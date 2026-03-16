import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/models/args/result_detail.dart';

class ResultItem extends StatefulWidget {
  final Map<String, String> item;
  const ResultItem({super.key, required this.item});

  @override
  State<ResultItem> createState() => _ResultItemState();
}

class _ResultItemState extends State<ResultItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item["subject"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gaps.hGap8,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.item["status"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Gaps.hGap8,
                    Icon(
                      _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                      size: 24,
                      color: AppColors.textDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Column(
              children: [
                _buildDetailRow(
                    "Ngày bắt đầu", widget.item["startDate"] ?? "N/A"),
                Gaps.vGap12,
                _buildDetailRow(
                    "Ngày thi dự kiến", widget.item["examDate"] ?? "N/A"),
                Gaps.vGap12,
                _buildDetailRow(
                    "Điểm quá trình", widget.item["processScore"] ?? "0.0",
                    isBold: true),
                Gaps.vGap16,
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.resultDetail,
                      arguments: ResultDetailArg(
                        courseId: widget.item["id"]!,
                        courseName: widget.item["subject"]!,
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Xem chi tiết",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.blue, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ),
        Gaps.hGap8,
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
