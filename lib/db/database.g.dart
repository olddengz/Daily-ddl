// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseMeta = const VerificationMeta('course');
  @override
  late final GeneratedColumn<String> course = GeneratedColumn<String>(
    'course',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('self'),
  );
  static const VerificationMeta _taskKindMeta = const VerificationMeta(
    'taskKind',
  );
  @override
  late final GeneratedColumn<String> taskKind = GeneratedColumn<String>(
    'task_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('legacy'),
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<String> scheduledDate = GeneratedColumn<String>(
    'scheduled_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _deadlineUtcMeta = const VerificationMeta(
    'deadlineUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineUtc = GeneratedColumn<DateTime>(
    'deadline_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindMinutesMeta = const VerificationMeta(
    'remindMinutes',
  );
  @override
  late final GeneratedColumn<String> remindMinutes = GeneratedColumn<String>(
    'remind_minutes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _weightOverrideMeta = const VerificationMeta(
    'weightOverride',
  );
  @override
  late final GeneratedColumn<double> weightOverride = GeneratedColumn<double>(
    'weight_override',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('todo'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('windows'),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> completedAtUtc =
      GeneratedColumn<DateTime>(
        'completed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatEndUtcMeta = const VerificationMeta(
    'repeatEndUtc',
  );
  @override
  late final GeneratedColumn<DateTime> repeatEndUtc = GeneratedColumn<DateTime>(
    'repeat_end_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentTaskIdMeta = const VerificationMeta(
    'parentTaskId',
  );
  @override
  late final GeneratedColumn<String> parentTaskId = GeneratedColumn<String>(
    'parent_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    course,
    note,
    type,
    taskKind,
    scheduledDate,
    seriesId,
    priority,
    deadlineUtc,
    remindMinutes,
    weightOverride,
    status,
    source,
    deviceId,
    createdAtUtc,
    updatedAtUtc,
    completedAtUtc,
    repeatRule,
    repeatEndUtc,
    parentTaskId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('course')) {
      context.handle(
        _courseMeta,
        course.isAcceptableOrUnknown(data['course']!, _courseMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('task_kind')) {
      context.handle(
        _taskKindMeta,
        taskKind.isAcceptableOrUnknown(data['task_kind']!, _taskKindMeta),
      );
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('deadline_utc')) {
      context.handle(
        _deadlineUtcMeta,
        deadlineUtc.isAcceptableOrUnknown(
          data['deadline_utc']!,
          _deadlineUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deadlineUtcMeta);
    }
    if (data.containsKey('remind_minutes')) {
      context.handle(
        _remindMinutesMeta,
        remindMinutes.isAcceptableOrUnknown(
          data['remind_minutes']!,
          _remindMinutesMeta,
        ),
      );
    }
    if (data.containsKey('weight_override')) {
      context.handle(
        _weightOverrideMeta,
        weightOverride.isAcceptableOrUnknown(
          data['weight_override']!,
          _weightOverrideMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('repeat_end_utc')) {
      context.handle(
        _repeatEndUtcMeta,
        repeatEndUtc.isAcceptableOrUnknown(
          data['repeat_end_utc']!,
          _repeatEndUtcMeta,
        ),
      );
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(
        _parentTaskIdMeta,
        parentTaskId.isAcceptableOrUnknown(
          data['parent_task_id']!,
          _parentTaskIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      course: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      taskKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_kind'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_date'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      deadlineUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_utc'],
      )!,
      remindMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remind_minutes'],
      )!,
      weightOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_override'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at_utc'],
      ),
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      ),
      repeatEndUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}repeat_end_utc'],
      ),
      parentTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_task_id'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String course;
  final String note;

  /// assignment / exam / self
  final String type;

  /// legacy preserves existing tasks until the user explicitly classifies them.
  final String taskKind;
  final String? scheduledDate;
  final String? seriesId;

  /// high / medium / low
  final String priority;

  /// UTC，精度到分钟
  final DateTime deadlineUtc;

  /// JSON 数组字符串，如 [1440,180]
  final String remindMinutes;

  /// 手动权重覆盖；NULL 表示按公式
  final double? weightOverride;

  /// todo / done / overdue / cancelled
  final String status;

  /// manual / recurring
  final String source;

  /// 同步预留（阶段 2 用）
  final String deviceId;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? completedAtUtc;

  /// 每 N 天/周/月：`every:N:unit`；NULL=不重复
  final String? repeatRule;

  /// 循环结束日期；NULL=永不结束
  final DateTime? repeatEndUtc;

  /// 实现细节：自动生成的循环实例记录父实例 id（撤销完成时删除）
  final String? parentTaskId;
  const Task({
    required this.id,
    required this.title,
    required this.course,
    required this.note,
    required this.type,
    required this.taskKind,
    this.scheduledDate,
    this.seriesId,
    required this.priority,
    required this.deadlineUtc,
    required this.remindMinutes,
    this.weightOverride,
    required this.status,
    required this.source,
    required this.deviceId,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.completedAtUtc,
    this.repeatRule,
    this.repeatEndUtc,
    this.parentTaskId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['course'] = Variable<String>(course);
    map['note'] = Variable<String>(note);
    map['type'] = Variable<String>(type);
    map['task_kind'] = Variable<String>(taskKind);
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<String>(scheduledDate);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    map['priority'] = Variable<String>(priority);
    map['deadline_utc'] = Variable<DateTime>(deadlineUtc);
    map['remind_minutes'] = Variable<String>(remindMinutes);
    if (!nullToAbsent || weightOverride != null) {
      map['weight_override'] = Variable<double>(weightOverride);
    }
    map['status'] = Variable<String>(status);
    map['source'] = Variable<String>(source);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc);
    }
    if (!nullToAbsent || repeatRule != null) {
      map['repeat_rule'] = Variable<String>(repeatRule);
    }
    if (!nullToAbsent || repeatEndUtc != null) {
      map['repeat_end_utc'] = Variable<DateTime>(repeatEndUtc);
    }
    if (!nullToAbsent || parentTaskId != null) {
      map['parent_task_id'] = Variable<String>(parentTaskId);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      course: Value(course),
      note: Value(note),
      type: Value(type),
      taskKind: Value(taskKind),
      scheduledDate: scheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDate),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      priority: Value(priority),
      deadlineUtc: Value(deadlineUtc),
      remindMinutes: Value(remindMinutes),
      weightOverride: weightOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(weightOverride),
      status: Value(status),
      source: Value(source),
      deviceId: Value(deviceId),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      repeatRule: repeatRule == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatRule),
      repeatEndUtc: repeatEndUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatEndUtc),
      parentTaskId: parentTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTaskId),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      course: serializer.fromJson<String>(json['course']),
      note: serializer.fromJson<String>(json['note']),
      type: serializer.fromJson<String>(json['type']),
      taskKind: serializer.fromJson<String>(json['taskKind']),
      scheduledDate: serializer.fromJson<String?>(json['scheduledDate']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      priority: serializer.fromJson<String>(json['priority']),
      deadlineUtc: serializer.fromJson<DateTime>(json['deadlineUtc']),
      remindMinutes: serializer.fromJson<String>(json['remindMinutes']),
      weightOverride: serializer.fromJson<double?>(json['weightOverride']),
      status: serializer.fromJson<String>(json['status']),
      source: serializer.fromJson<String>(json['source']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completedAtUtc']),
      repeatRule: serializer.fromJson<String?>(json['repeatRule']),
      repeatEndUtc: serializer.fromJson<DateTime?>(json['repeatEndUtc']),
      parentTaskId: serializer.fromJson<String?>(json['parentTaskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'course': serializer.toJson<String>(course),
      'note': serializer.toJson<String>(note),
      'type': serializer.toJson<String>(type),
      'taskKind': serializer.toJson<String>(taskKind),
      'scheduledDate': serializer.toJson<String?>(scheduledDate),
      'seriesId': serializer.toJson<String?>(seriesId),
      'priority': serializer.toJson<String>(priority),
      'deadlineUtc': serializer.toJson<DateTime>(deadlineUtc),
      'remindMinutes': serializer.toJson<String>(remindMinutes),
      'weightOverride': serializer.toJson<double?>(weightOverride),
      'status': serializer.toJson<String>(status),
      'source': serializer.toJson<String>(source),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'completedAtUtc': serializer.toJson<DateTime?>(completedAtUtc),
      'repeatRule': serializer.toJson<String?>(repeatRule),
      'repeatEndUtc': serializer.toJson<DateTime?>(repeatEndUtc),
      'parentTaskId': serializer.toJson<String?>(parentTaskId),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? course,
    String? note,
    String? type,
    String? taskKind,
    Value<String?> scheduledDate = const Value.absent(),
    Value<String?> seriesId = const Value.absent(),
    String? priority,
    DateTime? deadlineUtc,
    String? remindMinutes,
    Value<double?> weightOverride = const Value.absent(),
    String? status,
    String? source,
    String? deviceId,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> completedAtUtc = const Value.absent(),
    Value<String?> repeatRule = const Value.absent(),
    Value<DateTime?> repeatEndUtc = const Value.absent(),
    Value<String?> parentTaskId = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    course: course ?? this.course,
    note: note ?? this.note,
    type: type ?? this.type,
    taskKind: taskKind ?? this.taskKind,
    scheduledDate: scheduledDate.present
        ? scheduledDate.value
        : this.scheduledDate,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    priority: priority ?? this.priority,
    deadlineUtc: deadlineUtc ?? this.deadlineUtc,
    remindMinutes: remindMinutes ?? this.remindMinutes,
    weightOverride: weightOverride.present
        ? weightOverride.value
        : this.weightOverride,
    status: status ?? this.status,
    source: source ?? this.source,
    deviceId: deviceId ?? this.deviceId,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    repeatRule: repeatRule.present ? repeatRule.value : this.repeatRule,
    repeatEndUtc: repeatEndUtc.present ? repeatEndUtc.value : this.repeatEndUtc,
    parentTaskId: parentTaskId.present ? parentTaskId.value : this.parentTaskId,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      course: data.course.present ? data.course.value : this.course,
      note: data.note.present ? data.note.value : this.note,
      type: data.type.present ? data.type.value : this.type,
      taskKind: data.taskKind.present ? data.taskKind.value : this.taskKind,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      priority: data.priority.present ? data.priority.value : this.priority,
      deadlineUtc: data.deadlineUtc.present
          ? data.deadlineUtc.value
          : this.deadlineUtc,
      remindMinutes: data.remindMinutes.present
          ? data.remindMinutes.value
          : this.remindMinutes,
      weightOverride: data.weightOverride.present
          ? data.weightOverride.value
          : this.weightOverride,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      repeatEndUtc: data.repeatEndUtc.present
          ? data.repeatEndUtc.value
          : this.repeatEndUtc,
      parentTaskId: data.parentTaskId.present
          ? data.parentTaskId.value
          : this.parentTaskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('course: $course, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('taskKind: $taskKind, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('seriesId: $seriesId, ')
          ..write('priority: $priority, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('remindMinutes: $remindMinutes, ')
          ..write('weightOverride: $weightOverride, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('repeatEndUtc: $repeatEndUtc, ')
          ..write('parentTaskId: $parentTaskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    course,
    note,
    type,
    taskKind,
    scheduledDate,
    seriesId,
    priority,
    deadlineUtc,
    remindMinutes,
    weightOverride,
    status,
    source,
    deviceId,
    createdAtUtc,
    updatedAtUtc,
    completedAtUtc,
    repeatRule,
    repeatEndUtc,
    parentTaskId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.course == this.course &&
          other.note == this.note &&
          other.type == this.type &&
          other.taskKind == this.taskKind &&
          other.scheduledDate == this.scheduledDate &&
          other.seriesId == this.seriesId &&
          other.priority == this.priority &&
          other.deadlineUtc == this.deadlineUtc &&
          other.remindMinutes == this.remindMinutes &&
          other.weightOverride == this.weightOverride &&
          other.status == this.status &&
          other.source == this.source &&
          other.deviceId == this.deviceId &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.completedAtUtc == this.completedAtUtc &&
          other.repeatRule == this.repeatRule &&
          other.repeatEndUtc == this.repeatEndUtc &&
          other.parentTaskId == this.parentTaskId);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> course;
  final Value<String> note;
  final Value<String> type;
  final Value<String> taskKind;
  final Value<String?> scheduledDate;
  final Value<String?> seriesId;
  final Value<String> priority;
  final Value<DateTime> deadlineUtc;
  final Value<String> remindMinutes;
  final Value<double?> weightOverride;
  final Value<String> status;
  final Value<String> source;
  final Value<String> deviceId;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> completedAtUtc;
  final Value<String?> repeatRule;
  final Value<DateTime?> repeatEndUtc;
  final Value<String?> parentTaskId;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.course = const Value.absent(),
    this.note = const Value.absent(),
    this.type = const Value.absent(),
    this.taskKind = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.priority = const Value.absent(),
    this.deadlineUtc = const Value.absent(),
    this.remindMinutes = const Value.absent(),
    this.weightOverride = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.repeatEndUtc = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.course = const Value.absent(),
    this.note = const Value.absent(),
    this.type = const Value.absent(),
    this.taskKind = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.priority = const Value.absent(),
    required DateTime deadlineUtc,
    this.remindMinutes = const Value.absent(),
    this.weightOverride = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.completedAtUtc = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.repeatEndUtc = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       deadlineUtc = Value(deadlineUtc),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? course,
    Expression<String>? note,
    Expression<String>? type,
    Expression<String>? taskKind,
    Expression<String>? scheduledDate,
    Expression<String>? seriesId,
    Expression<String>? priority,
    Expression<DateTime>? deadlineUtc,
    Expression<String>? remindMinutes,
    Expression<double>? weightOverride,
    Expression<String>? status,
    Expression<String>? source,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? completedAtUtc,
    Expression<String>? repeatRule,
    Expression<DateTime>? repeatEndUtc,
    Expression<String>? parentTaskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (course != null) 'course': course,
      if (note != null) 'note': note,
      if (type != null) 'type': type,
      if (taskKind != null) 'task_kind': taskKind,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (seriesId != null) 'series_id': seriesId,
      if (priority != null) 'priority': priority,
      if (deadlineUtc != null) 'deadline_utc': deadlineUtc,
      if (remindMinutes != null) 'remind_minutes': remindMinutes,
      if (weightOverride != null) 'weight_override': weightOverride,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (repeatEndUtc != null) 'repeat_end_utc': repeatEndUtc,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? course,
    Value<String>? note,
    Value<String>? type,
    Value<String>? taskKind,
    Value<String?>? scheduledDate,
    Value<String?>? seriesId,
    Value<String>? priority,
    Value<DateTime>? deadlineUtc,
    Value<String>? remindMinutes,
    Value<double?>? weightOverride,
    Value<String>? status,
    Value<String>? source,
    Value<String>? deviceId,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? completedAtUtc,
    Value<String?>? repeatRule,
    Value<DateTime?>? repeatEndUtc,
    Value<String?>? parentTaskId,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      note: note ?? this.note,
      type: type ?? this.type,
      taskKind: taskKind ?? this.taskKind,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      seriesId: seriesId ?? this.seriesId,
      priority: priority ?? this.priority,
      deadlineUtc: deadlineUtc ?? this.deadlineUtc,
      remindMinutes: remindMinutes ?? this.remindMinutes,
      weightOverride: weightOverride ?? this.weightOverride,
      status: status ?? this.status,
      source: source ?? this.source,
      deviceId: deviceId ?? this.deviceId,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      repeatRule: repeatRule ?? this.repeatRule,
      repeatEndUtc: repeatEndUtc ?? this.repeatEndUtc,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (course.present) {
      map['course'] = Variable<String>(course.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (taskKind.present) {
      map['task_kind'] = Variable<String>(taskKind.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<String>(scheduledDate.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (deadlineUtc.present) {
      map['deadline_utc'] = Variable<DateTime>(deadlineUtc.value);
    }
    if (remindMinutes.present) {
      map['remind_minutes'] = Variable<String>(remindMinutes.value);
    }
    if (weightOverride.present) {
      map['weight_override'] = Variable<double>(weightOverride.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (repeatEndUtc.present) {
      map['repeat_end_utc'] = Variable<DateTime>(repeatEndUtc.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<String>(parentTaskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('course: $course, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('taskKind: $taskKind, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('seriesId: $seriesId, ')
          ..write('priority: $priority, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('remindMinutes: $remindMinutes, ')
          ..write('weightOverride: $weightOverride, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('repeatEndUtc: $repeatEndUtc, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks with TableInfo<$SubtasksTable, Subtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estMinutesMeta = const VerificationMeta(
    'estMinutes',
  );
  @override
  late final GeneratedColumn<int> estMinutes = GeneratedColumn<int>(
    'est_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    title,
    estMinutes,
    done,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('est_minutes')) {
      context.handle(
        _estMinutesMeta,
        estMinutes.isAcceptableOrUnknown(data['est_minutes']!, _estMinutesMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      estMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}est_minutes'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }
}

class Subtask extends DataClass implements Insertable<Subtask> {
  final int id;
  final String taskId;
  final String title;
  final int? estMinutes;
  final bool done;
  final int sortOrder;
  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.estMinutes,
    required this.done,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || estMinutes != null) {
      map['est_minutes'] = Variable<int>(estMinutes);
    }
    map['done'] = Variable<bool>(done);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      estMinutes: estMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estMinutes),
      done: Value(done),
      sortOrder: Value(sortOrder),
    );
  }

  factory Subtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subtask(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      estMinutes: serializer.fromJson<int?>(json['estMinutes']),
      done: serializer.fromJson<bool>(json['done']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'estMinutes': serializer.toJson<int?>(estMinutes),
      'done': serializer.toJson<bool>(done),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Subtask copyWith({
    int? id,
    String? taskId,
    String? title,
    Value<int?> estMinutes = const Value.absent(),
    bool? done,
    int? sortOrder,
  }) => Subtask(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    estMinutes: estMinutes.present ? estMinutes.value : this.estMinutes,
    done: done ?? this.done,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Subtask copyWithCompanion(SubtasksCompanion data) {
    return Subtask(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      estMinutes: data.estMinutes.present
          ? data.estMinutes.value
          : this.estMinutes,
      done: data.done.present ? data.done.value : this.done,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subtask(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('estMinutes: $estMinutes, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, title, estMinutes, done, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subtask &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.estMinutes == this.estMinutes &&
          other.done == this.done &&
          other.sortOrder == this.sortOrder);
}

class SubtasksCompanion extends UpdateCompanion<Subtask> {
  final Value<int> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<int?> estMinutes;
  final Value<bool> done;
  final Value<int> sortOrder;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.estMinutes = const Value.absent(),
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SubtasksCompanion.insert({
    this.id = const Value.absent(),
    required String taskId,
    required String title,
    this.estMinutes = const Value.absent(),
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : taskId = Value(taskId),
       title = Value(title);
  static Insertable<Subtask> custom({
    Expression<int>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<int>? estMinutes,
    Expression<bool>? done,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (estMinutes != null) 'est_minutes': estMinutes,
      if (done != null) 'done': done,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SubtasksCompanion copyWith({
    Value<int>? id,
    Value<String>? taskId,
    Value<String>? title,
    Value<int?>? estMinutes,
    Value<bool>? done,
    Value<int>? sortOrder,
  }) {
    return SubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      estMinutes: estMinutes ?? this.estMinutes,
      done: done ?? this.done,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (estMinutes.present) {
      map['est_minutes'] = Variable<int>(estMinutes.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('estMinutes: $estMinutes, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CreditLedgerTable extends CreditLedger
    with TableInfo<$CreditLedgerTable, CreditLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refTypeMeta = const VerificationMeta(
    'refType',
  );
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
    'ref_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settleDateMeta = const VerificationMeta(
    'settleDate',
  );
  @override
  late final GeneratedColumn<String> settleDate = GeneratedColumn<String>(
    'settle_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    refType,
    refId,
    settleDate,
    note,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('ref_type')) {
      context.handle(
        _refTypeMeta,
        refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta),
      );
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('settle_date')) {
      context.handle(
        _settleDateMeta,
        settleDate.isAcceptableOrUnknown(data['settle_date']!, _settleDateMeta),
      );
    } else if (isInserting) {
      context.missing(_settleDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditLedgerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      refType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_type'],
      ),
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      settleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settle_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $CreditLedgerTable createAlias(String alias) {
    return $CreditLedgerTable(attachedDatabase, alias);
  }
}

class CreditLedgerData extends DataClass
    implements Insertable<CreditLedgerData> {
  final int id;
  final String type;
  final double amount;
  final String? refType;
  final String? refId;
  final String settleDate;
  final String note;
  final DateTime createdAtUtc;
  const CreditLedgerData({
    required this.id,
    required this.type,
    required this.amount,
    this.refType,
    this.refId,
    required this.settleDate,
    required this.note,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || refType != null) {
      map['ref_type'] = Variable<String>(refType);
    }
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    map['settle_date'] = Variable<String>(settleDate);
    map['note'] = Variable<String>(note);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    return map;
  }

  CreditLedgerCompanion toCompanion(bool nullToAbsent) {
    return CreditLedgerCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      refType: refType == null && nullToAbsent
          ? const Value.absent()
          : Value(refType),
      refId: refId == null && nullToAbsent
          ? const Value.absent()
          : Value(refId),
      settleDate: Value(settleDate),
      note: Value(note),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory CreditLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditLedgerData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      refType: serializer.fromJson<String?>(json['refType']),
      refId: serializer.fromJson<String?>(json['refId']),
      settleDate: serializer.fromJson<String>(json['settleDate']),
      note: serializer.fromJson<String>(json['note']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'refType': serializer.toJson<String?>(refType),
      'refId': serializer.toJson<String?>(refId),
      'settleDate': serializer.toJson<String>(settleDate),
      'note': serializer.toJson<String>(note),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  CreditLedgerData copyWith({
    int? id,
    String? type,
    double? amount,
    Value<String?> refType = const Value.absent(),
    Value<String?> refId = const Value.absent(),
    String? settleDate,
    String? note,
    DateTime? createdAtUtc,
  }) => CreditLedgerData(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    refType: refType.present ? refType.value : this.refType,
    refId: refId.present ? refId.value : this.refId,
    settleDate: settleDate ?? this.settleDate,
    note: note ?? this.note,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  CreditLedgerData copyWithCompanion(CreditLedgerCompanion data) {
    return CreditLedgerData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      settleDate: data.settleDate.present
          ? data.settleDate.value
          : this.settleDate,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditLedgerData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('settleDate: $settleDate, ')
          ..write('note: $note, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    refType,
    refId,
    settleDate,
    note,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditLedgerData &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.settleDate == this.settleDate &&
          other.note == this.note &&
          other.createdAtUtc == this.createdAtUtc);
}

class CreditLedgerCompanion extends UpdateCompanion<CreditLedgerData> {
  final Value<int> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<String?> refType;
  final Value<String?> refId;
  final Value<String> settleDate;
  final Value<String> note;
  final Value<DateTime> createdAtUtc;
  const CreditLedgerCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.settleDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  CreditLedgerCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required double amount,
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    required String settleDate,
    this.note = const Value.absent(),
    required DateTime createdAtUtc,
  }) : type = Value(type),
       amount = Value(amount),
       settleDate = Value(settleDate),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<CreditLedgerData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? refType,
    Expression<String>? refId,
    Expression<String>? settleDate,
    Expression<String>? note,
    Expression<DateTime>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (settleDate != null) 'settle_date': settleDate,
      if (note != null) 'note': note,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  CreditLedgerCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<double>? amount,
    Value<String?>? refType,
    Value<String?>? refId,
    Value<String>? settleDate,
    Value<String>? note,
    Value<DateTime>? createdAtUtc,
  }) {
    return CreditLedgerCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      settleDate: settleDate ?? this.settleDate,
      note: note ?? this.note,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (settleDate.present) {
      map['settle_date'] = Variable<String>(settleDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditLedgerCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('settleDate: $settleDate, ')
          ..write('note: $note, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

class $RewardsTable extends Rewards with TableInfo<$RewardsTable, Reward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatableMeta = const VerificationMeta(
    'repeatable',
  );
  @override
  late final GeneratedColumn<bool> repeatable = GeneratedColumn<bool>(
    'repeatable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeatable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _redeemedCountMeta = const VerificationMeta(
    'redeemedCount',
  );
  @override
  late final GeneratedColumn<int> redeemedCount = GeneratedColumn<int>(
    'redeemed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cost,
    repeatable,
    redeemedCount,
    sortOrder,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rewards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('repeatable')) {
      context.handle(
        _repeatableMeta,
        repeatable.isAcceptableOrUnknown(data['repeatable']!, _repeatableMeta),
      );
    }
    if (data.containsKey('redeemed_count')) {
      context.handle(
        _redeemedCountMeta,
        redeemedCount.isAcceptableOrUnknown(
          data['redeemed_count']!,
          _redeemedCountMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      repeatable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeatable'],
      )!,
      redeemedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}redeemed_count'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $RewardsTable createAlias(String alias) {
    return $RewardsTable(attachedDatabase, alias);
  }
}

class Reward extends DataClass implements Insertable<Reward> {
  final int id;
  final String name;
  final double cost;
  final bool repeatable;
  final int redeemedCount;
  final int sortOrder;
  final DateTime createdAtUtc;
  const Reward({
    required this.id,
    required this.name,
    required this.cost,
    required this.repeatable,
    required this.redeemedCount,
    required this.sortOrder,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['cost'] = Variable<double>(cost);
    map['repeatable'] = Variable<bool>(repeatable);
    map['redeemed_count'] = Variable<int>(redeemedCount);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    return map;
  }

  RewardsCompanion toCompanion(bool nullToAbsent) {
    return RewardsCompanion(
      id: Value(id),
      name: Value(name),
      cost: Value(cost),
      repeatable: Value(repeatable),
      redeemedCount: Value(redeemedCount),
      sortOrder: Value(sortOrder),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory Reward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reward(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cost: serializer.fromJson<double>(json['cost']),
      repeatable: serializer.fromJson<bool>(json['repeatable']),
      redeemedCount: serializer.fromJson<int>(json['redeemedCount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cost': serializer.toJson<double>(cost),
      'repeatable': serializer.toJson<bool>(repeatable),
      'redeemedCount': serializer.toJson<int>(redeemedCount),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  Reward copyWith({
    int? id,
    String? name,
    double? cost,
    bool? repeatable,
    int? redeemedCount,
    int? sortOrder,
    DateTime? createdAtUtc,
  }) => Reward(
    id: id ?? this.id,
    name: name ?? this.name,
    cost: cost ?? this.cost,
    repeatable: repeatable ?? this.repeatable,
    redeemedCount: redeemedCount ?? this.redeemedCount,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  Reward copyWithCompanion(RewardsCompanion data) {
    return Reward(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cost: data.cost.present ? data.cost.value : this.cost,
      repeatable: data.repeatable.present
          ? data.repeatable.value
          : this.repeatable,
      redeemedCount: data.redeemedCount.present
          ? data.redeemedCount.value
          : this.redeemedCount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reward(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('repeatable: $repeatable, ')
          ..write('redeemedCount: $redeemedCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    cost,
    repeatable,
    redeemedCount,
    sortOrder,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reward &&
          other.id == this.id &&
          other.name == this.name &&
          other.cost == this.cost &&
          other.repeatable == this.repeatable &&
          other.redeemedCount == this.redeemedCount &&
          other.sortOrder == this.sortOrder &&
          other.createdAtUtc == this.createdAtUtc);
}

class RewardsCompanion extends UpdateCompanion<Reward> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> cost;
  final Value<bool> repeatable;
  final Value<int> redeemedCount;
  final Value<int> sortOrder;
  final Value<DateTime> createdAtUtc;
  const RewardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cost = const Value.absent(),
    this.repeatable = const Value.absent(),
    this.redeemedCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  RewardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double cost,
    this.repeatable = const Value.absent(),
    this.redeemedCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAtUtc,
  }) : name = Value(name),
       cost = Value(cost),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<Reward> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? cost,
    Expression<bool>? repeatable,
    Expression<int>? redeemedCount,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cost != null) 'cost': cost,
      if (repeatable != null) 'repeatable': repeatable,
      if (redeemedCount != null) 'redeemed_count': redeemedCount,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  RewardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? cost,
    Value<bool>? repeatable,
    Value<int>? redeemedCount,
    Value<int>? sortOrder,
    Value<DateTime>? createdAtUtc,
  }) {
    return RewardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      repeatable: repeatable ?? this.repeatable,
      redeemedCount: redeemedCount ?? this.redeemedCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (repeatable.present) {
      map['repeatable'] = Variable<bool>(repeatable.value);
    }
    if (redeemedCount.present) {
      map['redeemed_count'] = Variable<int>(redeemedCount.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('repeatable: $repeatable, ')
          ..write('redeemedCount: $redeemedCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

class $RewardLogsTable extends RewardLogs
    with TableInfo<$RewardLogsTable, RewardLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<int> ledgerId = GeneratedColumn<int>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES credit_ledger (id)',
    ),
  );
  static const VerificationMeta _rewardIdMeta = const VerificationMeta(
    'rewardId',
  );
  @override
  late final GeneratedColumn<int> rewardId = GeneratedColumn<int>(
    'reward_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rewards (id)',
    ),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _redeemedAtUtcMeta = const VerificationMeta(
    'redeemedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> redeemedAtUtc =
      GeneratedColumn<DateTime>(
        'redeemed_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerId,
    rewardId,
    cost,
    redeemedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reward_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RewardLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('reward_id')) {
      context.handle(
        _rewardIdMeta,
        rewardId.isAcceptableOrUnknown(data['reward_id']!, _rewardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardIdMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('redeemed_at_utc')) {
      context.handle(
        _redeemedAtUtcMeta,
        redeemedAtUtc.isAcceptableOrUnknown(
          data['redeemed_at_utc']!,
          _redeemedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_redeemedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RewardLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ledger_id'],
      )!,
      rewardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_id'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      redeemedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}redeemed_at_utc'],
      )!,
    );
  }

  @override
  $RewardLogsTable createAlias(String alias) {
    return $RewardLogsTable(attachedDatabase, alias);
  }
}

class RewardLog extends DataClass implements Insertable<RewardLog> {
  final int id;
  final int ledgerId;
  final int rewardId;
  final double cost;
  final DateTime redeemedAtUtc;
  const RewardLog({
    required this.id,
    required this.ledgerId,
    required this.rewardId,
    required this.cost,
    required this.redeemedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ledger_id'] = Variable<int>(ledgerId);
    map['reward_id'] = Variable<int>(rewardId);
    map['cost'] = Variable<double>(cost);
    map['redeemed_at_utc'] = Variable<DateTime>(redeemedAtUtc);
    return map;
  }

  RewardLogsCompanion toCompanion(bool nullToAbsent) {
    return RewardLogsCompanion(
      id: Value(id),
      ledgerId: Value(ledgerId),
      rewardId: Value(rewardId),
      cost: Value(cost),
      redeemedAtUtc: Value(redeemedAtUtc),
    );
  }

  factory RewardLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardLog(
      id: serializer.fromJson<int>(json['id']),
      ledgerId: serializer.fromJson<int>(json['ledgerId']),
      rewardId: serializer.fromJson<int>(json['rewardId']),
      cost: serializer.fromJson<double>(json['cost']),
      redeemedAtUtc: serializer.fromJson<DateTime>(json['redeemedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ledgerId': serializer.toJson<int>(ledgerId),
      'rewardId': serializer.toJson<int>(rewardId),
      'cost': serializer.toJson<double>(cost),
      'redeemedAtUtc': serializer.toJson<DateTime>(redeemedAtUtc),
    };
  }

  RewardLog copyWith({
    int? id,
    int? ledgerId,
    int? rewardId,
    double? cost,
    DateTime? redeemedAtUtc,
  }) => RewardLog(
    id: id ?? this.id,
    ledgerId: ledgerId ?? this.ledgerId,
    rewardId: rewardId ?? this.rewardId,
    cost: cost ?? this.cost,
    redeemedAtUtc: redeemedAtUtc ?? this.redeemedAtUtc,
  );
  RewardLog copyWithCompanion(RewardLogsCompanion data) {
    return RewardLog(
      id: data.id.present ? data.id.value : this.id,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      rewardId: data.rewardId.present ? data.rewardId.value : this.rewardId,
      cost: data.cost.present ? data.cost.value : this.cost,
      redeemedAtUtc: data.redeemedAtUtc.present
          ? data.redeemedAtUtc.value
          : this.redeemedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardLog(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('rewardId: $rewardId, ')
          ..write('cost: $cost, ')
          ..write('redeemedAtUtc: $redeemedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ledgerId, rewardId, cost, redeemedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardLog &&
          other.id == this.id &&
          other.ledgerId == this.ledgerId &&
          other.rewardId == this.rewardId &&
          other.cost == this.cost &&
          other.redeemedAtUtc == this.redeemedAtUtc);
}

class RewardLogsCompanion extends UpdateCompanion<RewardLog> {
  final Value<int> id;
  final Value<int> ledgerId;
  final Value<int> rewardId;
  final Value<double> cost;
  final Value<DateTime> redeemedAtUtc;
  const RewardLogsCompanion({
    this.id = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.rewardId = const Value.absent(),
    this.cost = const Value.absent(),
    this.redeemedAtUtc = const Value.absent(),
  });
  RewardLogsCompanion.insert({
    this.id = const Value.absent(),
    required int ledgerId,
    required int rewardId,
    required double cost,
    required DateTime redeemedAtUtc,
  }) : ledgerId = Value(ledgerId),
       rewardId = Value(rewardId),
       cost = Value(cost),
       redeemedAtUtc = Value(redeemedAtUtc);
  static Insertable<RewardLog> custom({
    Expression<int>? id,
    Expression<int>? ledgerId,
    Expression<int>? rewardId,
    Expression<double>? cost,
    Expression<DateTime>? redeemedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (rewardId != null) 'reward_id': rewardId,
      if (cost != null) 'cost': cost,
      if (redeemedAtUtc != null) 'redeemed_at_utc': redeemedAtUtc,
    });
  }

  RewardLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? ledgerId,
    Value<int>? rewardId,
    Value<double>? cost,
    Value<DateTime>? redeemedAtUtc,
  }) {
    return RewardLogsCompanion(
      id: id ?? this.id,
      ledgerId: ledgerId ?? this.ledgerId,
      rewardId: rewardId ?? this.rewardId,
      cost: cost ?? this.cost,
      redeemedAtUtc: redeemedAtUtc ?? this.redeemedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<int>(ledgerId.value);
    }
    if (rewardId.present) {
      map['reward_id'] = Variable<int>(rewardId.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (redeemedAtUtc.present) {
      map['redeemed_at_utc'] = Variable<DateTime>(redeemedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardLogsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('rewardId: $rewardId, ')
          ..write('cost: $cost, ')
          ..write('redeemedAtUtc: $redeemedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiCacheTable extends AiCache with TableInfo<$AiCacheTable, AiCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _featureMeta = const VerificationMeta(
    'feature',
  );
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
    'feature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cacheKey,
    feature,
    resultJson,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('feature')) {
      context.handle(
        _featureMeta,
        feature.isAcceptableOrUnknown(data['feature']!, _featureMeta),
      );
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_resultJsonMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      feature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $AiCacheTable createAlias(String alias) {
    return $AiCacheTable(attachedDatabase, alias);
  }
}

class AiCacheData extends DataClass implements Insertable<AiCacheData> {
  final int id;
  final String cacheKey;
  final String feature;
  final String resultJson;
  final DateTime createdAtUtc;
  const AiCacheData({
    required this.id,
    required this.cacheKey,
    required this.feature,
    required this.resultJson,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cache_key'] = Variable<String>(cacheKey);
    map['feature'] = Variable<String>(feature);
    map['result_json'] = Variable<String>(resultJson);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    return map;
  }

  AiCacheCompanion toCompanion(bool nullToAbsent) {
    return AiCacheCompanion(
      id: Value(id),
      cacheKey: Value(cacheKey),
      feature: Value(feature),
      resultJson: Value(resultJson),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory AiCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiCacheData(
      id: serializer.fromJson<int>(json['id']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      feature: serializer.fromJson<String>(json['feature']),
      resultJson: serializer.fromJson<String>(json['resultJson']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'feature': serializer.toJson<String>(feature),
      'resultJson': serializer.toJson<String>(resultJson),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  AiCacheData copyWith({
    int? id,
    String? cacheKey,
    String? feature,
    String? resultJson,
    DateTime? createdAtUtc,
  }) => AiCacheData(
    id: id ?? this.id,
    cacheKey: cacheKey ?? this.cacheKey,
    feature: feature ?? this.feature,
    resultJson: resultJson ?? this.resultJson,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  AiCacheData copyWithCompanion(AiCacheCompanion data) {
    return AiCacheData(
      id: data.id.present ? data.id.value : this.id,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      feature: data.feature.present ? data.feature.value : this.feature,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiCacheData(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('feature: $feature, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cacheKey, feature, resultJson, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiCacheData &&
          other.id == this.id &&
          other.cacheKey == this.cacheKey &&
          other.feature == this.feature &&
          other.resultJson == this.resultJson &&
          other.createdAtUtc == this.createdAtUtc);
}

class AiCacheCompanion extends UpdateCompanion<AiCacheData> {
  final Value<int> id;
  final Value<String> cacheKey;
  final Value<String> feature;
  final Value<String> resultJson;
  final Value<DateTime> createdAtUtc;
  const AiCacheCompanion({
    this.id = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.feature = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  AiCacheCompanion.insert({
    this.id = const Value.absent(),
    required String cacheKey,
    required String feature,
    required String resultJson,
    required DateTime createdAtUtc,
  }) : cacheKey = Value(cacheKey),
       feature = Value(feature),
       resultJson = Value(resultJson),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<AiCacheData> custom({
    Expression<int>? id,
    Expression<String>? cacheKey,
    Expression<String>? feature,
    Expression<String>? resultJson,
    Expression<DateTime>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (feature != null) 'feature': feature,
      if (resultJson != null) 'result_json': resultJson,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  AiCacheCompanion copyWith({
    Value<int>? id,
    Value<String>? cacheKey,
    Value<String>? feature,
    Value<String>? resultJson,
    Value<DateTime>? createdAtUtc,
  }) {
    return AiCacheCompanion(
      id: id ?? this.id,
      cacheKey: cacheKey ?? this.cacheKey,
      feature: feature ?? this.feature,
      resultJson: resultJson ?? this.resultJson,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiCacheCompanion(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('feature: $feature, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $CreditLedgerTable creditLedger = $CreditLedgerTable(this);
  late final $RewardsTable rewards = $RewardsTable(this);
  late final $RewardLogsTable rewardLogs = $RewardLogsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AiCacheTable aiCache = $AiCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    subtasks,
    creditLedger,
    rewards,
    rewardLogs,
    settings,
    aiCache,
  ];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  Value<String> course,
  Value<String> note,
  Value<String> type,
  Value<String> taskKind,
  Value<String?> scheduledDate,
  Value<String?> seriesId,
  Value<String> priority,
  required DateTime deadlineUtc,
  Value<String> remindMinutes,
  Value<double?> weightOverride,
  Value<String> status,
  Value<String> source,
  Value<String> deviceId,
  required DateTime createdAtUtc,
  required DateTime updatedAtUtc,
  Value<DateTime?> completedAtUtc,
  Value<String?> repeatRule,
  Value<DateTime?> repeatEndUtc,
  Value<String?> parentTaskId,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> course,
  Value<String> note,
  Value<String> type,
  Value<String> taskKind,
  Value<String?> scheduledDate,
  Value<String?> seriesId,
  Value<String> priority,
  Value<DateTime> deadlineUtc,
  Value<String> remindMinutes,
  Value<double?> weightOverride,
  Value<String> status,
  Value<String> source,
  Value<String> deviceId,
  Value<DateTime> createdAtUtc,
  Value<DateTime> updatedAtUtc,
  Value<DateTime?> completedAtUtc,
  Value<String?> repeatRule,
  Value<DateTime?> repeatEndUtc,
  Value<String?> parentTaskId,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubtasksTable, List<Subtask>> _subtasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.subtasks,
    aliasName: 'tasks__id__subtasks__task_id',
  );

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager(
      $_db,
      $_db.subtasks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get course => $composableBuilder(
    column: $table.course,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskKind => $composableBuilder(
    column: $table.taskKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineUtc => $composableBuilder(
    column: $table.deadlineUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remindMinutes => $composableBuilder(
    column: $table.remindMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightOverride => $composableBuilder(
    column: $table.weightOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get repeatEndUtc => $composableBuilder(
    column: $table.repeatEndUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentTaskId => $composableBuilder(
    column: $table.parentTaskId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subtasksRefs(
    Expression<bool> Function($$SubtasksTableFilterComposer f) f,
  ) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableFilterComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get course => $composableBuilder(
    column: $table.course,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskKind => $composableBuilder(
    column: $table.taskKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineUtc => $composableBuilder(
    column: $table.deadlineUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remindMinutes => $composableBuilder(
    column: $table.remindMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightOverride => $composableBuilder(
    column: $table.weightOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get repeatEndUtc => $composableBuilder(
    column: $table.repeatEndUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentTaskId => $composableBuilder(
    column: $table.parentTaskId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get course =>
      $composableBuilder(column: $table.course, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get taskKind =>
      $composableBuilder(column: $table.taskKind, builder: (column) => column);

  GeneratedColumn<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get deadlineUtc => $composableBuilder(
    column: $table.deadlineUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remindMinutes => $composableBuilder(
    column: $table.remindMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightOverride => $composableBuilder(
    column: $table.weightOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get repeatEndUtc => $composableBuilder(
    column: $table.repeatEndUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentTaskId => $composableBuilder(
    column: $table.parentTaskId,
    builder: (column) => column,
  );

  Expression<T> subtasksRefs<T extends Object>(
    Expression<T> Function($$SubtasksTableAnnotationComposer a) f,
  ) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool subtasksRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> course = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> taskKind = const Value.absent(),
                Value<String?> scheduledDate = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<DateTime> deadlineUtc = const Value.absent(),
                Value<String> remindMinutes = const Value.absent(),
                Value<double?> weightOverride = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<String?> repeatRule = const Value.absent(),
                Value<DateTime?> repeatEndUtc = const Value.absent(),
                Value<String?> parentTaskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                course: course,
                note: note,
                type: type,
                taskKind: taskKind,
                scheduledDate: scheduledDate,
                seriesId: seriesId,
                priority: priority,
                deadlineUtc: deadlineUtc,
                remindMinutes: remindMinutes,
                weightOverride: weightOverride,
                status: status,
                source: source,
                deviceId: deviceId,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                completedAtUtc: completedAtUtc,
                repeatRule: repeatRule,
                repeatEndUtc: repeatEndUtc,
                parentTaskId: parentTaskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> course = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> taskKind = const Value.absent(),
                Value<String?> scheduledDate = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                required DateTime deadlineUtc,
                Value<String> remindMinutes = const Value.absent(),
                Value<double?> weightOverride = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<String?> repeatRule = const Value.absent(),
                Value<DateTime?> repeatEndUtc = const Value.absent(),
                Value<String?> parentTaskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                course: course,
                note: note,
                type: type,
                taskKind: taskKind,
                scheduledDate: scheduledDate,
                seriesId: seriesId,
                priority: priority,
                deadlineUtc: deadlineUtc,
                remindMinutes: remindMinutes,
                weightOverride: weightOverride,
                status: status,
                source: source,
                deviceId: deviceId,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                completedAtUtc: completedAtUtc,
                repeatRule: repeatRule,
                repeatEndUtc: repeatEndUtc,
                parentTaskId: parentTaskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subtasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (subtasksRefs) db.subtasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subtasksRefs)
                    await $_getPrefetchedData<Task, $TasksTable, Subtask>(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._subtasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TasksTableReferences(db, table, p0).subtasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool subtasksRefs})
    >;
typedef $$SubtasksTableCreateCompanionBuilder = SubtasksCompanion Function({
  Value<int> id,
  required String taskId,
  required String title,
  Value<int?> estMinutes,
  Value<bool> done,
  Value<int> sortOrder,
});
typedef $$SubtasksTableUpdateCompanionBuilder = SubtasksCompanion Function({
  Value<int> id,
  Value<String> taskId,
  Value<String> title,
  Value<int?> estMinutes,
  Value<bool> done,
  Value<int> sortOrder,
});

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, Subtask> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('subtasks__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estMinutes => $composableBuilder(
    column: $table.estMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estMinutes => $composableBuilder(
    column: $table.estMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get estMinutes => $composableBuilder(
    column: $table.estMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtasksTable,
          Subtask,
          $$SubtasksTableFilterComposer,
          $$SubtasksTableOrderingComposer,
          $$SubtasksTableAnnotationComposer,
          $$SubtasksTableCreateCompanionBuilder,
          $$SubtasksTableUpdateCompanionBuilder,
          (Subtask, $$SubtasksTableReferences),
          Subtask,
          PrefetchHooks Function({bool taskId})
        > {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> estMinutes = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubtasksCompanion(
                id: id,
                taskId: taskId,
                title: title,
                estMinutes: estMinutes,
                done: done,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String taskId,
                required String title,
                Value<int?> estMinutes = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubtasksCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                estMinutes: estMinutes,
                done: done,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubtasksTable, Subtask>(table),
                  $$SubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$SubtasksTableReferences._taskIdTable(
                          db,
                        ),
                        referencedColumn: $$SubtasksTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtasksTable,
      Subtask,
      $$SubtasksTableFilterComposer,
      $$SubtasksTableOrderingComposer,
      $$SubtasksTableAnnotationComposer,
      $$SubtasksTableCreateCompanionBuilder,
      $$SubtasksTableUpdateCompanionBuilder,
      (Subtask, $$SubtasksTableReferences),
      Subtask,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$CreditLedgerTableCreateCompanionBuilder =
    CreditLedgerCompanion Function({
      Value<int> id,
      required String type,
      required double amount,
      Value<String?> refType,
      Value<String?> refId,
      required String settleDate,
      Value<String> note,
      required DateTime createdAtUtc,
    });
typedef $$CreditLedgerTableUpdateCompanionBuilder =
    CreditLedgerCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<double> amount,
      Value<String?> refType,
      Value<String?> refId,
      Value<String> settleDate,
      Value<String> note,
      Value<DateTime> createdAtUtc,
    });

final class $$CreditLedgerTableReferences
    extends
        BaseReferences<_$AppDatabase, $CreditLedgerTable, CreditLedgerData> {
  $$CreditLedgerTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RewardLogsTable, List<RewardLog>>
  _rewardLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rewardLogs,
    aliasName: 'credit_ledger__id__reward_logs__ledger_id',
  );

  $$RewardLogsTableProcessedTableManager get rewardLogsRefs {
    final manager = $$RewardLogsTableTableManager(
      $_db,
      $_db.rewardLogs,
    ).filter((f) => f.ledgerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rewardLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CreditLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $CreditLedgerTable> {
  $$CreditLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settleDate => $composableBuilder(
    column: $table.settleDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rewardLogsRefs(
    Expression<bool> Function($$RewardLogsTableFilterComposer f) f,
  ) {
    final $$RewardLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rewardLogs,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardLogsTableFilterComposer(
            $db: $db,
            $table: $db.rewardLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CreditLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditLedgerTable> {
  $$CreditLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settleDate => $composableBuilder(
    column: $table.settleDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CreditLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditLedgerTable> {
  $$CreditLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get settleDate => $composableBuilder(
    column: $table.settleDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  Expression<T> rewardLogsRefs<T extends Object>(
    Expression<T> Function($$RewardLogsTableAnnotationComposer a) f,
  ) {
    final $$RewardLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rewardLogs,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.rewardLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CreditLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditLedgerTable,
          CreditLedgerData,
          $$CreditLedgerTableFilterComposer,
          $$CreditLedgerTableOrderingComposer,
          $$CreditLedgerTableAnnotationComposer,
          $$CreditLedgerTableCreateCompanionBuilder,
          $$CreditLedgerTableUpdateCompanionBuilder,
          (CreditLedgerData, $$CreditLedgerTableReferences),
          CreditLedgerData,
          PrefetchHooks Function({bool rewardLogsRefs})
        > {
  $$CreditLedgerTableTableManager(_$AppDatabase db, $CreditLedgerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> refType = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<String> settleDate = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
              }) => CreditLedgerCompanion(
                id: id,
                type: type,
                amount: amount,
                refType: refType,
                refId: refId,
                settleDate: settleDate,
                note: note,
                createdAtUtc: createdAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required double amount,
                Value<String?> refType = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                required String settleDate,
                Value<String> note = const Value.absent(),
                required DateTime createdAtUtc,
              }) => CreditLedgerCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                refType: refType,
                refId: refId,
                settleDate: settleDate,
                note: note,
                createdAtUtc: createdAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CreditLedgerTable, CreditLedgerData>(table),
                  $$CreditLedgerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rewardLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (rewardLogsRefs) db.rewardLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rewardLogsRefs)
                    await $_getPrefetchedData<
                      CreditLedgerData,
                      $CreditLedgerTable,
                      RewardLog
                    >(
                      currentTable: table,
                      referencedTable: $$CreditLedgerTableReferences
                          ._rewardLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CreditLedgerTableReferences(
                            db,
                            table,
                            p0,
                          ).rewardLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ledgerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CreditLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditLedgerTable,
      CreditLedgerData,
      $$CreditLedgerTableFilterComposer,
      $$CreditLedgerTableOrderingComposer,
      $$CreditLedgerTableAnnotationComposer,
      $$CreditLedgerTableCreateCompanionBuilder,
      $$CreditLedgerTableUpdateCompanionBuilder,
      (CreditLedgerData, $$CreditLedgerTableReferences),
      CreditLedgerData,
      PrefetchHooks Function({bool rewardLogsRefs})
    >;
typedef $$RewardsTableCreateCompanionBuilder = RewardsCompanion Function({
  Value<int> id,
  required String name,
  required double cost,
  Value<bool> repeatable,
  Value<int> redeemedCount,
  Value<int> sortOrder,
  required DateTime createdAtUtc,
});
typedef $$RewardsTableUpdateCompanionBuilder = RewardsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> cost,
  Value<bool> repeatable,
  Value<int> redeemedCount,
  Value<int> sortOrder,
  Value<DateTime> createdAtUtc,
});

final class $$RewardsTableReferences
    extends BaseReferences<_$AppDatabase, $RewardsTable, Reward> {
  $$RewardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RewardLogsTable, List<RewardLog>>
  _rewardLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rewardLogs,
    aliasName: 'rewards__id__reward_logs__reward_id',
  );

  $$RewardLogsTableProcessedTableManager get rewardLogsRefs {
    final manager = $$RewardLogsTableTableManager(
      $_db,
      $_db.rewardLogs,
    ).filter((f) => f.rewardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rewardLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RewardsTableFilterComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatable => $composableBuilder(
    column: $table.repeatable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redeemedCount => $composableBuilder(
    column: $table.redeemedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rewardLogsRefs(
    Expression<bool> Function($$RewardLogsTableFilterComposer f) f,
  ) {
    final $$RewardLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rewardLogs,
      getReferencedColumn: (t) => t.rewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardLogsTableFilterComposer(
            $db: $db,
            $table: $db.rewardLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RewardsTableOrderingComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatable => $composableBuilder(
    column: $table.repeatable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redeemedCount => $composableBuilder(
    column: $table.redeemedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<bool> get repeatable => $composableBuilder(
    column: $table.repeatable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get redeemedCount => $composableBuilder(
    column: $table.redeemedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  Expression<T> rewardLogsRefs<T extends Object>(
    Expression<T> Function($$RewardLogsTableAnnotationComposer a) f,
  ) {
    final $$RewardLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rewardLogs,
      getReferencedColumn: (t) => t.rewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.rewardLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RewardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RewardsTable,
          Reward,
          $$RewardsTableFilterComposer,
          $$RewardsTableOrderingComposer,
          $$RewardsTableAnnotationComposer,
          $$RewardsTableCreateCompanionBuilder,
          $$RewardsTableUpdateCompanionBuilder,
          (Reward, $$RewardsTableReferences),
          Reward,
          PrefetchHooks Function({bool rewardLogsRefs})
        > {
  $$RewardsTableTableManager(_$AppDatabase db, $RewardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<bool> repeatable = const Value.absent(),
                Value<int> redeemedCount = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
              }) => RewardsCompanion(
                id: id,
                name: name,
                cost: cost,
                repeatable: repeatable,
                redeemedCount: redeemedCount,
                sortOrder: sortOrder,
                createdAtUtc: createdAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double cost,
                Value<bool> repeatable = const Value.absent(),
                Value<int> redeemedCount = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAtUtc,
              }) => RewardsCompanion.insert(
                id: id,
                name: name,
                cost: cost,
                repeatable: repeatable,
                redeemedCount: redeemedCount,
                sortOrder: sortOrder,
                createdAtUtc: createdAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RewardsTable, Reward>(table),
                  $$RewardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rewardLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (rewardLogsRefs) db.rewardLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rewardLogsRefs)
                    await $_getPrefetchedData<Reward, $RewardsTable, RewardLog>(
                      currentTable: table,
                      referencedTable: $$RewardsTableReferences
                          ._rewardLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RewardsTableReferences(
                        db,
                        table,
                        p0,
                      ).rewardLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.rewardId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RewardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RewardsTable,
      Reward,
      $$RewardsTableFilterComposer,
      $$RewardsTableOrderingComposer,
      $$RewardsTableAnnotationComposer,
      $$RewardsTableCreateCompanionBuilder,
      $$RewardsTableUpdateCompanionBuilder,
      (Reward, $$RewardsTableReferences),
      Reward,
      PrefetchHooks Function({bool rewardLogsRefs})
    >;
typedef $$RewardLogsTableCreateCompanionBuilder = RewardLogsCompanion Function({
  Value<int> id,
  required int ledgerId,
  required int rewardId,
  required double cost,
  required DateTime redeemedAtUtc,
});
typedef $$RewardLogsTableUpdateCompanionBuilder = RewardLogsCompanion Function({
  Value<int> id,
  Value<int> ledgerId,
  Value<int> rewardId,
  Value<double> cost,
  Value<DateTime> redeemedAtUtc,
});

final class $$RewardLogsTableReferences
    extends BaseReferences<_$AppDatabase, $RewardLogsTable, RewardLog> {
  $$RewardLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CreditLedgerTable _ledgerIdTable(_$AppDatabase db) =>
      db.creditLedger.createAlias('reward_logs__ledger_id__credit_ledger__id');

  $$CreditLedgerTableProcessedTableManager get ledgerId {
    final $_column = $_itemColumn<int>('ledger_id')!;

    final manager = $$CreditLedgerTableTableManager(
      $_db,
      $_db.creditLedger,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RewardsTable _rewardIdTable(_$AppDatabase db) =>
      db.rewards.createAlias('reward_logs__reward_id__rewards__id');

  $$RewardsTableProcessedTableManager get rewardId {
    final $_column = $_itemColumn<int>('reward_id')!;

    final manager = $$RewardsTableTableManager(
      $_db,
      $_db.rewards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rewardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RewardLogsTableFilterComposer
    extends Composer<_$AppDatabase, $RewardLogsTable> {
  $$RewardLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get redeemedAtUtc => $composableBuilder(
    column: $table.redeemedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$CreditLedgerTableFilterComposer get ledgerId {
    final $$CreditLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.creditLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditLedgerTableFilterComposer(
            $db: $db,
            $table: $db.creditLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableFilterComposer get rewardId {
    final $$RewardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableFilterComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RewardLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $RewardLogsTable> {
  $$RewardLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get redeemedAtUtc => $composableBuilder(
    column: $table.redeemedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$CreditLedgerTableOrderingComposer get ledgerId {
    final $$CreditLedgerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.creditLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditLedgerTableOrderingComposer(
            $db: $db,
            $table: $db.creditLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableOrderingComposer get rewardId {
    final $$RewardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableOrderingComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RewardLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RewardLogsTable> {
  $$RewardLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get redeemedAtUtc => $composableBuilder(
    column: $table.redeemedAtUtc,
    builder: (column) => column,
  );

  $$CreditLedgerTableAnnotationComposer get ledgerId {
    final $$CreditLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.creditLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.creditLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableAnnotationComposer get rewardId {
    final $$RewardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableAnnotationComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RewardLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RewardLogsTable,
          RewardLog,
          $$RewardLogsTableFilterComposer,
          $$RewardLogsTableOrderingComposer,
          $$RewardLogsTableAnnotationComposer,
          $$RewardLogsTableCreateCompanionBuilder,
          $$RewardLogsTableUpdateCompanionBuilder,
          (RewardLog, $$RewardLogsTableReferences),
          RewardLog,
          PrefetchHooks Function({bool ledgerId, bool rewardId})
        > {
  $$RewardLogsTableTableManager(_$AppDatabase db, $RewardLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ledgerId = const Value.absent(),
                Value<int> rewardId = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<DateTime> redeemedAtUtc = const Value.absent(),
              }) => RewardLogsCompanion(
                id: id,
                ledgerId: ledgerId,
                rewardId: rewardId,
                cost: cost,
                redeemedAtUtc: redeemedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ledgerId,
                required int rewardId,
                required double cost,
                required DateTime redeemedAtUtc,
              }) => RewardLogsCompanion.insert(
                id: id,
                ledgerId: ledgerId,
                rewardId: rewardId,
                cost: cost,
                redeemedAtUtc: redeemedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RewardLogsTable, RewardLog>(table),
                  $$RewardLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ledgerId = false, rewardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ledgerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ledgerId,
                        referencedTable: $$RewardLogsTableReferences
                            ._ledgerIdTable(db),
                        referencedColumn: $$RewardLogsTableReferences
                            ._ledgerIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (rewardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.rewardId,
                        referencedTable: $$RewardLogsTableReferences
                            ._rewardIdTable(db),
                        referencedColumn: $$RewardLogsTableReferences
                            ._rewardIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RewardLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RewardLogsTable,
      RewardLog,
      $$RewardLogsTableFilterComposer,
      $$RewardLogsTableOrderingComposer,
      $$RewardLogsTableAnnotationComposer,
      $$RewardLogsTableCreateCompanionBuilder,
      $$RewardLogsTableUpdateCompanionBuilder,
      (RewardLog, $$RewardLogsTableReferences),
      RewardLog,
      PrefetchHooks Function({bool ledgerId, bool rewardId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$AiCacheTableCreateCompanionBuilder = AiCacheCompanion Function({
  Value<int> id,
  required String cacheKey,
  required String feature,
  required String resultJson,
  required DateTime createdAtUtc,
});
typedef $$AiCacheTableUpdateCompanionBuilder = AiCacheCompanion Function({
  Value<int> id,
  Value<String> cacheKey,
  Value<String> feature,
  Value<String> resultJson,
  Value<DateTime> createdAtUtc,
});

class $$AiCacheTableFilterComposer
    extends Composer<_$AppDatabase, $AiCacheTable> {
  $$AiCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $AiCacheTable> {
  $$AiCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiCacheTable> {
  $$AiCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$AiCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiCacheTable,
          AiCacheData,
          $$AiCacheTableFilterComposer,
          $$AiCacheTableOrderingComposer,
          $$AiCacheTableAnnotationComposer,
          $$AiCacheTableCreateCompanionBuilder,
          $$AiCacheTableUpdateCompanionBuilder,
          (
            AiCacheData,
            BaseReferences<_$AppDatabase, $AiCacheTable, AiCacheData>,
          ),
          AiCacheData,
          PrefetchHooks Function()
        > {
  $$AiCacheTableTableManager(_$AppDatabase db, $AiCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> feature = const Value.absent(),
                Value<String> resultJson = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
              }) => AiCacheCompanion(
                id: id,
                cacheKey: cacheKey,
                feature: feature,
                resultJson: resultJson,
                createdAtUtc: createdAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cacheKey,
                required String feature,
                required String resultJson,
                required DateTime createdAtUtc,
              }) => AiCacheCompanion.insert(
                id: id,
                cacheKey: cacheKey,
                feature: feature,
                resultJson: resultJson,
                createdAtUtc: createdAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiCacheTable, AiCacheData>(table),
                  BaseReferences<_$AppDatabase, $AiCacheTable, AiCacheData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiCacheTable,
      AiCacheData,
      $$AiCacheTableFilterComposer,
      $$AiCacheTableOrderingComposer,
      $$AiCacheTableAnnotationComposer,
      $$AiCacheTableCreateCompanionBuilder,
      $$AiCacheTableUpdateCompanionBuilder,
      (AiCacheData, BaseReferences<_$AppDatabase, $AiCacheTable, AiCacheData>),
      AiCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$CreditLedgerTableTableManager get creditLedger =>
      $$CreditLedgerTableTableManager(_db, _db.creditLedger);
  $$RewardsTableTableManager get rewards =>
      $$RewardsTableTableManager(_db, _db.rewards);
  $$RewardLogsTableTableManager get rewardLogs =>
      $$RewardLogsTableTableManager(_db, _db.rewardLogs);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$AiCacheTableTableManager get aiCache =>
      $$AiCacheTableTableManager(_db, _db.aiCache);
}
