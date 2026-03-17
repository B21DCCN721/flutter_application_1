import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_test.dart';
import 'package:flutter_application_1/models/args/do_test_result_detail.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/quiz_api.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/widgets/course_content_sheet.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:oktoast/oktoast.dart';

class DoTestResultDetailScreen extends StatefulWidget {
  final DoTestResultDetailArg arg;
  const DoTestResultDetailScreen({super.key, required this.arg});

  @override
  State<DoTestResultDetailScreen> createState() =>
      _DoTestResultDetailScreenState();
}

class _DoTestResultDetailScreenState extends State<DoTestResultDetailScreen> {
  final Color _bgColor = const Color(0xFF1A1A1A);
  bool _isLoading = true;
  dynamic _resultData;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

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
        final questionsList = (res['questions'] as List?) ?? [];
        _itemKeys.clear();
        _itemKeys.addAll(List.generate(questionsList.length, (index) => GlobalKey()));
        _isLoading = false;

        if (widget.arg.initialPage != null && widget.arg.initialPage! < _itemKeys.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToIndex(widget.arg.initialPage!);
          });
        }
      });
    } catch (e) {
      logger("Error fetching result details: $e");
      showToast("Không thể tải chi tiết kết quả");
      if (mounted) Navigator.pop(context);
    }
  }

  void _scrollToIndex(int index) {
    if (index >= 0 && index < _itemKeys.length) {
      final context = _itemKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
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

    final questions = (_resultData['questions'] as List?) ?? [];
    final int gradedRight = _resultData['count_gradedright'] ?? 0;
    final int total = questions.length;
    final int flaggedCount =
        questions.where((q) => q['flagged'] == true).length;

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
          style: const TextStyle(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Column(
        children: [
          _buildScoreSummary(gradedRight, total, flaggedCount),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _itemKeys.length,
              itemBuilder: (context, index) {
                if (index >= questions.length || index >= _itemKeys.length) {
                  return const SizedBox.shrink();
                }
                return Container(
                  key: _itemKeys[index],
                  child: _buildQuestionItem(questions[index]),
                );
              },
            ),
          ),
          _buildBottomBar(questions),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(int gradedRight, int total, int flagged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            "Trả lời đúng:",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          ),
          const Spacer(),
          Text(
            "$gradedRight/$total - $gradedRight",
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.bookmark, color: Colors.white70, size: 20),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(dynamic q) {
    final int number = q['number'] ?? 0;
    final String text = q['questiontext'] ?? "";
    final List answers = q['answertext'] ?? [];
    final dynamic chosenId = q['chosenid'];
    final String state = q['state'] ?? ""; // gradedwrong, gradedright, gaveup
    final String feedback = q['feedback'] ?? "";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              "Câu $number:",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Html(
              data: text,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  color: Colors.black,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontWeight: FontWeight.bold,
                ),
                "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              },
            ),
            const SizedBox(height: 16),
            ...List.generate(answers.length, (idx) {
              final ans = answers[idx];
              final bool isChosen = chosenId != null && chosenId == ans['id'];
              final bool isCorrect = ans['fraction'] == 1;
              
              return _buildOption(idx, ans['answer'], isChosen, isCorrect, state);
            }),
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildFeedbackBox(feedback),
            ]
          ],
        ),
    );
  }

  Widget _buildOption(int index, String text, bool isChosen, bool isCorrect, String state) {
    String label = String.fromCharCode(65 + index); // A, B, C, D
    
    Color radioColor = Colors.grey.shade300;
    if (isChosen) {
      if (state == "gradedwrong") {
        radioColor = Colors.red;
      } else if (state == "gradedright") {
        radioColor = Colors.green;
      } else {
        radioColor = Colors.blue;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isChosen ? radioColor : Colors.grey.shade400,
                width: isChosen ? 7 : 1.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "$label. $text",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBox(String feedback) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Html(
        data: feedback,
        style: {
          "body": Style(
            fontSize: FontSize(14),
            color: Colors.black,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          "span": Style(fontWeight: FontWeight.bold),
        },
      ),
    );
  }

  Widget _buildBottomBar(List questions) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => _showQuestionList(questions),
              child: const Text(
                "Danh sách câu hỏi",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Làm lại",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionList(List questions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.arg.courseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final String state = q['state'] ?? "";
                    Color color = Colors.grey[700]!;
                    if (state == "gradedright") {
                      color = Colors.green;
                    } else if (state == "gradedwrong" || state == "gaveup") {
                      color = Colors.red;
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToIndex(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
