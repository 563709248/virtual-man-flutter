import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../services/session_service.dart';
import 'membership_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _service = const ProfileService();
  final _nickname = TextEditingController();
  final _interest = TextEditingController();
  final _avatar = TextEditingController();
  DateTime? _birthday;
  int? _gender;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nickname.dispose();
    _interest.dispose();
    _avatar.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await _service.getProfile();
      _applyProfile(profile);
    } catch (_) {
      _nickname.text = session.username ?? '';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyProfile(UserProfile profile) {
    _nickname.text = profile.nickname;
    _avatar.text = profile.avatar ?? '';
    _interest.text = profile.interest ?? '';
    _birthday = profile.birthday;
    _gender = profile.gender;
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _birthday = picked);
  }

  Future<void> _save() async {
    final nickname = _nickname.text.trim();
    if (nickname.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final profile = await _service.saveProfile(
        nickname: nickname,
        avatar: _avatar.text.trim(),
        birthday: _birthday,
        gender: _gender,
        interest: _interest.text.trim(),
      );
      if (!mounted) return;
      _applyProfile(profile);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('资料已保存')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _birthdayLabel {
    if (_birthday == null) return '选择生日';
    return '${_birthday!.year.toString().padLeft(4, '0')}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('我的资料')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundImage: _avatar.text.isNotEmpty
                  ? NetworkImage(_avatar.text)
                  : null,
              child: _avatar.text.isEmpty
                  ? const Icon(Icons.person, size: 36)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _avatar,
            decoration: const InputDecoration(
              labelText: '头像链接',
              hintText: 'https://...',
            ),
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nickname,
            maxLength: 50,
            decoration: const InputDecoration(labelText: '昵称'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('生日'),
            subtitle: Text(_birthdayLabel),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickBirthday,
          ),
          DropdownButtonFormField<int>(
            initialValue: _gender,
            decoration: const InputDecoration(labelText: '性别'),
            items: const [
              DropdownMenuItem(value: 0, child: Text('保密')),
              DropdownMenuItem(value: 1, child: Text('男')),
              DropdownMenuItem(value: 2, child: Text('女')),
            ],
            onChanged: (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _interest,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '兴趣爱好'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中...' : '保存'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('会员中心'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MembershipPage())),
          ),
        ],
      ),
    );
  }
}
