import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';

class AlertDetailScreen extends StatelessWidget {
  final String id;

  const AlertDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.map_outlined, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'انقطاع تيار كهربائي',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: AppTheme.darkText,
                        ),
                      ),
                      _buildCredibilityBadge(92),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'منذ 10 دقائق',
                        style: TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 13),
                      ),
                      SizedBox(width: 24),
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'تفرغ زينة، قطاع 4',
                        style: TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppTheme.darkText,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'انقطع التيار الكهربائي عن الحي بأكمله منذ الساعة 9:00 مساءً. قمنا بالتواصل مع الشركة ولم يتم الرد حتى الآن. نرجو الحذر.',
                    style: TextStyle(
                      color: Colors.black87,
                      height: 1.6,
                      fontFamily: 'Cairo',
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'الصور المرفقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppTheme.darkText,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        width: 160,
                        margin: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: NetworkImage('https://picsum.photos/400/300'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'تأكيدات المجتمع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppTheme.darkText,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '92 شخصاً أكدوا البلاغ',
                        style: TextStyle(color: Colors.green, fontSize: 13, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '8 أشخاص قالوا إنه خاطئ',
                        style: TextStyle(color: Colors.red, fontSize: 13, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'بلاغ خاطئ',
                          backgroundColor: Colors.white,
                          onPressed: () {},
                          // Border and text color for secondary button
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: 'تأكيد البلاغ',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredibilityBadge(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '%$score موثوق',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          fontSize: 14,
        ),
      ),
    );
  }
}

