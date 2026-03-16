import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/service/course_api.dart';
import 'package:flutter_application_1/service/quiz_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/widgets/quiz_attempt_card.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/models/args/do_test.dart';

class QuizDetailScreen extends StatefulWidget {
  final QuizDetailArg arg;
  const QuizDetailScreen({super.key, required this.arg});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool isloading = true;
  dynamic resCourse;
  dynamic resModule;
  dynamic resHistoryQuiz;
  @override
  void initState() {
    super.initState();
    _getDetailCourse();
  }

  String _stripHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  String _formatTimeSpent(int seconds) {
    if (seconds <= 0) return "--";
    if (seconds < 60) return "$seconds giây";
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes phút $remainingSeconds giây";
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null || timestamp == 0 || timestamp == "") return "--";
    try {
      int ts = timestamp is String ? int.parse(timestamp) : timestamp;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return "--";
    }
  }

  String _getGradingMethod(int? methodId) {
    switch (methodId) {
      case 1:
        return "Điểm cao nhất";
      case 2:
        return "Điểm trung bình";
      case 3:
        return "Lần đầu tiên";
      case 4:
        return "Lần cuối cùng";
      default:
        return "Không xác định";
    }
  }

  void _getDetailCourse() async {
    try {
      resCourse = await CourseApi.detailCourse(courseId: widget.arg.courseId);
      resModule = await CourseApi.detailCourseModule(cmid: widget.arg.cmid);
      resHistoryQuiz = await QuizApi.historyQuiz(quizId: widget.arg.quizId);
    } catch (e) {
      logger(e.toString());
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Back button and Info
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resModule['data']['name'] ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Gaps.vGap24,
                  Text(
                    _stripHtml(resModule['data']['intro'] ?? ""),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight,
                      height: 1.5,
                    ),
                  ),
                  Gaps.vGap24,
                  _buildDetailRow(
                      "Phương pháp chấm điểm",
                      _getGradingMethod(
                          resHistoryQuiz['quiz']?['grademethod'])),
                  _buildDetailRow(
                      "Thời gian mở luyện tập",
                      resModule['data']['timeopen'] != 0
                          ? formatTimestamp(resModule['data']['timeopen'])
                          : "Không xác định"),
                  _buildDetailRow(
                      "Thời gian đóng luyện tập",
                      resModule['data']['timeclose'] != 0
                          ? formatTimestamp(resModule['data']['timeclose'])
                          : "Không xác định"),

                  Gaps.vGap32,
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Điểm làm bài cao nhất  ",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextSpan(
                          text: resHistoryQuiz['quiz']?['usergrade'] ?? "0.00",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gaps.vGap24,

                  // List of attempts
                  ...(resHistoryQuiz['attempts'] as List? ?? []).map((attempt) {
                    int start = attempt['timestart'] ?? 0;
                    int finish = attempt['timefinish'] ?? 0;
                    String status = attempt['state'] == 'finished'
                        ? "Hoàn thành"
                        : "Chưa hoàn thành";
                    if (attempt['allowed'] == 1) {
                      status += " (Được tính)";
                    }

                    return QuizAttemptCard(
                      attemptNumber: attempt['attempt'],
                      status: status,
                      grade: attempt['grade']?.toString() ?? "0",
                      timeSpent: _formatTimeSpent(finish - start),
                      date: _formatDateTime(start),
                      isCompleted: attempt['state'] == 'finished',
                      onTap: () {
                        // TODO: Review or continue attempt
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            Gaps.vGap16,
            Text(
              resCourse['course']['fullname'],
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gaps.vGap16,
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.white,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                Gaps.hGap12,
                Text(
                  "Giảng viên: ${resCourse['teacher'] != null && resCourse['teacher'].isNotEmpty ? "${resCourse['teacher'][0]['lastname'] ?? ''} ${resCourse['teacher'][0]['firstname'] ?? ''}" : 'N/A'}",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    bool isOverdue = false;
    if (resModule != null && resModule['data'] != null) {
      final timeClose = resModule['data']['timeclose'];
      if (timeClose != null && timeClose != 0) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (now > timeClose) {
          isOverdue = true;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isOverdue ? null : () {
            Navigator.pushNamed(
              context,
              AppRouter.doTest,
              arguments: DoTestArg(
                quizId: int.parse(widget.arg.quizId),
                cmid: int.parse(widget.arg.cmid),
                courseId: int.parse(widget.arg.courseId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isOverdue ? Colors.grey : AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            "Tiếp tục làm bài",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
