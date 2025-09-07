import 'dart:io';
import 'package:flutter/material.dart';
import '../cascading_dropdowns.dart';
import 'package:camera/camera.dart';

class JobDetailScreen extends StatefulWidget {
  final String companyName;
  final String location;
  final String date;

  const JobDetailScreen({
    super.key,
    required this.companyName,
    required this.location,
    required this.date,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  XFile? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Tên Cty', widget.companyName),
              _infoRow('Địa chỉ', widget.location),
              _infoRow('Ngày quan trắc', widget.date),

              const SizedBox(height: 12),
              // Dropdown 3 cấp – nhớ dự án đã init Firebase
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CascadingDropdowns(
                    saveDocPath: 'bb_qtmtld/${DateTime.now().millisecondsSinceEpoch}',
                    outerPadding: 0.0, // widget của bạn đang nhận double
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildEntryCard('I. XƯỞNG ỐNG THẲNG'),
              const SizedBox(height: 16),
              _buildEntryCard('II. KHU VỰC CHÍNH'),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã lưu nháp')),
                      );
                      // TODO: lưu Firestore từng card nếu cần
                    },
                    child: const Text('LƯU NHÁP'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã hoàn thành')),
                      );
                      // TODO: lưu Firestore + đánh dấu hoàn thành
                    },
                    child: const Text('HOÀN THÀNH'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $value', style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildEntryCard(String title) {
    final fields = <String>[
      'Ánh sáng (lux)',
      'Nhiệt độ (°C)',
      'Độ ẩm (%)',
      'Vận tốc gió (m/s)',
      'Bức xạ nhiệt',
      'Tiếng ồn chung (dBA)',
      'Ồn giải tán',
      'Điện trường G',
      'Rung',
      'Bụi toàn phần',
      'Khí O₂',
      'Khí CO',
      'Khí CO₂',
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            for (final label in fields) ...[
              _buildTextInput(label),
              const Divider(),
            ],
            Row(
              children: [
                const Text('Ảnh OWAS:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _takePicture,
                  child: const Text('Chụp ảnh 📸'),
                ),
                const SizedBox(width: 12),
                if (_imageFile != null)
                  Image.file(
                    File(_imageFile!.path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(String label) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _takePicture() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy camera')),
        );
        return;
      }
      final cam = cameras.first;
      final img = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(builder: (_) => TakePictureScreen(camera: cam)),
      );
      if (img != null) {
        setState(() => _imageFile = img);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi camera: $e')),
      );
    }
  }
}

// Màn hình chụp ảnh đơn giản
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({super.key, required this.camera});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late final CameraController _controller;
  late final Future<void> _initialized;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initialized = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chụp ảnh OWAS')),
      body: FutureBuilder<void>(
        future: _initialized,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await _controller.takePicture();
          if (!mounted) return;
          Navigator.pop(context, image);
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
