import 'package:flutter/material.dart';

import '../models/companion_models.dart';
import '../services/companion_service.dart';
import '../services/session_service.dart';

const _service = CompanionService();

class RelationshipPage extends StatelessWidget {
  const RelationshipPage({
    required this.characterId,
    required this.characterName,
    super.key,
  });

  final int characterId;
  final String characterName;

  @override
  Widget build(BuildContext context) {
    final userId = session.userId;
    if (userId == null) return const _SessionExpired();
    return FutureBuilder<RelationshipState>(
      future: _service.relationship(userId: userId, characterId: characterId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return _LoadError(error: snapshot.error);
        final state = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '你和$characterName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('当前情绪：${state.emotion}'),
            const SizedBox(height: 20),
            _Metric(label: '亲密度', value: state.intimacy, icon: Icons.favorite),
            _Metric(
              label: '信任度',
              value: state.trust,
              icon: Icons.handshake_outlined,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('关系等级 ${state.level}\n持续交流会解锁更多共同记忆与互动。'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MemoryPage extends StatefulWidget {
  const MemoryPage({required this.characterId, super.key});

  final int characterId;

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  late Future<List<MemoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant MemoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.characterId != oldWidget.characterId) setState(_reload);
  }

  void _reload() {
    _future = _service.myMemories(characterId: widget.characterId);
  }

  Future<void> _editMemory(MemoryItem memory) async {
    final content = TextEditingController(text: memory.content);
    var importance = memory.importance.clamp(1, 10).toInt();
    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('编辑记忆'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: content, maxLines: 4, autofocus: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('重要度'),
                  Expanded(
                    child: Slider(
                      value: importance.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '$importance',
                      onChanged: (value) =>
                          setDialogState(() => importance = value.round()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    if (changed != true || !mounted) {
      content.dispose();
      return;
    }
    try {
      await _service.updateMemory(
        id: memory.id,
        content: content.text.trim(),
        importance: importance,
      );
      if (!mounted) return;
      setState(_reload);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      content.dispose();
    }
  }

  Future<void> _deleteMemory(MemoryItem memory) async {
    try {
      await _service.deleteMemory(id: memory.id);
      if (mounted) setState(_reload);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('操作失败：$error')));

  @override
  Widget build(BuildContext context) => FutureBuilder<List<MemoryItem>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return _LoadError(error: snapshot.error);
      final memories = snapshot.data!;
      if (memories.isEmpty) return const Center(child: Text('还没有值得收藏的记忆。'));
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: memories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final memory = memories[index];
          return Dismissible(
            key: ValueKey(memory.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async =>
                await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('删除记忆'),
                    content: const Text('删除后无法恢复。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                ) ??
                false,
            onDismissed: (_) => _deleteMemory(memory),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Theme.of(context).colorScheme.error,
              child: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.auto_stories_outlined),
              title: Text(memory.content),
              subtitle: Text(memory.type),
              trailing: Text('${memory.importance}/10'),
              onTap: () => _editMemory(memory),
            ),
          );
        },
      );
    },
  );
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<AppNotification>> _future;
  bool _proactiveEnabled = true;
  bool _loadingPreference = true;
  bool _updatingPreference = false;
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    _future = _notifications();
    _loadPreference();
  }

  Future<List<AppNotification>> _notifications() {
    return _service.notifications(unreadOnly: _unreadOnly);
  }

  Future<void> _loadPreference() async {
    try {
      final preference = await _service.notificationPreference();
      if (mounted)
        setState(() => _proactiveEnabled = preference.proactiveEnabled);
    } catch (_) {
      // Notifications remain available if the optional preference request fails.
    } finally {
      if (mounted) setState(() => _loadingPreference = false);
    }
  }

  Future<void> _updatePreference(bool enabled) async {
    if (_updatingPreference) return;
    final previous = _proactiveEnabled;
    setState(() {
      _proactiveEnabled = enabled;
      _updatingPreference = true;
    });
    try {
      final preference = await _service.updateNotificationPreference(
        proactiveEnabled: enabled,
      );
      if (mounted)
        setState(() => _proactiveEnabled = preference.proactiveEnabled);
    } catch (error) {
      if (mounted) {
        setState(() => _proactiveEnabled = previous);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败：$error')));
      }
    } finally {
      if (mounted) setState(() => _updatingPreference = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<AppNotification>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return _LoadError(error: snapshot.error);
      final items = snapshot.data!;
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 2,
        itemBuilder: (_, index) {
          if (index == 0) {
            return SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('主动陪伴提醒'),
              subtitle: const Text('允许角色在一段时间未联系后发送关心消息'),
              value: _proactiveEnabled,
              onChanged: _loadingPreference || _updatingPreference
                  ? null
                  : _updatePreference,
            );
          }
          if (index == 1) {
            return CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('仅看未读'),
              value: _unreadOnly,
              onChanged: (value) => setState(() {
                _unreadOnly = value ?? false;
                _future = _notifications();
              }),
            );
          }
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text('暂时没有新通知。')),
            );
          }
          final item = items[index - 2];
          return ListTile(
            tileColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: Icon(
              item.read ? Icons.notifications_none : Icons.notifications,
            ),
            title: Text(item.title),
            subtitle: Text(item.content),
            onTap: item.read
                ? null
                : () async {
                    await _service.markNotificationRead(id: item.id);
                    if (mounted) setState(() => _future = _notifications());
                  },
          );
        },
      );
    },
  );
}

class _SessionExpired extends StatelessWidget {
  const _SessionExpired();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('登录状态已失效，请重新登录。', textAlign: TextAlign.center),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: value / 100),
          const SizedBox(height: 8),
          Text('$value / 100'),
        ],
      ),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error});
  final Object? error;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('暂时无法加载，请检查网络后重试。\n$error', textAlign: TextAlign.center),
    ),
  );
}
