import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Question {
  final int id;
  final int slot;
  final int uniqueId;
  final String text;
  final List<String> options;

  Question({
    required this.id,
    required this.slot,
    required this.uniqueId,
    required this.text,
    required this.options,
  });
}

class QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final int? selectedAnswerIndex;
  final bool isFlagged;
  final Function(int) onSelectAnswer;
  final VoidCallback onToggleFlag;

  const QuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.selectedAnswerIndex,
    required this.isFlagged,
    required this.onSelectAnswer,
    required this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Câu ${index + 1}:",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Html(
            data: question.text,
            style: {
              "body": Style(
                fontWeight: FontWeight.bold,
                fontSize: FontSize(16),
                color: Colors.black,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "p": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
            },
          ),
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (optIndex) {
            bool isSelected = selectedAnswerIndex == optIndex;
            return InkWell(
              onTap: () => onSelectAnswer(optIndex),
              child: Padding(
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
                          color: isSelected
                              ? const Color(0xFF2E3192)
                              : Colors.grey.shade400,
                          width: isSelected ? 6 : 1.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        question.options[optIndex],
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          InkWell(
            onTap: onToggleFlag,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFlagged ? Icons.bookmark : Icons.bookmark_border,
                  color: isFlagged ? Colors.orange : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text("Gắn cờ",
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
