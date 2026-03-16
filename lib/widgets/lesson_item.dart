import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_file.dart';
import 'package:flutter_application_1/models/args/forum_detail.dart';
import 'package:flutter_application_1/models/args/hd72_list.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/course_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/models/args/media_viewer.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/toast.dart';

class LessonSectionItem extends StatefulWidget {
  final dynamic section;
  final String courseId;

  const LessonSectionItem(
      {super.key, required this.section, required this.courseId});

  @override
  State<LessonSectionItem> createState() => _LessonSectionItemState();
}

class _LessonSectionItemState extends State<LessonSectionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final modules = widget.section['modules'] as List? ?? [];

    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            leading: CircleAvatar(
              backgroundColor:
                  _isExpanded ? AppColors.primary : AppColors.grayBg,
              radius: 18,
              child: Icon(
                _isExpanded ? Icons.folder_open : Icons.folder,
                size: 18,
                color: _isExpanded ? Colors.white : Colors.grey,
              ),
            ),
            title: Text(
              widget.section['name'] ?? "Không có tên chương",
              style: TextStyle(
                fontWeight: _isExpanded ? FontWeight.bold : FontWeight.w500,
                color: _isExpanded ? AppColors.primary : AppColors.textDark,
              ),
            ),
            children: modules.map((module) {
              return LessonModuleItem(
                  module: module, courseId: widget.courseId);
            }).toList(),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class LessonModuleItem extends StatelessWidget {
  final dynamic module;
  final String courseId;

  const LessonModuleItem(
      {super.key, required this.module, required this.courseId});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

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
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      leading: Icon(iconData, color: iconColor, size: 22),
      title: Text(
        module['name'] ?? "",
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: () async {
        final String modName = module['modname']?.toString() ?? "";
        final String instance = module['instance']?.toString() ?? "";
        final String cmid = module['id']?.toString() ?? "";

        switch (modName) {
          case "quiz":
            Navigator.pushNamed(context, AppRouter.quizDetail,
                arguments: QuizDetailArg(
                    cmid: cmid, courseId: courseId, quizId: instance));
            break;
          case "forum":
            Navigator.pushNamed(context, AppRouter.forumDetail,
                arguments: ForumDetailArg(forumId: instance));
            break;
          case "helpdesk":
          case "hd72":
            Navigator.pushNamed(context, AppRouter.hd72List,
                arguments: Hd72ListArg(courseId: courseId));
            break;
          case "assign":
            Navigator.pushNamed(context, AppRouter.doFile,
                arguments: DoFileArg(
                    cmid: cmid, assignId: instance, courseId: courseId));
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
