import 'package:flutter/material.dart';

import 'character_edit_page.dart';
import 'chat_page.dart';
import 'companion_pages.dart';
import '../models/companion_character.dart';
import '../services/character_service.dart';
import '../services/session_service.dart';
import 'profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _titles = ['聊天', '羁绊', '记忆', '通知'];
  static const _actionCreate = 'create';
  static const _actionEdit = 'edit';

  int _index = 0;
  final _characters = CharacterService();
  List<CompanionCharacter> _availableCharacters = const [];
  CompanionCharacter? _selectedCharacter;
  bool _loadingCharacters = true;
  Object? _characterError;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() {
      _loadingCharacters = true;
      _characterError = null;
    });
    try {
      final characters = await _characters.listEnabled();
      if (!mounted) return;
      setState(() {
        _availableCharacters = characters;
        final selected = _selectedCharacter;
        _selectedCharacter = characters.isEmpty
            ? null
            : characters.firstWhere(
                (c) => c.id == selected?.id,
                orElse: () => characters.first,
              );
      });
    } catch (error) {
      if (mounted) setState(() => _characterError = error);
    } finally {
      if (mounted) setState(() => _loadingCharacters = false);
    }
  }

  /// 打开新建/编辑角色页，保存后刷新列表
  Future<void> _openCharacterEditor([CompanionCharacter? character]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CharacterEditPage(character: character),
      ),
    );
    if (changed == true && mounted) await _loadCharacters();
  }

  void _onCharacterMenuSelected(Object value) {
    if (value is CompanionCharacter) {
      setState(() => _selectedCharacter = value);
    } else if (value == _actionCreate) {
      _openCharacterEditor();
    } else if (value == _actionEdit) {
      _openCharacterEditor(_selectedCharacter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final character = _selectedCharacter;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: '我的资料',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          PopupMenuButton<Object>(
            tooltip: '角色菜单',
            initialValue: character,
            onSelected: _onCharacterMenuSelected,
            itemBuilder: (context) => [
              ..._availableCharacters.map(
                (item) => PopupMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      if (item.id == character?.id)
                        const Icon(Icons.check, size: 18)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.name)),
                    ],
                  ),
                ),
              ),
              if (_availableCharacters.isNotEmpty) const PopupMenuDivider(),
              if (character != null)
                const PopupMenuItem(
                  value: _actionEdit,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('编辑当前角色'),
                  ),
                ),
              const PopupMenuItem(
                value: _actionCreate,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.person_add_alt),
                  title: Text('新建角色'),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(character?.name ?? '角色'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: '退出登录',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => session.signOut(),
          ),
        ],
      ),
      body: _buildBody(character),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '聊天',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: '羁绊',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: '记忆',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: '通知',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CompanionCharacter? character) {
    if (_loadingCharacters)
      return const Center(child: CircularProgressIndicator());
    if (_characterError != null) {
      return Center(
        child: TextButton(
          onPressed: _loadCharacters,
          child: const Text('角色加载失败，点击重试'),
        ),
      );
    }
    if (character == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('还没有自己的虚拟朋友，先创建一个吧。', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _openCharacterEditor,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('创建角色'),
              ),
            ],
          ),
        ),
      );
    }
    final pages = [
      ChatPage(
        key: ValueKey(character.id),
        characterId: character.id,
        characterName: character.name,
        characterAvatar: character.avatar,
        characterModel: character.modelUrl,
      ),
      RelationshipPage(
        characterId: character.id,
        characterName: character.name,
      ),
      MemoryPage(key: ValueKey(character.id), characterId: character.id),
      const NotificationPage(),
    ];
    return IndexedStack(index: _index, children: pages);
  }
}
