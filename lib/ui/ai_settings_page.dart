import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/settings_dao.dart';
import '../services/ai_service.dart';

class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key, required this.db});
  final AppDatabase db;
  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  final config = AiConfig.instance;
  final endpoint = TextEditingController(),
      model = TextEditingController(),
      keyInput = TextEditingController();
  bool loading = true, busy = false;
  List<String> models = [];
  String? message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await config.load(SettingsDao(widget.db));
    if (!mounted) return;
    endpoint.text = config.endpoint;
    model.text = config.model;
    keyInput.text = config.key;
    setState(() => loading = false);
  }

  @override
  void dispose() {
    endpoint.dispose();
    model.dispose();
    keyInput.dispose();
    super.dispose();
  }

  Future<void> _fetchModels() async {
    setState(() {
      busy = true;
      message = null;
      models = [];
    });
    final client = ApiTaskExtractor(
      AiConfig()
        ..endpoint = endpoint.text.trim()
        ..key = keyInput.text,
    );
    try {
      final result = await client.listModels();
      if (!mounted) return;
      setState(() {
        models = result;
        message = '已获取模型，请从列表选择';
      });
    } catch (e) {
      if (mounted) {
        setState(() => message = e is AiFailure ? e.message : '获取模型失败');
      }
    } finally {
      client.close();
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(
    TextEditingController c,
    String label, {
    bool secret = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: TextField(
      controller: c,
      enabled: !busy,
      obscureText: secret,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
  Widget _configuration() => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('填写支持 Chat Completions 的服务。供文字添加与日历总结使用。'),
          field(endpoint, 'API 地址（支持根地址或完整接口地址）'),
          field(model, '模型名称（可手动填写或从列表选择）'),
          field(keyInput, 'API Key（仅本次运行有效）', secret: true),
          TextButton(
            onPressed: busy ? null : _fetchModels,
            child: const Text('获取模型列表'),
          ),
          if (models.isNotEmpty)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '选择可用模型'),
              items: models
                  .map(
                    (id) => DropdownMenuItem(
                      value: id,
                      child: Text(id, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: busy ? null : (v) => setState(() => model.text = v!),
            ),
          TextButton(
            onPressed: busy
                ? null
                : () async {
                    try {
                      final draft = AiConfig()
                        ..endpoint = endpoint.text.trim()
                        ..model = model.text.trim()
                        ..key = keyInput.text.trim();
                      if (draft.model.isEmpty || draft.key.isEmpty) {
                        throw const AiFailure('请填写模型和API Key');
                      }
                      draft.endpoint = draft.uri.toString();
                      await draft.save(SettingsDao(widget.db));
                      config.endpoint = draft.endpoint;
                      config.model = draft.model;
                      config.key = draft.key;
                      if (mounted) {
                        setState(() {
                          config.enabled = true;
                          message = 'AI 已启用';
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(
                          () => message = e is AiFailure
                              ? e.message
                              : '配置未保存，请重试',
                        );
                      }
                    }
                  },
            child: const Text('保存并启用'),
          ),
          SwitchListTile(
            title: const Text('启用 AI'),
            value: config.enabled,
            onChanged: busy ? null : (v) => setState(() => config.enabled = v),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI 设置')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _configuration(),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(message!),
                    ),
                ],
              ),
            ),
          ),
  );
}
