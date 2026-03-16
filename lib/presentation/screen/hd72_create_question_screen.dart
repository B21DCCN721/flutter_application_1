import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/hd72_create_question.dart';
import 'package:flutter_application_1/service/hd72_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/utils/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/constants/env.dart';

class Hd72CreateQuestionScreen extends StatefulWidget {
  final Hd72CreateQuestionArg? arg;
  const Hd72CreateQuestionScreen({super.key, this.arg});

  @override
  State<Hd72CreateQuestionScreen> createState() =>
      _Hd72CreateQuestionScreenState();
}

class _Hd72CreateQuestionScreenState extends State<Hd72CreateQuestionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCourseId;
  List<dynamic> _courses = [];
  bool _isSubmitting = false;
  bool _isPickingFile = false;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    if (widget.arg?.courseId != null) {
      _selectedCourseId = widget.arg!.courseId;
    }
    _fetchCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _fetchCourses() async {
    try {
      final res = await Hd72Api.countByCourse();
      if (res['courses'] != null) {
        setState(() {
          _courses = List<dynamic>.from(res['courses']);

          if (_selectedCourseId != null) {
            bool exists =
                _courses.any((c) => c['id'].toString() == _selectedCourseId);

            // Nếu không có ID 6 trong list, ta thêm một item "ảo" để không bị crash
            if (!exists) {
              _courses.add({
                'id': _selectedCourseId,
                'fullname': "Học phần hiện tại (ID: $_selectedCourseId)",
              });
            }
          }
        });
      }
    } catch (e) {
      logger("Hd72CreateQuestionScreen: _fetchCourses Error: $e");
    }
  }

  void _submit() async {
    if (_selectedCourseId == null) {
      Toast.show("Vui lòng chọn học phần");
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      Toast.show("Vui lòng nhập tiêu đề");
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      Toast.show("Vui lòng nhập nội dung");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final token = await LocalStorage.getString(Env.token);
      final res = await Hd72Api.addDiscussion(
        token: token,
        courseId: int.parse(_selectedCourseId!),
        subject: _titleController.text.trim(),
        message: _contentController.text.trim(),
        filePath: _selectedFile?.path ?? "",
        fileName: _selectedFile?.name ?? "",
        threadId: widget.arg?.threadId ?? "",
      );

      if (res) {
        Toast.show("Gửi câu hỏi thành công");
        Navigator.pop(context);
      }
    } catch (e) {
      logger("Hd72CreateQuestionScreen: _submit Error: $e");
      Toast.show("Gửi câu hỏi thất bại");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _pickFile({bool isImage = false}) async {
    setState(() => _isPickingFile = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: isImage ? FileType.image : FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      logger("Hd72CreateQuestionScreen: _pickFile Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: Text(
          widget.arg?.threadId != null ? "Viết câu hỏi tiếp" : "Đặt câu hỏi HD72",
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: (_isSubmitting || _isPickingFile) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D2D6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Đặt câu hỏi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseDropdown(),
            Gaps.vGap24,
            _buildTitleInput(),
            Gaps.vGap24,
            _buildContentInput(),
            Gaps.vGap24,
            _buildAttachmentButtons(),
            if (_selectedFile != null) ...[
              Gaps.vGap16,
              _buildFilePreview(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _courses.any((c) => c['id']?.toString() == _selectedCourseId)
              ? _selectedCourseId
              : null,
          hint: const Text("Học phần", style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          items: _courses.map((course) {
            return DropdownMenuItem<String>(
              value: course['id']?.toString(),
              child: Text(
                course['fullname'] ?? "",
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCourseId = val),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _titleController,
          maxLength: 255,
          decoration: const InputDecoration(
            hintText: "Nhập tiêu đề câu hỏi",
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
            counterText: "", // Hide default counter
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Gaps.vGap4,
        ValueListenableBuilder(
          valueListenable: _titleController,
          builder: (context, value, _) {
            return Text(
              "${value.text.length}/255",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      maxLines: null,
      minLines: 3,
      decoration: const InputDecoration(
        hintText: "Nhập nội dung",
        hintStyle: TextStyle(color: Colors.grey),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }

  Widget _buildAttachmentButtons() {
    return Row(
      children: [
        _buildMediaButton(
          Icons.image_outlined,
          "Thêm ảnh",
          onTap: () => _pickFile(isImage: true),
        ),
        Gaps.hGap12,
        _buildMediaButton(
          Icons.attach_file,
          "Thêm tệp",
          onTap: () => _pickFile(isImage: false),
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grayBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: AppColors.primary),
          Gaps.hGap12,
          Expanded(
            child: Text(
              _selectedFile!.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.red),
            onPressed: () => setState(() => _selectedFile = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            Gaps.hGap8,
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
