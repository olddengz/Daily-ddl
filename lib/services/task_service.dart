import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'plan_service.dart';
import '../db/task_repository.dart';
import '../db/settings_dao.dart';
import '../engine/recurrence.dart';

class TaskDraft {
  const TaskDraft({
    required this.draftId,
    required this.title,
    required this.kind,
    this.deadline,
    this.weight,
    this.course = '',
    this.note = '',
    this.priority = 'medium',
    this.type = 'self',
    this.repeatRule,
    this.repeatEnd,
    this.reminders = const [],
    this.source = 'agent',
    this.explicitTemporary = false,
    this.unresolved = const [],
  });
  final String draftId, title, kind, course, note, priority, type, source;
  final DateTime? deadline, repeatEnd;
  final double? weight;
  final String? repeatRule;
  final List<int> reminders;
  final bool explicitTemporary;
  final List<String> unresolved;
  Map<String, Object?> toJson() => {
    'weight': weight,
    'draftId': draftId,
    'title': title,
    'kind': kind,
    'deadline': deadline?.toUtc().toIso8601String(),
    'course': course,
    'note': note,
    'priority': priority,
    'type': type,
    'repeatRule': repeatRule,
    'repeatEnd': repeatEnd?.toUtc().toIso8601String(),
    'reminders': reminders,
    'source': source,
    'explicitTemporary': explicitTemporary,
    'unresolved': unresolved,
  };
}

/// Future model adapters return drafts only; no database or UI dependency.
abstract interface class TaskExtractor {
  Future<List<TaskDraft>> extract(
    String text, {
    required DateTime now,
    required String timeZone,
  });
}

class TaskCommandException implements Exception {
  const TaskCommandException(this.code);
  final String code;
  @override
  String toString() => code;
}

/// Only the confirmation UI retains this object. Adapters receive drafts, never
/// this capability. The snapshot is serialized to prevent later list mutation.
class TaskApproval {
  TaskApproval._(this.payload, this.localDate);
  final String payload, localDate;
}

class CompletionRecord {
  const CompletionRecord.forTask(Task value) : task = value, plan = null;
  const CompletionRecord.forPlan(Plan value) : task = null, plan = value;

  final Task? task;
  final Plan? plan;
  String get key => task == null ? 'plan:${plan!.id}' : 'task:${task!.id}';
  String get title => task?.title ?? plan!.title;
  DateTime? get completedAt => task?.completedAtUtc ?? plan?.completedAtUtc;
  DateTime? get deadline => task?.deadlineUtc ?? plan?.deadlineUtc;
  String get label => switch (task?.taskKind) {
    'daily' => '每日任务',
    'legacy' => '旧版待分类',
    null => '计划',
    _ => 'DDL',
  };
}

class TaskService {
  TaskService(AppDatabase db) : _db = db, _repo = TaskRepository(db);
  final AppDatabase _db;
  final TaskRepository _repo;
  Future<List<Task>> allTasks() => _repo.allTasks();
  Future<Task?> taskById(String id) => _repo.taskById(id);
  Future<double> earnedToday(DateTime now) => _repo.earnedToday(now.toLocal());
  Future<({int base, int bonus})> dailyCredits(DateTime now) =>
      _repo.dailyCredits(now.toLocal());
  Future<double> creditBalance(DateTime now) => _repo.balance(now: now);
  Future<ArchiveResult> archiveOverdue(
    Task expected, {
    required int quotedCost,
    required DateTime now,
  }) => _repo.archiveOverdue(expected, quotedCost: quotedCost, nowUtc: now);
  Future<List<Task>> history({String? kind, int offset = 0, int limit = 30}) {
    if (offset < 0 ||
        limit < 1 ||
        limit > 100 ||
        (kind != null && !['daily', 'ddl'].contains(kind))) {
      throw const TaskCommandException('validation_failed');
    }
    final q = _db.select(_db.tasks)..where((t) => t.status.equals('done'));
    if (kind != null) {
      q.where(
        (t) => kind == 'ddl'
            ? t.taskKind.isNotIn(['daily'])
            : t.taskKind.equals(kind),
      );
    }
    q.orderBy([
      (t) => OrderingTerm.desc(t.completedAtUtc),
      (t) => OrderingTerm.asc(t.id),
    ]);
    q.limit(limit, offset: offset);
    return q.get();
  }

  Future<List<CompletionRecord>> completionHistory({
    String? kind,
    DateTime? from,
    DateTime? until,
    int offset = 0,
    int limit = 30,
  }) => _db.transaction(() async {
    if (offset < 0 ||
        limit < 1 ||
        limit > 100 ||
        (kind != null && !['daily', 'ddl', 'plan'].contains(kind)) ||
        (from != null && until != null && !until.isAfter(from))) {
      throw const TaskCommandException('validation_failed');
    }

    final sources = [
      if (kind != 'plan')
        "SELECT id AS task_id, NULL AS plan_id, completed_at_utc FROM tasks "
        "WHERE status = 'done' "
        "${kind == 'daily' ? "AND task_kind = 'daily'" : kind == 'ddl' ? "AND task_kind != 'daily'" : ''}",
      if (kind == null || kind == 'plan')
        'SELECT NULL AS task_id, id AS plan_id, completed_at_utc FROM plans '
        'WHERE completed_at_utc IS NOT NULL',
    ];
    final keys = await _db.customSelect(
      'SELECT task_id, plan_id FROM (${sources.join(' UNION ALL ')}) '
      'WHERE 1 = 1 '
      '${from == null ? '' : 'AND completed_at_utc >= ? '}'
      '${until == null ? '' : 'AND completed_at_utc < ? '}'
      'ORDER BY completed_at_utc DESC, task_id IS NULL, task_id, plan_id '
      'LIMIT ? OFFSET ?',
      variables: [
        if (from != null) Variable<DateTime>(from.toUtc()),
        if (until != null) Variable<DateTime>(until.toUtc()),
        Variable<int>(limit),
        Variable<int>(offset),
      ],
      readsFrom: {_db.tasks, _db.plans},
    ).get();
    final taskIds = keys.map((r) => r.readNullable<String>('task_id')).nonNulls;
    final planIds = keys.map((r) => r.readNullable<int>('plan_id')).nonNulls;
    final tasks = {
      if (taskIds.isNotEmpty)
        for (final task in await (_db.select(_db.tasks)
              ..where((t) => t.id.isIn(taskIds))).get())
          task.id: task,
    };
    final plans = {
      if (planIds.isNotEmpty)
        for (final plan in await (_db.select(_db.plans)
              ..where((p) => p.id.isIn(planIds))).get())
          plan.id: plan,
    };
    return [
      for (final row in keys)
        if (row.readNullable<String>('task_id') case final id?)
          CompletionRecord.forTask(tasks[id]!)
        else
          CompletionRecord.forPlan(plans[row.read<int>('plan_id')]!),
    ];
  });

  Future<CompleteResult> complete(Task expected, DateTime now) =>
      _db.transaction(() async {
        final current = await _repo.taskById(expected.id);
        if (current == null) {
          return const CompleteResult(ok: false, reason: 'not_found');
        }
        if (current != expected) {
          return const CompleteResult(ok: false, reason: 'stale_state');
        }
        return _repo.completeTask(expected.id, now);
      });
  Future<bool> undo(Task expected, DateTime now) => _db.transaction(() async {
    final current = await _repo.taskById(expected.id);
    if (current == null || current != expected) {
      return false;
    }
    return _repo.undoComplete(expected.id, now);
  });
  List<String> validate(TaskDraft d, DateTime now) {
    final errors = <String>[];
    if (d.draftId.isEmpty ||
        d.title.trim().isEmpty ||
        !['daily', 'ddl', 'plan'].contains(d.kind)) {
      errors.add('title_or_kind');
    }
    if (!['high', 'medium', 'low'].contains(d.priority) ||
        !['self', 'assignment', 'exam'].contains(d.type)) {
      errors.add('classification');
    }
    if (!['manual', 'agent'].contains(d.source)) errors.add('source');
    if (d.unresolved.isNotEmpty) errors.add('unresolved_fields');
    if (d.deadline == null &&
        d.kind != 'plan' &&
        !(d.explicitTemporary && d.kind == 'daily' && d.repeatRule == null)) {
      errors.add('deadline_required');
    }
    if (d.deadline != null && !d.deadline!.isAfter(now)) {
      errors.add('deadline_expired');
    }
    if (d.kind == 'plan' &&
        (d.repeatRule != null || d.repeatEnd != null || d.reminders.isNotEmpty)) {
      errors.add('plan_schedule');
    }
    if (d.kind == 'daily' &&
        d.deadline != null &&
        TaskRepository.localDateKey(d.deadline!.toLocal()) !=
            TaskRepository.localDateKey(now.toLocal())) {
      errors.add('daily_date');
    }
    if (d.repeatRule != null && RepeatRule.parse(d.repeatRule) == null) {
      errors.add('repeat_rule');
    }
    if (d.repeatEnd != null &&
        (d.repeatRule == null ||
            (d.deadline != null && d.repeatEnd!.isBefore(d.deadline!)))) {
      errors.add('repeat_end');
    }
    if (d.weight != null && (!d.weight!.isFinite || d.weight! <= 0)) {
      errors.add('weight');
    }
    if (d.reminders.any((m) => m <= 0)) errors.add('reminders');
    return errors;
  }

  TaskApproval prepareConfirmation(List<TaskDraft> drafts, DateTime now) {
    if (drafts.isEmpty ||
        drafts.map((d) => d.draftId).toSet().length != drafts.length ||
        drafts.any((d) => validate(d, now).isNotEmpty)) {
      throw const TaskCommandException('validation_failed');
    }
    return TaskApproval._(
      jsonEncode(drafts.map((d) => d.toJson()).toList()),
      TaskRepository.localDateKey(now.toLocal()),
    );
  }

  Future<List<String>> confirm(
    TaskApproval approval, {
    required String requestId,
    required DateTime now,
  }) => _db.transaction(() async {
    if (requestId.trim().isEmpty) {
      throw const TaskCommandException('validation_failed');
    }
    final settings = SettingsDao(_db);
    final key = 'task_create_request:$requestId';
    final previous = await settings.get(key);
    if (previous != null) {
      final saved = jsonDecode(previous) as Map<String, dynamic>;
      if (saved['digest'] !=
          sha256.convert(utf8.encode(approval.payload)).toString()) {
        throw const TaskCommandException('request_conflict');
      }
      return (saved['ids'] as List).cast<String>();
    }
    if (approval.localDate != TaskRepository.localDateKey(now.toLocal())) {
      throw const TaskCommandException('stale_confirmation');
    }
    final rows = (jsonDecode(approval.payload) as List)
        .cast<Map<String, dynamic>>();
    final ids = <String>[];
    final plans = PlanService(_db);
    for (var i = 0; i < rows.length; i++) {
      final d = rows[i];
      if (d['kind'] == 'plan') {
        final raw = d['deadline'] as String?;
        final deadline = raw == null ? null : DateTime.parse(raw);
        if (deadline != null && !deadline.isAfter(now)) {
          throw const TaskCommandException('deadline_expired');
        }
        final id = await plans.create(d['title'] as String, deadline, now);
        ids.add('plan:$id');
        continue;
      }
      final deadline = d['deadline'] == null
          ? DateTime(
              now.toLocal().year,
              now.toLocal().month,
              now.toLocal().day,
              23,
              59,
              59,
            ).toUtc()
          : DateTime.parse(d['deadline'] as String);
      if (!deadline.isAfter(now)) {
        throw const TaskCommandException('deadline_expired');
      }
      final id = 'draft_${base64Url.encode(utf8.encode(requestId))}_$i';
      ids.add(id);
      await _repo.addTask(
        TasksCompanion.insert(
          id: id,
          title: (d['title'] as String).trim(),
          taskKind: Value(d['kind'] as String),
          course: Value(d['course'] as String),
          note: Value(d['note'] as String),
          priority: Value(d['priority'] as String),
          type: Value(d['type'] as String),
          source: Value(d['source'] as String),
          deadlineUtc: deadline,
          weightOverride: Value((d['weight'] as num?)?.toDouble()),
          scheduledDate: Value(
            d['kind'] == 'daily'
                ? TaskRepository.localDateKey(deadline.toLocal())
                : null,
          ),
          seriesId: Value(d['kind'] == 'daily' ? id : null),
          repeatRule: Value(d['repeatRule'] as String?),
          repeatEndUtc: Value(
            d['repeatEnd'] == null
                ? null
                : DateTime.parse(d['repeatEnd'] as String),
          ),
          remindMinutes: Value(jsonEncode(d['reminders'])),
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
    }
    await settings.set(
      key,
      jsonEncode({
        'digest': sha256.convert(utf8.encode(approval.payload)).toString(),
        'ids': ids,
      }),
    );
    return ids;
  });
}
