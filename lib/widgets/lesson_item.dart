import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';

class LessonSectionItem extends StatefulWidget {
  final dynamic section;

  const LessonSectionItem({super.key, required this.section});

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
              return LessonModuleItem(module: module);
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

  const LessonModuleItem({super.key, required this.module});

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
      onTap: () {
        // Xử lý điều hướng khi bấm vào module nếu cần
      },
    );
  }
}
