import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';

class CourseTaskItem extends StatelessWidget {
  final dynamic task;
  final VoidCallback onTap;

  const CourseTaskItem({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompleted = task['status'] == "Đã hoàn thành";

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "${task['modname']} - ${task['title']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.pending,
                  color: isCompleted ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ],
            ),
            Gaps.vGap12,
            Row(
              children: [
                const Text(
                  'Trạng thái: ',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
                Text(
                  task['status'] ?? "",
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (task['deadline'] != null) ...[
              Gaps.vGap8,
              Row(
                children: [
                  const Text(
                    'Hạn nộp: ',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                  Text(
                    task['deadline'] ?? "",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
