import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String modName;
  final String subject;
  final String status;
  final String? deadline;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.modName,
    required this.title,
    required this.subject,
    required this.status,
    this.deadline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom-like Icon
            const Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            Gaps.hGap20,
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$modName - $title",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Gaps.vGap16,
                  _buildInfoRow("Học phần:", subject),
                  Gaps.vGap12,
                  _buildInfoRow("Trạng thái:", status),
                  if (deadline != null) ...[
                    Gaps.vGap12,
                    _buildInfoRow("Deadline:", deadline!, isDeadline: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isDeadline = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 16,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: isDeadline ? AppColors.danger : AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
