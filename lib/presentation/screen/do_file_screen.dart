import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_file.dart';
import 'package:flutter_application_1/service/assign_api.dart';
import 'package:flutter_application_1/service/course_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/service/file_api.dart';
import 'package:flutter_application_1/utils/toast.dart';

class DoFileScreen extends StatefulWidget {
  final DoFileArg arg;
  const DoFileScreen({super.key, required this.arg});

  @override
  State<DoFileScreen> createState() => _DoFileScreenState();
}

class _DoFileScreenState extends State<DoFileScreen> {
  bool _isLoading = true;
  dynamic _moduleData;
  dynamic _gradeData;
  List<PlatformFile> _selectedFiles = [];
  List<int> _deleteFileIds = [];
  bool _isNotAllowed = false;
  String? _availabilityInfo;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await CourseApi.detailCourseModule(cmid: widget.arg.cmid);
      if (res['success'] == true && res['data'] != null) {
        setState(() {
          _moduleData = res['data'];
          if (res['data']['availabilityinfo'] != null &&
              res['data']['availabilityinfo'].toString().isNotEmpty) {
            _isNotAllowed = true;
            _availabilityInfo = res['data']['availabilityinfo'];
          }
        });
      }

      final res2 = await AssignApi.getGrade(assignId: widget.arg.assignId);
      if (res2 != null &&
          (res2['exception'] == "dml_missing_record_exception" ||
              res2['exception'] == "require_login_exception")) {
        setState(() {
          _isNotAllowed = true;
        });
      }

      setState(() {
        _gradeData = res2;
      });
    } catch (e) {
      logger("DoFileScreen:_fetchData Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickFiles() async {
    try {
      List<String>? allowedExtensions;
      FileType fileType = FileType.any;

      if (_gradeData != null && _gradeData['filetype'] != null && _gradeData['filetype'] is List) {
        List<dynamic> rawTypes = _gradeData['filetype'];
        if (rawTypes.isNotEmpty) {
          allowedExtensions = rawTypes
              .map((e) => e.toString().replaceAll(RegExp(r'^\.+'), '').toLowerCase().trim())
              .where((e) => e.isNotEmpty && e != '*')
              .toList();
              
          if (allowedExtensions.isNotEmpty) {
            fileType = FileType.custom;
          } else {
            allowedExtensions = null;
          }
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: fileType,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        List<PlatformFile> validFiles = [];
        List<String> invalidNames = [];

        for (var file in result.files) {
          if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
            String ext = file.extension?.toLowerCase() ?? '';
            if (ext.isEmpty || !allowedExtensions.contains(ext)) {
              invalidNames.add(file.name);
              continue;
            }
          }
          validFiles.add(file);
        }

        if (invalidNames.isNotEmpty) {
          Toast.show("Định dạng không hỗ trợ: ${invalidNames.join(', ')}");
        }

        if (validFiles.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(validFiles);
          });
        }
      }
    } catch (e) {
      logger("DoFileScreen:_pickFiles Error: $e");
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận thoát"),
        content: const Text(
            "Bạn có chắc chắn muốn thoát? Các thay đổi chưa nộp sẽ bị mất."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Thoát", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _submitFiles() async {
    if (_selectedFiles.isEmpty && _deleteFileIds.isEmpty) {
      Toast.show("Vui lòng chọn file nộp hoặc xóa file");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String token = await LocalStorage.getString(Env.token);
      
      if (_deleteFileIds.isNotEmpty) {
        int confirm = _gradeData?['lastattempt']?['graded'] ?? 0;
        for (int fileId in _deleteFileIds) {
          await AssignApi.deleteFile(fileId: fileId, confirm: confirm);
        }
      }

      if (_selectedFiles.isEmpty) {
        Toast.show("Cập nhật file thành công");
        _deleteFileIds.clear();
        await _fetchData();
        return;
      }

      var itemId = '';
      bool isAllSuccessful = true;

      for (PlatformFile file in _selectedFiles) {
        if (file.path != null) {
          var uploadResponse = await FileApi.uploadFile(
            token: token,
            filePath: file.path!,
            itemid: itemId,
          );

          if (uploadResponse != null && uploadResponse is List && uploadResponse.isNotEmpty) {
            // Lấy itemId từ lần upload file đầu tiên để dùng cho các file tiếp theo
            itemId = "${uploadResponse[0]['itemid']}";
          } else {
            // Thông báo lỗi nếu có file upload thất bại
            Toast.show("Upload file thất bại: ${file.name}");
            isAllSuccessful = false;
            break;
          }
        }
      }

      if (isAllSuccessful && itemId.isNotEmpty) {
        int assignId = int.parse(widget.arg.assignId);
        final submitResponse = await AssignApi.submit(
          assignId: assignId,
          fileItemId: itemId,
        );

        if (submitResponse != null) {
          Toast.show("Nộp bài thành công");
          _selectedFiles.clear();
          _deleteFileIds.clear();
          await _fetchData();
        } else {
          Toast.show("Nộp bài thất bại");
        }
      }
    } catch (e) {
      logger("DoFileScreen:_submitFiles Error: $e");
      Toast.show("Có lỗi xảy ra khi nộp bài");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF222222),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }



    final data = _moduleData;
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int dueDateValue = data?['duedate'] ?? 0;
    final bool isExpired = dueDateValue > 0 && now > dueDateValue;

    final name = data?['name'] ?? "Không có tiêu đề";
    final intro = data?['intro'] ?? "";
    final startDate = data?['allowsubmissionsfromdate'] != null &&
            data?['allowsubmissionsfromdate'] > 0
        ? formatTimestamp(data['allowsubmissionsfromdate'], showTime: true)
        : "Không giới hạn";
    final dueDate = data?['duedate'] != null && data?['duedate'] > 0
        ? formatTimestamp(data['duedate'], showTime: true)
        : "Không có hạn chót";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF222222), // Dark header area
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Icon(Icons.menu, color: Colors.white),
          title: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () async {
                final shouldPop = await _showExitDialog();
                if (shouldPop && mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Gaps.vGap24,
                      const Text(
                        "Đề bài:",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      if (intro.isNotEmpty)
                        Html(
                          data: intro,
                          style: {
                            "body": Style(
                              fontSize: FontSize(16),
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                          },
                        )
                      else
                        const SizedBox(height: 8),
                      Gaps.vGap32,
                      _buildInfoLine("Bắt đầu nộp bài:", startDate),
                      Gaps.vGap16,
                      _buildInfoLine("Hạn chót nộp bài:", dueDate),
                      Gaps.vGap24,
                      _buildInfoLine("Số lượng file:",
                          "${_gradeData?['numfiles'] ?? 0}/${_gradeData?['maxfile'] ?? 0}"),
                      Gaps.vGap24,
                      _buildStatusLine("Trạng thái:",
                          _gradeData?['lastattempt']?['status'] ?? "Chưa nộp"),
                      Gaps.vGap16,
                      _buildStatusLine(
                          "Ngày chấm:",
                          (_gradeData?['lastattempt']?['timegraded'] != null &&
                                  _gradeData?['lastattempt']?['timegraded'] >
                                      1000000000)
                              ? formatTimestamp(
                                  _gradeData['lastattempt']['timegraded'],
                                  showTime: true)
                              : "Chưa chấm"),
                      Gaps.vGap16,
                      _buildStatusLine(
                          "Người chấm:",
                          (_gradeData?['lastattempt']?['grader'] != null &&
                                  _gradeData?['lastattempt']?['grader']
                                      .isNotEmpty)
                              ? _gradeData['lastattempt']['grader']
                              : "Chưa chấm"),
                      Gaps.vGap24,
                      if (!_isNotAllowed) ...[
                        const Text(
                          "File nộp bài:",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Gaps.vGap16,
                        _buildSubmissionFiles(isExpired),
                        Gaps.vGap24,
                        if (!isExpired) _buildUploadButton(),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _isNotAllowed
                    ? _buildNotAllowedAlert()
                    : _buildSubmitButton(isExpired),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      String token = await LocalStorage.getString(Env.token);
      String authUrl =
          url.contains("?") ? "$url&wstoken=$token" : "$url?wstoken=$token";

      final Uri uri = Uri.parse(authUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $authUrl');
      }
    } catch (e) {
      logger("DoFileScreen:_downloadFile Error: $e");
    }
  }

  Widget _buildSubmissionFiles(bool isExpired) {
    final rawServerFiles = _gradeData?['lastattempt']?['files'] as List? ?? [];
    final serverFiles = rawServerFiles.where((file) => !_deleteFileIds.contains(file['fileid'])).toList();

    if (serverFiles.isEmpty && _selectedFiles.isEmpty) {
      return const Center(
        child: Text(
          "Trống",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        ...serverFiles.map((file) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grayBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: AppColors.primary),
                Gaps.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file['filename'] ?? "",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "(Đã nộp)",
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: AppColors.primary),
                      onPressed: () => _downloadFile(file['fileurl']),
                    ),
                    if (!isExpired)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            if (!_deleteFileIds.contains(file['fileid'])) {
                              _deleteFileIds.add(file['fileid']);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
        ..._selectedFiles.asMap().entries.map((entry) {
          int index = entry.key;
          PlatformFile file = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, color: AppColors.primary),
                Gaps.hGap12,
                Expanded(
                  child: Text(
                    file.name,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isExpired)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.red),
                    onPressed: () => _removeFile(index),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textDark),
        ),
        Gaps.hGap8,
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textDark),
        ),
        Gaps.hGap8,
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload, color: AppColors.textLight),
            Gaps.hGap12,
            Text(
              "Tải file lên",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isExpired) {
    return ElevatedButton(
      onPressed: isExpired ? null : _submitFiles,
      style: ElevatedButton.styleFrom(
        backgroundColor: isExpired ? Colors.grey : AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        disabledForegroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text(
        "Nộp bài",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotAllowedAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              Gaps.hGap12,
              Expanded(
                child: Text(
                  _availabilityInfo != null
                      ? "Điều kiện hoàn thành"
                      : "Không cho phép làm bài",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          if (_availabilityInfo != null) ...[
            Gaps.vGap8,
            Html(
              data: _availabilityInfo!,
              style: {
                "body": Style(
                  fontSize: FontSize(14),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: Colors.red.withOpacity(0.8),
                ),
              },
            ),
          ] else ...[
            Gaps.vGap8,
            const Text(
              "Bài tập này hiện không khả dụng hoặc bạn không có quyền truy cập.",
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
