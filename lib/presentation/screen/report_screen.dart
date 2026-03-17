import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/service/report_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File?> _selectedImages = [null, null, null];
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source, int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImages[index] = File(image.path);
        });
      }
    } catch (e) {
      Toast.show("Không thể chọn ảnh: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages[index] = null;
    });
  }

  Future<void> _submitFeedback() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      Toast.show("Vui lòng nhập nội dung góp ý");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await LocalStorage.getString(Env.token);
      final res = await ReportAPI.submitFeedback(
        token: token,
        content: content,
        file1: _selectedImages[0]?.path ?? "",
        file2: _selectedImages[1]?.path ?? "",
        file3: _selectedImages[2]?.path ?? "",
      );

      if (res) {
        Toast.show("Gửi góp ý thành công!");
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      Toast.show("Đã có lỗi xảy ra: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _showImagePicker(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Gaps.vGap24,
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: "Chụp ảnh",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, index);
                  },
                ),
                Gaps.vGap12,
                const Divider(color: AppColors.border),
                Gaps.vGap12,
                _buildPickerOption(
                  icon: Icons.image,
                  label: "Chọn ảnh có sẵn",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            Gaps.hGap16,
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedImages.length < 3) {
      _selectedImages = [null, null, null];
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Góp ý - báo lỗi hệ thống",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nội dung góp ý",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                  Gaps.vGap8,
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: "Nhập nội dung",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  Gaps.vGap24,
                  const Text(
                    "Ảnh đính kèm",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                  Gaps.vGap8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildImageSlot(0),
                      _buildImageSlot(1),
                      _buildImageSlot(2),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Gửi góp ý",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlot(int index) {
    final file = _selectedImages[index];
    if (file != null) {
      return Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              image: DecorationImage(
                image: FileImage(file),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _showImagePicker(context, index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.add_photo_alternate_rounded,
          color: Colors.black54,
          size: 32,
        ),
      ),
    );
  }
}
