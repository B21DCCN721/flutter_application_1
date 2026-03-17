import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_test.dart';
import 'package:flutter_application_1/service/quiz_api.dart';
import 'package:flutter_application_1/service/quiz_server_api.dart';
import 'package:flutter_application_1/widgets/question_card.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/models/args/do_test_result.dart';
import 'package:flutter_application_1/widgets/course_content_sheet.dart';

class DoTestScreen extends StatefulWidget {
  final DoTestArg arg;
  const DoTestScreen({super.key, required this.arg});

  @override
  State<DoTestScreen> createState() => _DoTestScreenState();
}

class _DoTestScreenState extends State<DoTestScreen> {
  final Color _bgColor = const Color(0xFF1E1E1E);
  final Map<int, int> _selectedAnswers = {};
  final Set<int> _flaggedQuestions = {};

  bool _isLoading = true;
  String? _errorMessage;
  int? _attemptId;
  List<Question> _questions = [];
  bool _isOverdue = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Call historyQuiz
      final historyRes = await QuizApi.historyQuiz(
        quizId: widget.arg.quizId.toString(),
      );

      final attempts = historyRes['attempts'] as List? ?? [];
      var activeAttempt = attempts.firstWhere(
        (a) => a['state'] == 'inprogress' || a['state'] == 'overdue',
        orElse: () => null,
      );

      int? currentAttemptId;
      if (activeAttempt != null) {
        currentAttemptId = activeAttempt['id'];
        if (activeAttempt['state'] == 'overdue') {
          _isOverdue = true;
        }
      } else {
        // 2. Call startQuiz
        final startRes = await QuizApi.startQuiz(
          quizId: widget.arg.quizId,
          requireCamera: false, // Default to false, can be updated if needed
        );

        if (startRes['attempt'] == null ||
            (startRes['attempt'] as Map).isEmpty) {
          setState(() {
            _errorMessage = "Hết lượt làm bài";
            _isLoading = false;
          });
          showToast(_errorMessage!);
          return;
        }
        currentAttemptId = startRes['attempt']['id'];
      }

      if (currentAttemptId != null) {
        _attemptId = currentAttemptId;

        // 3. Call quizContent
        final contentRes = await QuizApi.quizContent(
          attemptId: currentAttemptId,
          requireCamera: false,
        );

        // 4. Call QuizServerApi.getAttempt for synchronization
        final serverRes = await QuizServerApi.getAttempt(
          attemptid: currentAttemptId.toString(),
        );

        final questionsData = contentRes['questions'] as List? ?? [];
        final Map<int, int> initialAnswers = {};
        final Set<int> initialFlags = {};

        for (int i = 0; i < questionsData.length; i++) {
          String key = (i + 1).toString();
          if (serverRes.containsKey(key)) {
            var qServer = serverRes[key];

            // Sync Answers
            if (qServer['answers'] != null &&
                qServer['answers']['-1'] != null) {
              int? ansIndex = int.tryParse(qServer['answers']['-1'].toString());
              if (ansIndex != null) {
                initialAnswers[i] = ansIndex;
              }
            }

            // Sync Flagged
            if (qServer['flagged'] == true) {
              initialFlags.add(i);
            }
          }
        }

        setState(() {
          _questions = questionsData.map((q) {
            return Question(
              id: q['questionid'] ?? 0,
              slot: q['slot'] ?? 0,
              uniqueId: q['usageid'] ?? 0,
              text: q['questiontext'] ?? "",
              options: (q['answertext'] as List? ?? [])
                  .map((a) => a['answer'] as String)
                  .toList(),
            );
          }).toList();
          _selectedAnswers.addAll(initialAnswers);
          _flaggedQuestions.addAll(initialFlags);
        });
      }
    } catch (e) {
      debugPrint("Error initializing quiz: $e");
      setState(() {
        _errorMessage = "Có lỗi xảy ra: $e";
      });
      showToast(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (_isOverdue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showOverdueDialog();
        });
      }
    }
  }

  void _showOverdueDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Hết thời gian làm bài"),
        content: const Text(
            "Thời gian làm bài đã hết. Vui lòng nộp bài để ghi nhận kết quả."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _onSubmitQuiz();
            },
            child: const Text("Nộp bài"),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận thoát"),
        content: const Text(
            "Bạn có chắc chắn muốn thoát? Các câu trả lời của bạn đã được lưu lại."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Thoát", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onSelectAnswer(int questionIndex, int answerIndex) async {
    if (_attemptId == null) return;

    setState(() {
      _selectedAnswers[questionIndex] = answerIndex;
    });

    try {
      final question = _questions[questionIndex];
      await QuizServerApi.saveAttempt(
        attemptid: _attemptId.toString(),
        slot: question.slot.toString(),
        value: answerIndex.toString(),
      );
    } catch (e) {
      debugPrint("Error saving answer: $e");
    }
  }

  Future<void> _onToggleFlag(int questionIndex) async {
    if (_attemptId == null) return;

    setState(() {
      if (_flaggedQuestions.contains(questionIndex)) {
        _flaggedQuestions.remove(questionIndex);
      } else {
        _flaggedQuestions.add(questionIndex);
      }
    });

    try {
      final question = _questions[questionIndex];
      await QuizServerApi.flagQuestion(
        attemptid: _attemptId.toString(),
        slot: question.slot.toString(),
      );
    } catch (e) {
      debugPrint("Error toggling flag: $e");
    }
  }

  Future<void> _onSubmitQuiz() async {
    if (_attemptId == null || _questions.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Format data for submitQuiz
      List<Map<String, dynamic>> submitData = [];
      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final ansIndex = _selectedAnswers[i];

        if (ansIndex != null) {
          // answer parameter
          submitData.add({
            "name": "q${q.uniqueId}:${q.slot}_answer",
            "value": ansIndex.toString(),
          });
        }

        // sequencecheck parameter
        submitData.add({
          "name": "q${q.uniqueId}:${q.slot}_:sequencecheck",
          "value": "1",
        });
      }

      // 2. Call QuizApi.submitQuiz
      await QuizApi.submitQuiz(
        attemptId: _attemptId!,
        data: submitData,
      );

      // 3. Call QuizServerApi.submitAttempt
      await QuizServerApi.submitAttempt(
        attemptid: _attemptId.toString(),
      );

      showToast("Nộp bài thành công!");
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.doTestResult,
          arguments: DoTestResultArg(
            attemptId: _attemptId!,
            courseName: widget.arg.courseName,
            cmid: widget.arg.cmid,
            quizId: widget.arg.quizId,
            courseId: widget.arg.courseId,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error submitting quiz: $e");
      showToast("Nộp bài thất bại: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
              onPressed: () async {
                final shouldPop = await _showExitDialog();
                if (shouldPop && mounted) {
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    _buildHeaderInfo(),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _questions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return QuestionCard(
                            index: index,
                            question: _questions[index],
                            selectedAnswerIndex: _selectedAnswers[index],
                            isFlagged: _flaggedQuestions.contains(index),
                            onSelectAnswer: (optIndex) =>
                                _onSelectAnswer(index, optIndex),
                            onToggleFlag: () => _onToggleFlag(index),
                          );
                        },
                      ),
                    ),
                    _buildBottomButton(),
                  ],
                ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thời gian còn lại:",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                "Đã làm:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Text(
                "${_selectedAnswers.length}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "/${_questions.length}",
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.bookmark, color: Colors.white54, size: 18),
              const SizedBox(width: 4),
              Text(
                "${_flaggedQuestions.length}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.all(16)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E3192),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed:
              _attemptId == null || _isLoading ? null : () => _onSubmitQuiz(),
          child: const Text(
            "Nộp bài",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
