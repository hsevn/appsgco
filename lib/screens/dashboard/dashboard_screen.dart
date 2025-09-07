import 'package:flutter/material.dart';
import '../danh_sach_cong_viec_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DashboardItem>[
      _DashboardItem(
        icon: Icons.work_history,
        title: 'BB QTMT LĐ',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DanhSachCongViecScreen()),
          );
        },
      ),
      _DashboardItem(
        icon: Icons.article,
        title: 'BB QTMT',
        onTap: () => _todo(context),
      ),
      _DashboardItem(
        icon: Icons.science,
        title: 'BB PT PTN',
        onTap: () => _todo(context),
      ),
      _DashboardItem(
        icon: Icons.attach_money,
        title: 'Chi Phí',
        onTap: () => _todo(context),
      ),
      _DashboardItem(
        icon: Icons.sync,
        title: 'Hoàn Ứng',
        onTap: () => _todo(context),
      ),
      _DashboardItem(
        icon: Icons.history,
        title: 'Lịch Sử CV',
        onTap: () => _todo(context),
      ),
      _DashboardItem(
        icon: Icons.water_drop,
        title: 'Mẫu nước',
        onTap: () => _todo(context),
      ),
      _DashboardItem(
        icon: Icons.air,
        title: 'Mẫu khí',
        onTap: () => _todo(context),
      ),
      _DashboardItem(
        icon: Icons.description,
        title: 'HDSD TB',
        onTap: () => _todo(context),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nội dung công việc'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF1F7F6),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (_, i) {
            final it = items[i];
            return InkWell(
              onTap: it.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(it.icon, size: 44, color: Colors.purple),
                    const SizedBox(height: 14),
                    Text(
                      it.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // Thanh bottom đơn giản (Back, Home, Chat) – chỉ minh họa
      bottomNavigationBar: BottomAppBar(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.arrow_back, color: Colors.deepPurple),
            Icon(Icons.home_outlined),
            Icon(Icons.chat_bubble_outline),
          ],
        ),
      ),
    );
  }

  static void _todo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mục này sẽ triển khai sau')),
    );
  }
}

class _DashboardItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _DashboardItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
