import 'dart:convert';

import 'package:daily_ddl/services/ai_service.dart';
import 'package:daily_ddl/services/task_service.dart';
import 'package:daily_ddl/db/database.dart';
import 'package:daily_ddl/db/settings_dao.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

String response(List<Map<String, dynamic>> tasks) => jsonEncode({
  'choices': [
    {
      'message': {
        'content': jsonEncode({'tasks': tasks}),
      },
    },
  ],
});
Map<String, dynamic> task() => {
  'title': '测试作业',
  'kind': 'ddl',
  'deadline': '2099-01-01T18:00:00+08:00',
};
void main() {
  test('总结复用配置且读取普通文本，发送的内容为调用方整理的 JSON', () async {
    final config = AiConfig()
      ..endpoint = 'https://example.com/v1'
      ..model = 'summary-model'
      ..key = 'test-key'
      ..enabled = true;
    final dio = Dio();
    const payload = '{"counts":{"daily":2,"ddl":1}}';
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.uri.path, '/v1/chat/completions');
          expect(options.data['model'], 'summary-model');
          expect(options.data['messages'][1]['content'], payload);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: ResponseBody.fromString(
                '{"choices":[{"message":{"content":"完成了三项任务。"}}]}',
                200,
              ),
            ),
          );
        },
      ),
    );
    final client = ApiTaskExtractor(config, client: dio);
    addTearDown(client.close);
    expect(await client.summarize(payload), '完成了三项任务。');
  });

  test('混合多任务按各自原文补日期，日期无时分保留为当日结束', () {
    final now = DateTime(2026, 10, 30, 12);
    final rows = [
      TaskDraft(
        draftId: 'a',
        title: '投100份简历',
        kind: 'ddl',
        unresolved: ['截止时间不明'],
      ),
      TaskDraft(
        draftId: 'b',
        title: '数据库作业',
        kind: 'daily',
        unresolved: ['时间缺失'],
      ),
    ];
    final result = ApiTaskExtractor.resolveInputDates(
      rows,
      '帮我加一个下个月15号截止的ddl作业，标题为投100份简历，以及一个今天要完成的数据库作业',
      now,
    );
    expect(result[0].deadline, DateTime(2026, 11, 15, 23, 59, 59));
    expect(result[1].deadline, DateTime(2026, 10, 30, 23, 59, 59));
    final full = ApiTaskExtractor.resolveInputDates(
      rows,
      '下个月15号截止的ddl作业标题为投100份简历，以及一个今天要完成的数据库作业',
      now,
    );
    expect(full[0].deadline, DateTime(2026, 11, 15, 23, 59, 59));
    expect(full[1].deadline, DateTime(2026, 10, 30, 23, 59, 59));
  });
  test('月份跨年、无效日期及已有时间不被错误覆盖', () {
    final d = TaskDraft(draftId: 'x', title: '简历', kind: 'ddl');
    expect(
      ApiTaskExtractor.resolveInputDates(
        [d],
        '下个月15号简历',
        DateTime(2026, 12, 1),
      ).single.deadline,
      DateTime(2027, 1, 15, 23, 59, 59),
    );
    expect(
      ApiTaskExtractor.resolveInputDates(
        [d],
        '下个月31号简历',
        DateTime(2026, 1, 1),
      ).single.deadline,
      isNull,
    );
    expect(
      ApiTaskExtractor.resolveInputDates(
        [d],
        '下个月15号13点简历',
        DateTime(2026, 1, 1),
      ).single.deadline,
      isNull,
    );
  });

  test('明确今日任务无时间默认当天结束，确认后按今天入库且不重复', () async {
    final now = DateTime(2026, 10, 30, 12);
    final missing = TaskDraft(
      draftId: 'x',
      title: '完成链表练习',
      kind: 'daily',
      unresolved: ['未提供具体时间，deadline留空'],
    );
    final draft = ApiTaskExtractor.applyTodayDefault(
      [missing],
      '创建一个今日任务：完成链表练习',
      now,
    ).single;
    expect(draft.deadline, DateTime(2026, 10, 30, 23, 59, 59));
    expect(draft.unresolved, isEmpty);
    expect(draft.repeatRule, isNull);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final service = TaskService(db);
    await service.confirm(
      service.prepareConfirmation([draft], now),
      requestId: 'today',
      now: now,
    );
    expect((await service.allTasks()).single.scheduledDate, '2026-10-30');
  });
  test('不覆盖明确截止，普通缺日期和混合多任务不全局套今天', () {
    final now = DateTime(2026, 10, 30, 12);
    final d = TaskDraft(draftId: 'x', title: '链表', kind: 'ddl');
    expect(
      ApiTaskExtractor.applyTodayDefault([d], '完成链表', now).single.deadline,
      isNull,
    );
    expect(
      ApiTaskExtractor.applyTodayDefault(
        [d],
        '今日任务，后天13点交',
        now,
      ).single.deadline,
      isNull,
    );
    expect(
      ApiTaskExtractor.applyTodayDefault([d, d], '今日任务', now).first.deadline,
      isNull,
    );
    final dated = TaskDraft(
      draftId: 'x',
      title: '链表',
      kind: 'ddl',
      deadline: DateTime(2026, 11, 1, 13),
    );
    expect(
      ApiTaskExtractor.applyTodayDefault([dated], '今日任务', now).single.deadline,
      dated.deadline,
    );
  });
  test('模型列表不要求激活或模型名，同主机认证且禁止重定向', () async {
    final c = AiConfig()
      ..endpoint = 'https://api.deepseek.com'
      ..key = 'SECRET';
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          expect(o.uri.toString(), 'https://api.deepseek.com/models');
          expect(o.method, 'GET');
          expect(o.followRedirects, isFalse);
          expect(o.headers['Authorization'], 'Bearer SECRET');
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: ResponseBody.fromString(
                '{"data":[{"id":"model-b"},{"id":"model-a"},{"id":"model-b"}]}',
                200,
              ),
            ),
          );
        },
      ),
    );
    final e = ApiTaskExtractor(c, client: dio);
    addTearDown(e.close);
    expect(await e.listModels(), ['model-a', 'model-b']);
  });
  test('模型列表空结果和失败不能当作配置成功', () async {
    final c = AiConfig()
      ..endpoint = 'https://example.com/v1'
      ..key = 'SECRET';
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          expect(o.uri.path, '/v1/models');
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: ResponseBody.fromString('{"data":[]}', 200),
            ),
          );
        },
      ),
    );
    final e = ApiTaskExtractor(c, client: dio);
    addTearDown(e.close);
    await expectLater(e.listModels(), throwsA(isA<AiFailure>()));
  });

  test('根地址和v1地址补全，完整地址不重复拼接', () {
    final c = AiConfig();
    for (final url in [
      'https://api.deepseek.com',
      'https://api.deepseek.com/',
      'https://api.deepseek.com/chat/completions',
    ]) {
      c.endpoint = url;
      expect(c.uri.toString(), 'https://api.deepseek.com/chat/completions');
    }
    c.endpoint = 'https://example.com/v1/';
    expect(c.uri.path, '/v1/chat/completions');
  });
  test('区分余额、模型与连接问题，不输出服务私密响应', () async {
    final c = AiConfig()
      ..endpoint = 'https://api.deepseek.com'
      ..model = 'demo'
      ..key = 'SECRET'
      ..enabled = true;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          expect(o.contentType, Headers.jsonContentType);
          expect(o.data['thinking']['type'], 'disabled');
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 402,
              data: ResponseBody.fromString('{"error":"PRIVATE"}', 402),
            ),
          );
        },
      ),
    );
    final e = ApiTaskExtractor(c, client: dio);
    addTearDown(e.close);
    await expectLater(
      e.extract('任务', now: DateTime.now(), timeZone: 'UTC'),
      throwsA(
        isA<AiFailure>().having(
          (e) => e.message,
          'message',
          contains('HTTP 402'),
        ),
      ),
    );
  });

  test('解析草稿不写库，确认绑定内容，批量提交重试不重复', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final drafts = ApiTaskExtractor.decode(
      response([
        task(),
        {
          ...task(),
          'kind': 'daily',
          'deadline': null,
          'unresolved': ['日期缺失'],
        },
      ]),
    );
    final service = TaskService(db);
    expect(await service.allTasks(), isEmpty);
    expect(
      service.validate(drafts[1], DateTime.now()),
      contains('unresolved_fields'),
    );
    expect(drafts[0].source, 'agent');
    final a = service.prepareConfirmation([drafts.first], DateTime.now());
    final ids = await service.confirm(
      a,
      requestId: 'test',
      now: DateTime.now(),
    );
    expect(
      await service.confirm(a, requestId: 'test', now: DateTime.now()),
      ids,
    );
    expect(await service.allTasks(), hasLength(1));
  });
  test('错误结构、无时区日期和超量输出拒绝', () {
    expect(() => ApiTaskExtractor.decode('{}'), throwsA(isA<AiFailure>()));
    expect(
      () => ApiTaskExtractor.decode(
        response([
          {...task(), 'deadline': '2099-01-01T18:00:00'},
        ]),
      ),
      throwsA(isA<AiFailure>()),
    );
    expect(
      () => ApiTaskExtractor.decode(response(List.generate(21, (_) => task()))),
      throwsA(isA<AiFailure>()),
    );
    expect(ApiTaskExtractor.decode(response([])), isEmpty);
  });
  test('模型不能注入积分权重或确认权限', () {
    final d = ApiTaskExtractor.decode(
      response([
        {...task(), 'weight': 100, 'source': 'manual', 'confirmed': true},
      ]),
    ).single;
    expect(d.weight, isNull);
    expect(d.source, 'agent');
    expect(d.explicitTemporary, isFalse);
  });
  test('只保存服务地址和模型，不存Key及激活状态', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final c = AiConfig()
      ..endpoint = 'https://example.com/v1/chat/completions'
      ..model = 'demo'
      ..key = 'SECRET'
      ..enabled = true;
    await c.save(SettingsDao(db));
    final values = await db.select(db.settings).get();
    expect(values.map((r) => r.value).join(), isNot(contains('SECRET')));
    final next = AiConfig();
    await next.load(SettingsDao(db));
    expect(next.key, isEmpty);
    expect(next.enabled, isFalse);
    expect(next.model, 'demo');
  });
  test('未激活、明文或含凭据URL不发请求', () async {
    final c = AiConfig();
    final e = ApiTaskExtractor(c);
    addTearDown(e.close);
    await expectLater(
      e.extract('test', now: DateTime.now(), timeZone: 'UTC'),
      throwsA(isA<AiFailure>()),
    );
    c.enabled = true;
    c.key = 'secret';
    c.model = 'demo';
    c.endpoint = 'http://example.com';
    await expectLater(
      e.extract('test', now: DateTime.now(), timeZone: 'UTC'),
      throwsA(isA<AiFailure>()),
    );
    c.endpoint = 'https://user:password@example.com';
    expect(() => c.uri, throwsA(isA<AiFailure>()));
  });
  test('请求固定协议及禁止重定向，响应解析和认证错误脱敏', () async {
    final c = AiConfig()
      ..endpoint = 'https://example.com/v1/chat/completions'
      ..model = 'demo'
      ..key = 'SECRET'
      ..enabled = true;
    final client = Dio();
    var failure = false;
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.followRedirects, isFalse);
          expect(options.headers['Authorization'], 'Bearer SECRET');
          expect(options.data['messages'][1]['content'], '提交论文');
          if (failure) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 401),
              ),
            );
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: ResponseBody.fromString(response([task()]), 200),
              ),
            );
          }
        },
      ),
    );
    final e = ApiTaskExtractor(c, client: client);
    addTearDown(e.close);
    expect(
      await e.extract('提交论文', now: DateTime.now(), timeZone: 'UTC+08'),
      hasLength(1),
    );
    failure = true;
    await expectLater(
      e.extract('提交论文', now: DateTime.now(), timeZone: 'UTC+08'),
      throwsA(
        isA<AiFailure>().having(
          (e) => e.message,
          'message',
          isNot(contains('SECRET')),
        ),
      ),
    );
  });
}
