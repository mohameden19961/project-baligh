import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primaryGreen,
                  child: CircleAvatar(
                    radius: 57,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=abdy'),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 20, color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const AppTextField(
              label: 'الاسم الكامل',
              hint: 'عبد الهادي الحسيني',
            ),
            const SizedBox(height: 20),
            const AppTextField(
              label: 'رقم الهاتف',
              hint: '+222 47 00 00 00',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const AppTextField(
              label: 'البريد الإلكتروني',
              hint: 'abdy@mail.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 48),
            AppButton(
              text: 'حفظ التغييرات',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

