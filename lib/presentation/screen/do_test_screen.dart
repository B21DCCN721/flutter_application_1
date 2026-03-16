import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/do_test.dart';
import 'package:flutter_application_1/widgets/question_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "Luyện tập trắc nghiệm 3",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Column(
        children: [
          _buildHeaderInfo(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockQuestions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return QuestionCard(
                  index: index,
                  question: mockQuestions[index],
                  selectedAnswerIndex: _selectedAnswers[index],
                  isFlagged: _flaggedQuestions.contains(index),
                  onSelectAnswer: (optIndex) {
                    setState(() {
                      _selectedAnswers[index] = optIndex;
                    });
                  },
                  onToggleFlag: () {
                    setState(() {
                      if (_flaggedQuestions.contains(index)) {
                        _flaggedQuestions.remove(index);
                      } else {
                        _flaggedQuestions.add(index);
                      }
                    });
                  },
                );
              },
            ),
          ),
          _buildBottomButton(),
        ],
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
                "/${mockQuestions.length}",
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
          onPressed: () {
            // Nộp bài
          },
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



// Dummy data from screenshots
List<Question> mockQuestions = [
  Question(
    id: 1,
    text:
        "Trong quy trình giải quyết vấn đề, công cụ nào được khuyến nghị sử dụng trong bước 1: xác định vấn đề?",
    options: [
      "A. 5W và 1H",
      "B. Fishbone chart",
      "C. Sơ đồ tư duy",
      "D. Nguyên tắc Pareto"
    ],
  ),
  Question(
    id: 2,
    text:
        "Trong quá trình ra quyết định nhóm, một thành viên luôn bác bỏ mọi ý kiến mới và khăng khăng bảo vệ quan điểm ban đầu của mình. Rào cản nào đang xuất hiện trong trường hợp này?",
    options: [
      "A. Là khả năng định hướng hoạt động nhóm bằng việc làm rõ vai trò và các yêu cầu của nhiệm vụ",
      "B. Là khả năng tác động của người lãnh đạo tới nhân viên để đạt được kết quả cao hơn những gì ban đầu mong đợi hoặc nghĩ là có thể đạt được",
      "C. Là khả năng sử dụng các quyền uy lãnh đạo để áp chế, tạo sức ảnh hưởng tới nhân viên, thuộc cấp",
      "D. Là khả năng thôi thúc nhân viên vượt qua những nhu cầu của bản thân để tập trung vào tổ chức"
    ],
  ),
];
