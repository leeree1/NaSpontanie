import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _client = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _profileFuture;

  static const _fallbackName = 'Odkrywca';
  static const _fallbackXp = 1250;
  static const _fallbackCreatedAt = '15.01.2026';

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _client
        .from('profiles')
        .select('display_name, avatar_url, total_xp, created_at, updated_at')
        .eq('id', user.id)
        .maybeSingle();
  }

  String _formatDate(dynamic value) {
    if (value == null) return _fallbackCreatedAt;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return _fallbackCreatedAt;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day.$month.${parsed.year}';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;

    return Scaffold(
      appBar: const AppHeader(title: 'Profil'),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = (profile?['display_name'] as String?)?.trim();
          final displayName =
              (name != null && name.isNotEmpty) ? name : _fallbackName;
          final xp = profile?['total_xp'] is num
              ? (profile!['total_xp'] as num).toInt()
              : _fallbackXp;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, size: 52, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(child: XpBadge(xp: xp, chip: true)),
              const SizedBox(height: 28),
              _row('Nazwa', displayName),
              _row('Email', user?.email ?? 'testowy@gmail.com'),
              _row('Punkty XP', '$xp'),
              _row('Poziom', '4'),
              _row('Miasto', 'Wrocław'),
              _row('Pieczątki', '2 / 6'),
              _row('Ukończone wyprawy', '3'),
              _row('Utworzono', _formatDate(profile?['created_at'])),
              const SizedBox(height: 32),
              AppButton(
                label: 'Wyloguj się',
                icon: Icons.logout,
                onPressed: () => _client.auth.signOut(),
              ),
            ],
          );
        },
      ),
    );
  }
}
