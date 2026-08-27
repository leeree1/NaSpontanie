import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _client = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final result = await _client
        .from('profiles')
        .select('display_name, avatar_url, total_xp, created_at, updated_at')
        .eq('id', user.id)
        .maybeSingle();
    return result;
  }

  Future<void> _signOut() async {
    await _client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Nie udało się pobrać profilu.'));
          }
          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Profil nie istnieje.'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.person, size: 72),
              const SizedBox(height: 24),
              _ProfileRow(
                label: 'Nazwa',
                value: profile['display_name'] as String? ?? '',
              ),
              _ProfileRow(label: 'Email', value: user.email ?? ''),
              _ProfileRow(
                label: 'Punkty XP',
                value: '${profile['total_xp'] ?? 0}',
              ),
              _ProfileRow(
                label: 'Utworzono',
                value: '${profile['created_at'] ?? ''}',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Wyloguj się'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
