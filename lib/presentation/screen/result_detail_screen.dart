import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/result_detail.dart';
import 'package:flutter_application_1/service/result_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/logger.dart';

class ResultDetailScreen extends StatefulWidget {
  final ResultDetailArg arg;
  const ResultDetailScreen({super.key, required this.arg});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  bool _isLoading = true;
  dynamic _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      final res = await ResultApi.resultDetail(courseId: widget.arg.courseId);
      setState(() {
        _data = res;
      });
    } catch (e) {
      logger("ResultDetailScreen:_fetchData Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 24, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D6E), // Dark blue from image
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Gaps.vGap24,
          Text(
            _data?['ten_mon'] ?? widget.arg.courseName ?? "Chi tiết kết quả",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_data == null) return const Center(child: Text("Không có dữ liệu"));

    final calendar = _data['data_calendar'] as List? ?? [];
    final midTermGrades = _data['diem_giua_ky'] as List? ?? [];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSummaryInfo(),
        const Divider(height: 1, color: AppColors.border),
        ...calendar.map<Widget>((week) => _buildWeekItem(week)),
        if (midTermGrades.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Điểm thành phần",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          ...midTermGrades.map<Widget>((item) => _buildGradeItem(item)),
        ],
        Gaps.vGap32,
      ],
    );
  }

  Widget _buildSummaryInfo() {
    // For "Ngày bắt đầu", we take the start_date of the first week if root doesn't have it
    final calendar = _data['data_calendar'] as List? ?? [];
    final startDate = calendar.isNotEmpty ? calendar[0]['start_date'] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Ngày bắt đầu",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                Gaps.vGap8,
                Text(
                  formatTimestamp(startDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Ngày chốt ĐCC",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                Gaps.vGap8,
                Text(
                  formatTimestamp(_data['date_attendance_grade']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekItem(dynamic week) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  week['week_name'] ?? "Tuần",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Gaps.vGap4,
                Text(
                  "${formatTimestamp(week['start_date'])}-${formatTimestamp(week['end_date'])}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _buildCountItem(week['forum']?.toString() ?? "0", "Bài diễn đàn"),
          Gaps.hGap16,
          _buildCountItem(week['practice']?.toString() ?? "0", "Bài LTTN"),
          Gaps.hGap16,
          _buildCountItem(week['helpdesk']?.toString() ?? "0", "HD72"),
          Gaps.hGap12,
          const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
        ],
      ),
    );
  }

  Widget _buildGradeItem(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? "",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                if (item['deadline'] != null && item['deadline'] != 0)
                  Text(
                    "Deadline: ${formatTimestamp(item['deadline'])}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Text(
            item['grade']?.toString() ?? "-/-",
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCountItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Gaps.vGap4,
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
