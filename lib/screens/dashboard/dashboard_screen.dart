import 'package:flutter/material.dart';
import '../danh_sach_cong_viec_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.work, 'label': 'BB QTMTLĐ'},
      {'icon': Icons.water, 'label': 'Mẫu nước'},
      {'icon': Icons.wb_cloudy, 'label': 'Mẫu khí'},
      {'icon': Icons.paid, 'label': 'Chi phí'},
      {'icon': Icons.file_copy, 'label': 'Hồ sơ'},
      {'icon': Icons.bar_chart, 'label': 'Báo cáo'},
      {'icon': Icons.chat, 'label': 'Tin nhắn'},
      {'icon': Icons.home, 'label': 'Trang chủ'},
      {'icon': Icons.logout, 'label': 'Logout'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('SGCO Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isLogout = item['label'] == 'Logout';

            return GestureDetector(
              onTap: () {
                if (item['label'] == 'BB QTMTLĐ') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DanhSachCongViecScreen()),
                  );
                } else if (isLogout) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text('Bạn có muốn thoát khỏi tài khoản không?'),
                      actions: [
                        TextButton(
                          child: const Text('No'),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            Navigator.pop(ctx); // đóng popup
                            Navigator.pop(context); // quay về ngoài (nếu có)
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Icon(item['icon'] as IconData, size: 36, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
