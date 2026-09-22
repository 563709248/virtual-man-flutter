import 'package:flutter/material.dart';

import '../models/boyfriend_preset.dart';
import '../models/companion_character.dart';
import '../services/character_service.dart';
import '../widgets/character_avatar.dart';

/// 新建或编辑当前用户的虚拟朋友角色。
/// 后端按登录态归属 userId，列表只返回启用状态的角色。
class CharacterEditPage extends StatefulWidget {
  const CharacterEditPage({super.key, this.character});

  /// 传入表示编辑，否则为新建
  final CompanionCharacter? character;

  @override
  State<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final _service = const CharacterService();
  late final TextEditingController _name;
  late final TextEditingController _personality;
  late final TextEditingController _background;
  late final TextEditingController _promptTemplate;
  late final TextEditingController _avatar;
  late final TextEditingController _voiceId;
  late final TextEditingController _modelUrl;
  bool _saving = false;
  bool _toggling = false;

  bool get _isEdit => widget.character != null;

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _name = TextEditingController(text: c?.name ?? '');
    _personality = TextEditingController(text: c?.personality ?? '');
    _background = TextEditingController(text: c?.background ?? '');
    _promptTemplate = TextEditingController(text: c?.promptTemplate ?? '');
    _avatar = TextEditingController(text: c?.avatar ?? '');
    _voiceId = TextEditingController(text: c?.voiceId ?? '');
    _modelUrl = TextEditingController(text: c?.modelUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _personality.dispose();
    _background.dispose();
    _promptTemplate.dispose();
    _avatar.dispose();
    _voiceId.dispose();
    _modelUrl.dispose();
    super.dispose();
  }

  /// 选中预设男友后填充表单，仍可继续编辑
  void _applyPreset(BoyfriendPreset preset) {
    setState(() {
      _name.text = preset.name;
      _avatar.text = preset.avatar;
      _personality.text = preset.personality;
      _background.text = preset.background;
      _promptTemplate.text = preset.promptTemplate;
      _voiceId.text = preset.voiceId ?? '';
      _modelUrl.text = preset.modelUrl ?? '';
    });
  }

  CharacterPayload _payload() => CharacterPayload(
    name: _name.text.trim(),
    avatar: _avatar.text.trim(),
    personality: _personality.text.trim(),
    background: _background.text.trim(),
    promptTemplate: _promptTemplate.text.trim(),
    voiceId: _voiceId.text.trim(),
    modelUrl: _modelUrl.text.trim(),
  );

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      _toast('角色名称不能为空');
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _service.update(widget.character!.id, _payload());
      } else {
        await _service.create(_payload());
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _toast('保存失败：$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleStatus() async {
    final character = widget.character;
    if (character == null || _toggling) return;
    final disable = character.enabled;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(disable ? '停用角色' : '启用角色'),
        content: Text(disable ? '停用后该角色将从列表隐藏，历史聊天保留。' : '启用后该角色恢复可聊天状态。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _toggling = true);
    try {
      await _service.updateStatus(character.id, disable ? 0 : 1);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _toast('操作失败：$error');
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑角色' : '新建角色'),
        actions: [
          if (_isEdit)
            TextButton(
              onPressed: _toggling ? null : _toggleStatus,
              child: Text(widget.character!.enabled ? '停用' : '启用'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('选择预设男友', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BoyfriendPreset.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final preset = BoyfriendPreset.all[index];
                final selected = _avatar.text == preset.avatar;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _applyPreset(preset),
                  child: Container(
                    width: 92,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: selected ? 2 : 1,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                    child: Column(
                      children: [
                        CharacterAvatar(
                          avatar: preset.avatar,
                          size: 52,
                          previewable: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          preset.tagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            maxLength: 30,
            decoration: const InputDecoration(labelText: '角色名称 *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _personality,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '性格设定',
              hintText: '例如：温柔体贴、有点小脾气、喜欢开玩笑',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _background,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '背景故事',
              hintText: '角色的身世、你们的关系等',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptTemplate,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '补充设定（Prompt）',
              hintText: '对模型回复风格的额外要求',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _avatar,
            decoration: InputDecoration(
              labelText: '头像链接',
              hintText: 'https://... 或选择上方预设',
              helperText: BoyfriendPreset.isPreset(_avatar.text)
                  ? '当前为内置预设头像'
                  : null,
              suffixIcon: _avatar.text.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: CharacterAvatar(
                        avatar: _avatar.text,
                        size: 32,
                        previewable: true,
                      ),
                    ),
            ),
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _voiceId,
            decoration: const InputDecoration(labelText: '音色 ID（可选）'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelUrl,
            decoration: const InputDecoration(
              labelText: '3D 模型链接（可选，预留）',
              hintText: 'https://... .glb',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中...' : '保存'),
          ),
        ],
      ),
    );
  }
}
