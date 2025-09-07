import 'package:flutter/material.dart';

class Company {
  final String name;
  final String date;
  final String location;
  final String status;

  Company({
    required this.name,
    required this.date,
    required this.location,
    required this.status,
  });
}

class DanhSachCongViecScreen extends StatefulWidget {
  const DanhSachCongViecScreen({super.key});

  @override
  State<DanhSachCongViecScreen> createState() => _DanhSachCongViecScreenState();
}

class _DanhSachCongViecScreenState extends State<DanhSachCongViecScreen> {
  String selectedStatus = 'Tất cả';
  String query = '';
  bool showSearch = false;

  // dữ liệu mẫu (sau này thay bằng API Odoo)
  final List<Company> companies = [
    Company(name: 'Đồng Hải Lượng', date: '01/09/2025', location: 'TP.HCM', status: 'Đang làm'),
    Company(name: 'Viet so', date: '01/09/2025', location: 'Đồng Nai', status: 'Tạm hoãn'),
    Company(name: 'pv gaz', date: '01/09/2025', location: 'Long An', status: 'Tạm hoãn'),
    Company(name: 'Công ty sản xuất A', date: '01/09/2025', location: 'TP.HCM', status: 'Đang làm'),
    Company(name: 'công ty dịch vụ B', date: '01/09/2025', location: 'Bình Dương', status: 'Hoàn thành'),
    Company(name: 'Công ty 6', date: '02/09/2025', location: 'Bình Phước', status: 'Đang làm'),
    Company(name: 'Công ty 7', date: '03/09/2025', location: 'TP.HCM', status: 'Hoàn thành'),
    Company(name: 'Công ty 8', date: '03/09/2025', location: 'Đồng Nai', status: 'Tạm hoãn'),
    Company(name: 'Công ty 9', date: '04/09/2025', location: 'Long An', status: 'Đang làm'),
    Company(name: 'Công ty 10', date: '05/09/2025', location: 'Bình Dương', status: 'Hoàn thành'),
  ];

  final List<String> statuses = const ['Tất cả', 'Đang làm', 'Tạm hoãn', 'Hoàn thành'];

  @override
  Widget build(BuildContext context) {
    final filtered = companies.where((c) {
      final byStatus = selectedStatus == 'Tất cả' || c.status == selectedStatus;
      final q = query.trim().toLowerCase();
      final byQuery = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q) ||
          c.date.toLowerCase().contains(q);
      return byStatus && byQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm',
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => showSearch = !showSearch),
          ),
        ],
      ),
      body: Column(
        children: [
          if (showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, ngày, địa chỉ...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
          // dải lọc trạng thái
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = statuses[i];
                final selected = s == selectedStatus;
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedStatus = s),
                  selectedColor: Colors.blue.shade600,
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                );
              },
            ),
          ),

          // Header các cột
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFEFF6F0),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text('Tên Cty', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Ngày QT', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Địa chỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // Danh sách
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = filtered[i];
                return InkWell(
                  onTap: () {
                    // 👉 sau này mở màn "Biên bản quan trắc môi trường"
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mở biên bản của: ${c.name}')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text(c.name)),
                        Expanded(flex: 3, child: Text(c.date)),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Flexible(child: Text(c.location, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusColor(c.status).withOpacity(.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _statusColor(c.status)),
                              ),
                              child: Text(
                                c.status,
                                style: TextStyle(
                                  color: _statusColor(c.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Đang làm':
        return Colors.grey.shade700;
      case 'Tạm hoãn':
        return Colors.orange;
      case 'Hoàn thành':
        return Colors.blue;
      default:
        return Colors.black54;
    }
  }
}
