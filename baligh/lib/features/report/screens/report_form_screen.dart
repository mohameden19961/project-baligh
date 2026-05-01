import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'electricity', 'label': 'كهرباء', 'icon': Icons.bolt, 'color': Colors.amber},
    {'id': 'road', 'label': 'طرق', 'icon': Icons.directions_car, 'color': Colors.red},
    {'id': 'flood', 'label': 'مياه', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'id': 'security', 'label': 'أمن', 'icon': Icons.security, 'color': Colors.indigo},
    {'id': 'health', 'label': 'صحة', 'icon': Icons.health_and_safety, 'color': Colors.green},
    {'id': 'internet', 'label': 'إنترنت', 'icon': Icons.wifi, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'تقديم بلاغ جديد',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          textDirection: TextDirection.rtl,
          children: [
            const Text(
              'عن ماذا تريد التبليغ؟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: AppTheme.darkText,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['id'];
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat['id']),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryGreen : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryGreen : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat['icon'],
                          color: isSelected ? Colors.white : cat['color'],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.darkText,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'تفاصيل البلاغ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: AppTheme.darkText,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            const AppTextField(
              label: '',
              hint: 'صف المشكلة بالتفصيل هنا...',
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!, width: 2, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 48, color: AppTheme.primaryGreen),
                    SizedBox(height: 8),
                    Text(
                      'أضف صورة توضيحية',
                      style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.location_on, color: AppTheme.accentGold),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تحديد الموقع على الخريطة',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Icon(Icons.chevron_left, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'إرسال البلاغ',
              onPressed: () {
                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'يرجى اختيار فئة البلاغ',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                _showSuccessDialog(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'تم إرسال بلاغك بنجاح',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'شكراً لمساهمتك في تحسين مدينتنا. سيقوم فريقنا بمراجعة البلاغ قريباً.',
              style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'العودة للرئيسية',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

