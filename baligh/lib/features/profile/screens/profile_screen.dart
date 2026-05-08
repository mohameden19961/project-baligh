import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 32),
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=abdy'),
                        ),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.accentGold,
                        child: Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'عبدي محمدن',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'مساهم موثوق',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      _buildStatItem('بلاغات', '24'),
                      _buildStatItem('تأكيدات', '152'),
                      _buildStatItem('نقاط', '450'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    label: 'تعديل الملف الشخصي',
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    label: 'تاريخ بلاغاتي',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_none,
                    label: 'إعدادات التنبيهات',
                    onTap: () => context.push('/settings'),
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    label: 'مركز المساعدة',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildProfileOption(
                    icon: Icons.logout,
                    label: 'تسجيل الخروج',
                    color: Colors.red,
                    onTap: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Icon(icon, color: color ?? AppTheme.primaryGreen),
          title: Text(
            label,
            style: TextStyle(
              color: color ?? AppTheme.darkText,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
        ),
      ),

    );
  }
}

