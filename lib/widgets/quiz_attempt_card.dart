import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';

class QuizAttemptCard extends StatelessWidget {
  final int attemptNumber;
  final String status;
  final String grade;
  final String timeSpent;
  final String date;
  final bool isCompleted;
  final VoidCallback onTap;

  const QuizAttemptCard({
    super.key,
    required this.attemptNumber,
    required this.status,
    required this.grade,
    required this.timeSpent,
    required this.date,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lần $attemptNumber",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    children: [
                      Text(
                        isCompleted ? "Xem lại" : "Tiếp tục",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      "Điểm",
                      Row(
                        children: [
                          Text(
                            grade,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.cancel,
                            color: isCompleted ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    _buildInfoItem(
                      "Trạng thái",
                      Text(
                        status,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ],
                ),
                Gaps.vGap16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      "Thời gian",
                      Text(
                        timeSpent,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildInfoItem(
                      "Ngày",
                      Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, Widget child,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
