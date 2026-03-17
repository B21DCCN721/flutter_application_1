import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_file.dart';
import 'package:flutter_application_1/models/args/forum_detail.dart';
import 'package:flutter_application_1/models/args/hd72_list.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/models/args/media_viewer.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/course_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/toast.dart';
import 'package:flutter_html/flutter_html.dart';

class CourseContentSheet extends StatefulWidget {
  final dynamic courseData;
  final String courseId;
  final String? currentCmid;

  const CourseContentSheet({
    super.key,
    this.courseData,
    required this.courseId,
    this.currentCmid,
  });

  static void show(BuildContext context,
      {dynamic courseData, required String courseId, String? currentCmid}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseContentSheet(
        courseData: courseData,
        courseId: courseId,
        currentCmid: currentCmid,
      ),
    );
  }

  @override
  State<CourseContentSheet> createState() => _CourseContentSheetState();
}

class _CourseContentSheetState extends State<CourseContentSheet> {
  dynamic _courseData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _courseData = widget.courseData;
    if (_courseData == null) {
      _fetchCourseData();
    }
  }

  Future<void> _fetchCourseData() async {
    setState(() => _isLoading = true);
    try {
      final res = await CourseApi.detailCourse(courseId: widget.courseId);
      if (mounted) {
        setState(() {
          _courseData = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Toast.show("Không thể tải thông tin khóa học");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_courseData == null || _courseData['section'] == null) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const Center(child: Text("Không có dữ liệu khóa học")),
      );
    }

    final sections = _courseData['section'] as List;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Nội dung khóa học",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final modules = section['modules'] as List? ?? [];
                final summary = section['summary'] as String? ?? "";

                return ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.grayBg,
                    radius: 16,
                    child: Icon(
                      Icons.folder,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  title: Text(
                    section['name'] ?? "Chương ${index + 1}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  children: [
                    if (summary.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Html(
                          data: summary,
                          style: {
                            "body": Style(
                              fontSize: FontSize(14),
                              color: Colors.grey[700],
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                          },
                        ),
                      ),
                    ...modules.map((module) {
                      return _buildModuleItem(context, module);
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem(BuildContext context, dynamic module) {
    IconData iconData;
    Color iconColor;

    final String cmid = module['id']?.toString() ?? "";
    final bool isCurrent = widget.currentCmid != null && cmid == widget.currentCmid;

    switch (module['modname']) {
      case 'hvp':
        iconData = Icons.play_circle_fill;
        iconColor = Colors.red;
        break;
      case 'resource':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.blue;
        break;
      case 'quiz':
        iconData = Icons.quiz;
        iconColor = Colors.orange;
        break;
      case 'url':
        iconData = Icons.link;
        iconColor = Colors.green;
        break;
      case 'assign':
        iconData = Icons.assignment;
        iconColor = Colors.purple;
        break;
      case 'forum':
        iconData = Icons.forum;
        iconColor = Colors.teal;
        break;
      case 'helpdesk':
      case 'hd72':
        iconData = Icons.support_agent;
        iconColor = Colors.indigo;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      leading: Icon(iconData, color: isCurrent ? AppColors.primary : iconColor, size: 20),
      title: Text(
        module['name'] ?? "",
        style: TextStyle(
          fontSize: 14, 
          color: isCurrent ? AppColors.primary : AppColors.textDark,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () async {
        if (isCurrent) {
          Navigator.pop(context);
          return;
        }

        final String modName = module['modname']?.toString() ?? "";
        final String instance = module['instance']?.toString() ?? "";

        Navigator.pop(context); // Close bottom sheet

        switch (modName) {
          case "quiz":
            Navigator.pushReplacementNamed(context, AppRouter.quizDetail,
                arguments: QuizDetailArg(
                    cmid: cmid, courseId: widget.courseId, quizId: instance));
            break;
          case "forum":
            Navigator.pushNamed(context, AppRouter.forumDetail,
                arguments: ForumDetailArg(forumId: instance));
            break;
          case "helpdesk":
          case "hd72":
            Navigator.pushNamed(context, AppRouter.hd72List,
                arguments: Hd72ListArg(courseId: widget.courseId));
            break;
          case "assign":
            Navigator.pushReplacementNamed(context, AppRouter.doFile,
                arguments: DoFileArg(
                    cmid: cmid, assignId: instance, courseId: widget.courseId));
            break;
          case "resource":
            if (module['contents'] != null &&
                (module['contents'] as List).isNotEmpty) {
              final String url = module['contents'][0]['fileurl'] ?? "";
              final String name = module['name'] ?? "Tài liệu";
              final String token = await LocalStorage.getString(Env.token);
              final String authedUrl = Env.selfAuthPage(token, url);
              if (context.mounted) {
                Navigator.pushNamed(
                  context,
                  AppRouter.pdfViewer,
                  arguments: MediaViewerArg(url: authedUrl, title: name),
                );
              }
            }
            break;
          case "url":
            if (module['contents'] != null &&
                (module['contents'] as List).isNotEmpty) {
              final String url = module['contents'][0]['fileurl'] ?? "";
              final String name = module['name'] ?? "Webview";
              final String token = await LocalStorage.getString(Env.token);
              final String authedUrl = Env.selfAuthPage(token, url);
              if (context.mounted) {
                Navigator.pushNamed(
                  context,
                  AppRouter.webview,
                  arguments: MediaViewerArg(url: authedUrl, title: name),
                );
              }
            }
            break;
          case "hvp":
            try {
              final res = await CourseApi.detailCourseModule(cmid: cmid);
              if (res['success'] == true &&
                  res['data'] != null &&
                  res['data']['externalurl'] != null &&
                  (res['data']['externalurl'] as List).isNotEmpty) {
                final String externalUrl = res['data']['externalurl'][0];
                final String name = module['name'] ?? "Interactive Content";
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.webview,
                    arguments: MediaViewerArg(url: externalUrl, title: name),
                  );
                }
              } else {
                Toast.show("Không tìm thấy link bài học");
              }
            } catch (e) {
              Toast.show("Đã có lỗi xảy ra");
            }
            break;
          default:
            break;
        }
      },
    );
  }
}
