import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/boyfriend_preset.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../widgets/character_avatar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.characterId,
    required this.characterName,
    this.characterAvatar,
    this.characterModel,
    super.key,
  });

  final int characterId;
  final String characterName;
  final String? characterAvatar;

  /// 3D 模型地址：`model:bf_xxx` 内置资源或 http(s) 链接
  final String? characterModel;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _chat = ChatService();
  final List<ChatMessage> _messages = [];
  bool _loadingHistory = true;
  bool _loadingEarlier = false;
  bool _hasMore = false;
  int? _nextBeforeMessageId;
  String? _historyError;
  bool _sending = false;
  bool _showModel = false;

  /// 解析角色 3D 模型来源：优先 characterModel，否则由预设头像推导内置模型
  String? get _modelSrc {
    final model = widget.characterModel;
    if (model != null && model.isNotEmpty) {
      return BoyfriendPreset.isPresetModel(model)
          ? BoyfriendPreset.modelAssetOf(model)
          : model;
    }
    final derived = BoyfriendPreset.modelFor(widget.characterAvatar);
    return derived == null ? null : BoyfriendPreset.modelAssetOf(derived);
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.characterId == oldWidget.characterId) return;
    _messages.clear();
    _hasMore = false;
    _nextBeforeMessageId = null;
    _loadHistory();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    if (text.length > 4000) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('消息太长了，请控制在 4000 字以内')));
      return;
    }
    setState(() {
      _messages.add(ChatMessage(id: null, role: 'user', content: text));
      _messages.add(
        const ChatMessage(id: null, role: 'assistant', content: ''),
      );
      _sending = true;
      _input.clear();
    });
    _jumpToEnd();
    final characterId = widget.characterId;
    final replyIndex = _messages.length - 1;
    var reply = '';
    try {
      await for (final chunk in _chat.streamMessage(
        characterId: characterId,
        message: text,
      )) {
        reply += chunk;
        if (!mounted || widget.characterId != characterId) return;
        setState(
          () => _messages[replyIndex] = ChatMessage(
            id: null,
            role: 'assistant',
            content: reply,
          ),
        );
        _jumpToEnd();
      }
    } catch (error) {
      if (!mounted || widget.characterId != characterId) return;
      setState(
        () => _messages[replyIndex] = ChatMessage(
          id: null,
          role: 'assistant',
          content: reply.isEmpty ? '回复暂时中断，请稍后查看聊天记录。' : reply,
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('流式回复中断：$error')));
    } finally {
      if (mounted) setState(() => _sending = false);
      _jumpToEnd();
    }
  }

  Future<void> _loadHistory({bool earlier = false}) async {
    if (earlier && (!_hasMore || _loadingEarlier)) return;
    setState(() {
      if (earlier) {
        _loadingEarlier = true;
      } else {
        _loadingHistory = true;
        _historyError = null;
      }
    });
    final characterId = widget.characterId;
    try {
      final page = await _chat.history(
        characterId: characterId,
        beforeMessageId: earlier ? _nextBeforeMessageId : null,
      );
      if (!mounted || widget.characterId != characterId) return;
      setState(() {
        _messages.insertAll(0, page.messages);
        _nextBeforeMessageId = page.nextBeforeMessageId;
        _hasMore = page.hasMore;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _historyError = '历史消息加载失败：$error');
    } finally {
      if (mounted) {
        setState(() {
          _loadingHistory = false;
          _loadingEarlier = false;
        });
      }
    }
  }

  void _jumpToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients)
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
  });

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        children: [
          _CompanionHeader(
            name: widget.characterName,
            avatar: widget.characterAvatar,
            modelVisible: _showModel,
            onToggleModel: _modelSrc == null
                ? null
                : () => setState(() => _showModel = !_showModel),
          ),
          Expanded(child: _buildMessages()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: '说点什么...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    tooltip: '发送',
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      if (_showModel && _modelSrc != null)
        _FloatingModelPanel(
          src: _modelSrc!,
          onClose: () => setState(() => _showModel = false),
        ),
    ],
  );

  Widget _buildMessages() {
    if (_loadingHistory)
      return const Center(child: CircularProgressIndicator());
    if (_historyError != null && _messages.isEmpty) {
      return Center(
        child: TextButton(onPressed: _loadHistory, child: Text(_historyError!)),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (_hasMore && index == 0) {
          return Center(
            child: TextButton(
              onPressed: _loadingEarlier
                  ? null
                  : () => _loadHistory(earlier: true),
              child: Text(_loadingEarlier ? '加载中...' : '加载更早消息'),
            ),
          );
        }
        final messageIndex = index - (_hasMore ? 1 : 0);
        final message = _messages[messageIndex];
        return _MessageBubble(
          message: message,
          typing: message.role == 'assistant' && message.content.isEmpty,
        );
      },
    );
  }
}

class _CompanionHeader extends StatelessWidget {
  const _CompanionHeader({
    required this.name,
    this.avatar,
    this.modelVisible = false,
    this.onToggleModel,
  });

  final String name;
  final String? avatar;

  /// 3D 模型面板当前是否展示；null 回调表示无可用模型（不显示按钮）
  final bool modelVisible;
  final VoidCallback? onToggleModel;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        CharacterAvatar(avatar: avatar, size: 40, previewable: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              const Text('在线 · 正在等你', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        if (onToggleModel != null)
          IconButton(
            onPressed: onToggleModel,
            tooltip: modelVisible ? '收起 3D 模型' : '展示 3D 模型',
            icon: Icon(
              modelVisible ? Icons.view_in_ar : Icons.view_in_ar_outlined,
            ),
          ),
        const Icon(Icons.more_horiz),
      ],
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.typing = false});
  final ChatMessage message;
  final bool typing;
  @override
  Widget build(BuildContext context) => Align(
    alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: message.isMine
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        typing ? '正在输入…' : message.content,
        style: TextStyle(
          color: message.isMine
              ? Theme.of(context).colorScheme.onPrimary
              : typing
              ? Theme.of(context).colorScheme.outline
              : null,
          height: 1.35,
        ),
      ),
    ),
  );
}

/// 悬浮 3D 模型面板：顶部横条拖动移位，右下角手柄拖动缩放，
/// 中间区域交给 ModelViewer 旋转/缩放模型。
class _FloatingModelPanel extends StatefulWidget {
  const _FloatingModelPanel({required this.src, required this.onClose});

  final String src;
  final VoidCallback onClose;

  @override
  State<_FloatingModelPanel> createState() => _FloatingModelPanelState();
}

class _FloatingModelPanelState extends State<_FloatingModelPanel> {
  Offset _offset = const Offset(24, 90);
  Size _size = const Size(220, 300);

  static const _minSize = 140.0;

  @override
  Widget build(BuildContext context) {
    final bounds = MediaQuery.sizeOf(context);
    final maxW = bounds.width - 32;
    final maxH = bounds.height - 160;
    return Positioned(
      left: _offset.dx.clamp(0, bounds.width - _size.width),
      top: _offset.dy.clamp(0, bounds.height - _size.height),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: _size.width,
          height: _size.height,
          child: Column(
            children: [
              // 拖动横条
              GestureDetector(
                onPanUpdate: (d) => setState(() => _offset += d.delta),
                child: Container(
                  height: 34,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.open_with, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '3D 模型',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.close, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 模型区域：手势交给 ModelViewer 旋转缩放
              Expanded(
                child: Stack(
                  children: [
                    ModelViewer(
                      src: widget.src,
                      alt: '3D 模型',
                      autoRotate: true,
                      cameraControls: true,
                      disableZoom: false,
                      backgroundColor: const Color(0x00000000),
                    ),
                    // 右下角缩放手柄
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (d) => setState(() {
                          _size = Size(
                            (_size.width + d.delta.dx).clamp(_minSize, maxW),
                            (_size.height + d.delta.dy).clamp(_minSize, maxH),
                          );
                        }),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.unfold_more,
                            size: 18,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
