import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_test_result.dart';
import 'package:flutter_application_1/service/quiz_api.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/models/args/do_test.dart';
import 'package:flutter_application_1/models/args/do_test_result_detail.dart';
import 'package:flutter_application_1/widgets/course_content_sheet.dart';

class DoTestResultScreen extends StatefulWidget {
  final DoTestResultArg arg;
  const DoTestResultScreen({super.key, required this.arg});

  @override
  State<DoTestResultScreen> createState() => _DoTestResultScreenState();
}

class _DoTestResultScreenState extends State<DoTestResultScreen> {
  final Color _bgColor = const Color(0xFF1A1A1A);
  bool _isLoading = true;
  dynamic _resultData;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final res = await QuizApi.historyAttempt(attemptId: widget.arg.attemptId);
      setState(() {
        _resultData = res;
      });
    } catch (e) {
      logger("Error fetching results: $e");
      showToast("Không thể tải kết quả. Vui lòng thử lại!");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimeSpent(int start, int finish) {
    int totalSeconds = finish - start;
    if (totalSeconds <= 0) return "--";
    if (totalSeconds < 60) return "$totalSeconds giây";
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "$minutes phút $seconds giây";
  }

  String _formatDateTime(int timestamp) {
    if (timestamp == 0) return "--";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body:
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_resultData == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: const Center(
          child: Text(
            "Không có dữ liệu",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final attempt = _resultData['attempt'] ?? {};
    final int totalQuestions = (_resultData['questions'] as List?)?.length ?? 0;
    final int correctAnswers = _resultData['count_gradedright'] ??
        _resultData['countrightanswers'] ??
        0;
    final int incorrectAnswers = _resultData['count_gradedwrong'] ?? 0;
    final double grade =
        double.tryParse(_resultData['grade']?.toString() ?? "0") ?? 0;
    final double sumgrades =
        double.tryParse(attempt['sumgrades']?.toString() ?? "0") ?? 0;

    String feedback = "";
    final additional = _resultData['additionaldata'] as List?;
    if (additional != null) {
      final feedbackItem = additional
          .firstWhere((item) => item['id'] == 'feedback', orElse: () => null);
      if (feedbackItem != null) {
        feedback = feedbackItem['content'] ?? "";
        // Basic cleaning of HTML if needed, but since we are using HTML in other screens,
        // maybe we should use FlutterHtml here too?
        // For now stripping basic tags for simplicity or using Html widget.
      }
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            CourseContentSheet.show(
              context,
              courseId: widget.arg.courseId.toString(),
              currentCmid: widget.arg.cmid.toString(),
            );
          },
        ),
        title: Text(
          widget.arg.courseName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              _buildScoreCircle(grade),
              const SizedBox(height: 48),
              _buildStatRow("Đã làm:", "$totalQuestions/$totalQuestions câu"),
              const SizedBox(height: 16),
              _buildStatRowWithIcon(
                "Làm đúng:",
                "$correctAnswers câu",
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildStatRowWithIcon(
                "Làm sai:",
                "$incorrectAnswers câu",
                Icons.cancel,
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                  "Điểm hệ số 15:", "${sumgrades.toStringAsFixed(0)}/15 đ"),
              const SizedBox(height: 16),
              _buildStatRow(
                  "Điểm hệ số 10:", "${grade.toStringAsFixed(1)}/10 đ"),
              const SizedBox(height: 32),
              const Divider(color: Colors.white24),
              const SizedBox(height: 32),
              _buildTimeInfo(
                  "Tổng thời gian làm bài",
                  _formatTimeSpent(
                      attempt['timestart'] ?? 0, attempt['timefinish'] ?? 0)),
              const SizedBox(height: 16),
              _buildTimeInfo("Thời gian bắt đầu:",
                  _formatDateTime(attempt['timestart'] ?? 0)),
              const SizedBox(height: 16),
              _buildTimeInfo("Thời gian kết thúc:",
                  _formatDateTime(attempt['timefinish'] ?? 0)),
              const SizedBox(height: 32),
              _buildFeedbackSection(feedback),
              const SizedBox(height: 48),
              _buildBottomButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(double grade) {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              grade.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 2,
              width: 60,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            const Text(
              "10",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRowWithIcon(
      String label, String value, IconData icon, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: iconColor, size: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(String feedbackHtml) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Phản hồi",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 16),
        if (feedbackHtml.isEmpty)
          const Text(
            "Không có phản hồi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Html(
            data: feedbackHtml,
            style: {
              "body": Style(
                color: Colors.white,
                fontSize: FontSize(16),
                fontWeight: FontWeight.bold,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              "span": Style(color: Colors.white),
            },
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.doTestResultDetail,
                  arguments: DoTestResultDetailArg(
                    attemptId: widget.arg.attemptId,
                    courseName: widget.arg.courseName,
                    cmid: widget.arg.cmid,
                    quizId: widget.arg.quizId,
                    courseId: widget.arg.courseId,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5CB85C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Xem chi tiết",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRouter.doTest,
                  arguments: DoTestArg(
                    quizId: widget.arg.quizId,
                    courseId: widget.arg.courseId,
                    courseName: widget.arg.courseName,
                    cmid: widget.arg.cmid,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00AEEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Làm lại",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
