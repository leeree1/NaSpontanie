import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _client = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _profileFuture;

  static const _fallbackName = 'Alexandra';
  static const _fallbackCreatedAt = '15.01.2026';

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      return await _client
          .from('profiles')
          .select('display_name, avatar_url, total_xp, created_at, updated_at')
          .eq('id', user.id)
          .maybeSingle();
    } catch (e) {
      debugPrint('Błąd pobierania profilu: $e');
      return null;
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return _fallbackCreatedAt;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return _fallbackCreatedAt;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day.$month.${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;
    final app = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil Odkrywcy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = (profile?['display_name'] as String?)?.trim();
          final displayName = (name != null && name.isNotEmpty)
              ? name
              : (user?.userMetadata?['display_name'] ?? _fallbackName);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Karta Główna Tożsamości
                _buildIdentityCard(
                  displayName: displayName,
                  email: user?.email ?? 'aleksandra@example.com',
                  rankTitle: app.rankTitle,
                ),
                const SizedBox(height: 20),

                // Pasek Postępu Poziomu
                _buildLevelProgressCard(app),
                const SizedBox(height: 20),

                // Kafelki Statystyk (Grid 2x2)
                _buildStatGrid(app),
                const SizedBox(height: 24),

                // Gablota Osiągnięć i Odznak
                _buildBadgesSection(),
                const SizedBox(height: 24),

                // Informacje o Koncie i Akcje
                _buildAccountDetails(
                  createdAt: _formatDate(profile?['created_at']),
                ),
                const SizedBox(height: 24),

                // Przycisk Wylogowania
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Wylogować się?'),
                        content: const Text(
                          'Twój stan gry i pieczątki są bezpiecznie zapisane na Twoim koncie.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Anuluj'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Wyloguj'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _client.auth.signOut();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Wyloguj się z konta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    backgroundColor: const Color(0xFFFFF5F5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdentityCard({
    required String displayName,
    required String email,
    required String rankTitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rankTitle,
                    style: const TextStyle(
                      color: AppColors.primaryMid,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard(AppProvider app) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'POZIOM ${app.currentLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.bolt, color: AppColors.xpGold, size: 18),
                  Text(
                    '${app.userXp} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${(app.levelProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: app.levelProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Zdobądź jeszcze ${500 - app.xpInCurrentLevel} XP, aby awansować na Poziom ${app.currentLevel + 1}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(AppProvider app) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Stemple',
            value: '${app.unlockedLocationIds.length}',
            subtitle: 'odkryte punkty',
            icon: Icons.verified_rounded,
            accentColor: const Color(0xFF1E88E5),
            softBg: const Color(0xFFE3F2FD),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Seria dni',
            value: '${app.streakDays}',
            subtitle: 'dni z rzędu',
            icon: Icons.local_fire_department_rounded,
            accentColor: AppColors.fireOrange,
            softBg: const Color(0xFFFFEBE6),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(
            title: 'Trasy',
            value: '4',
            subtitle: 'ukończone',
            icon: Icons.map_outlined,
            accentColor: AppColors.primaryMid,
            softBg: AppColors.accentSoft,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {
        'title': 'Wrocławiak',
        'desc': 'Start w grze',
        'icon': Icons.location_city_rounded,
        'unlocked': true,
      },
      {
        'title': 'Krasnal',
        'desc': '3 punkty',
        'icon': Icons.emoji_people_rounded,
        'unlocked': true,
      },
      {
        'title': 'Mostowiec',
        'desc': 'Trasa nad Odrą',
        'icon': Icons.waves_rounded,
        'unlocked': true,
      },
      {
        'title': 'Nocny Marek',
        'desc': 'Spacer po 21:00',
        'icon': Icons.bedtime_rounded,
        'unlocked': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gablota Odznak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '3 / ${badges.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMid,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: badges.map((badge) {
              final isUnlocked = badge['unlocked'] as bool;
              return Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked
                          ? AppColors.xpGoldSoft
                          : AppColors.background,
                      border: Border.all(
                        color: isUnlocked
                            ? AppColors.xpGold
                            : AppColors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      badge['icon'] as IconData,
                      color: isUnlocked ? AppColors.xpGold : Colors.grey.shade400,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge['title'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? AppColors.textDark
                          : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    badge['desc'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: isUnlocked
                          ? AppColors.textMuted
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails({required String createdAt}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Miasto eksploracji',
            value: 'Wrocław, Dolny Śląsk',
          ),
          const Divider(height: 16, color: AppColors.cardBorder),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Konto aktywne od',
            value: createdAt,
          ),
          const Divider(height: 16, color: AppColors.cardBorder),
          _buildDetailRow(
            icon: Icons.shield_outlined,
            label: 'Status konta',
            value: 'Zweryfikowany Odkrywca',
            valueColor: AppColors.primaryMid,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.softBg,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color softBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}