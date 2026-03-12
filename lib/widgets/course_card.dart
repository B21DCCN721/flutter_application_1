import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/image_from_network.dart';

class CourseCard extends StatelessWidget {
  final String id;
  final String title;
  final String firstname;
  final String lastname;
  final String studyTime;
  final String examDate;
  final double progress;
  final String imagePath;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    this.id = "",
    this.title = "Xác suất và thống kê",
    this.firstname = "Nguyễn Phan Tình",
    this.lastname = "ThS.",
    this.studyTime = "28/05/2026",
    this.examDate = "-",
    this.progress = 0.38,
    this.imagePath = 'assets/imgs/bg1.jpg',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Course Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.grayBg,
                    child: _buildImage(),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset('assets/images/logo_small.png',
                        height: 20,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.school,
                                size: 20, color: AppColors.primary)),
                  ),
                ),
              ],
            ),
            Gaps.vGap16,

            // Course Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGray,
                    ),
                  ),
                ),
                const Icon(Icons.school, color: AppColors.primary, size: 20),
              ],
            ),
            Gaps.vGap12,

            // Instructor
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.grayBg,
                  child: Icon(Icons.person, size: 16, color: Colors.grey),
                ),
                Gaps.hGap8,
                const Text(
                  "Giảng viên: ",
                  style: TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
                Text(
                  "$lastname $firstname",
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Gaps.vGap16,

            // Study & Exam Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thời gian học",
                        style:
                            TextStyle(color: AppColors.textLight, fontSize: 13),
                      ),
                      Gaps.vGap4,
                      Text(
                        studyTime,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ngày thi dự kiến:",
                        style:
                            TextStyle(color: AppColors.textLight, fontSize: 13),
                      ),
                      Gaps.vGap4,
                      Text(
                        examDate,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gaps.vGap16,

            // Progress
            Text(
              "Hoàn thành ${(progress * 100).toInt()}%",
              style: const TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            Gaps.vGap8,
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.grayBg,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return imageFromNetwork(
      imagePath,
      double.infinity,
      160,
      fit: BoxFit.cover,
    );
  }
}
