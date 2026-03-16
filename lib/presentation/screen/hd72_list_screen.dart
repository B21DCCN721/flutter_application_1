import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/models/args/hd72_list.dart';
import 'package:flutter_application_1/models/args/hd72_question_detail.dart';
import 'package:flutter_application_1/models/args/hd72_create_question.dart';

import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/hd72_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/image_from_network.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/logger.dart';

class Hd72ListScreen extends StatefulWidget {
  final Hd72ListArg arg;
  const Hd72ListScreen({super.key, required this.arg});

  @override
  State<Hd72ListScreen> createState() => _Hd72ListScreenState();
}

class _Hd72ListScreenState extends State<Hd72ListScreen> {
  int _selectedTab = 0; // 0: Câu hỏi của tôi, 1: Tất cả câu hỏi
  bool _isLoading = true;
  List<dynamic> _threads = [];
  Map<String, dynamic> _counts = {
    "answered": 0,
    "waiting": 0,
    "closed": 0,
  };
  String _courseName = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String userId = await LocalStorage.getString(Env.userId);
      final results = await Future.wait([
        Hd72Api.countStatus(courseId: widget.arg.courseId),
        Hd72Api.list(
          courseId: widget.arg.courseId,
          createdBy: _selectedTab == 0 ? userId : "",
        ),
      ]);

      final countRes = results[0];
      final listRes = results[1];

      if (countRes['data_count'] != null) {
        _counts = Map<String, dynamic>.from(countRes['data_count']);
      }

      if (listRes['data'] != null) {
        _threads = listRes['data']['data_tblthread'] ?? [];
        final dataCourse = listRes['data']['data_course'] as List?;
        if (dataCourse != null && dataCourse.isNotEmpty) {
          _courseName = dataCourse[0]['fullname'] ?? "";
        }
      }
    } catch (e) {
      logger("Hd72ListScreen:_fetchData Error: $e");
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          _courseName.isNotEmpty ? _courseName : "Hệ thống hỗ trợ",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopTabs(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          child: Column(
                            children: [
                              _buildStatusSummary(),
                              Gaps.vGap24,
                              _buildQuestionList(),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildBottomButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildTabButton("Câu hỏi của tôi", 0),
          Gaps.hGap12,
          _buildTabButton("Tất cả câu hỏi", 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedTab != index) {
            setState(() {
              _selectedTab = index;
            });
            _fetchData();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.grayBg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Row(
      children: [
        _buildStatusCard(
          icon: Icons.description_outlined,
          iconColor: Colors.green,
          label: "Đã trả lời",
          count: "${_counts['answered'] ?? 0} câu",
          countColor: Colors.green,
          badgeIcon: Icons.check_circle,
          badgeColor: Colors.green,
        ),
        Gaps.hGap12,
        _buildStatusCard(
          icon: Icons.access_time,
          iconColor: Colors.blue,
          label: "Chờ trả lời",
          count: "${_counts['waiting'] ?? 0} câu",
          countColor: Colors.blue,
        ),
        Gaps.hGap12,
        _buildStatusCard(
          icon: Icons.description_outlined,
          iconColor: Colors.red,
          label: "Đã đóng",
          count: "${_counts['closed'] ?? 0} câu",
          countColor: Colors.red,
          badgeIcon: Icons.cancel,
          badgeColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required Color countColor,
    IconData? badgeIcon,
    Color? badgeColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 48,
              width: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 42, color: iconColor.withOpacity(0.8)),
                  if (badgeIcon != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(badgeIcon, size: 18, color: badgeColor),
                      ),
                    ),
                ],
              ),
            ),
            Gaps.vGap12,
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            Gaps.vGap4,
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: countColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    if (_threads.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
              Gaps.vGap12,
              const Text("Không có câu hỏi nào",
                  style: TextStyle(color: AppColors.textLight)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _threads.length,
      separatorBuilder: (context, index) => Gaps.vGap16,
      itemBuilder: (context, index) {
        final thread = _threads[index];
        return _buildQuestionCard(thread);
      },
    );
  }

  Widget _buildQuestionCard(dynamic thread) {
    String statusStr = "Chủ đề mở";
    Color statusColor = Colors.blue.shade50;
    Color statusTextColor = Colors.blue.shade700;

    final String status = thread['status'] ?? "";
    if (status == "waiting") {
      statusStr = "Chờ trả lời";
      statusColor = Colors.orange.shade50;
      statusTextColor = Colors.orange.shade700;
    } else if (status == "closed") {
      statusStr = "Đã đóng";
      statusColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade700;
    }

    final userInfo = thread['info_user'];
    final userReply = thread['info_user_reply'];

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.hd72QuestionDetail,
          arguments: Hd72QuestionDetailArg(
            threadId: thread['id'].toString(),
            courseId: widget.arg.courseId,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Text(
              thread['answername'] ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Gaps.vGap8,
            Text(
              formatTimestamp(thread['time'], showTime: true),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
            Gaps.vGap16,
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: imageFromNetwork(userInfo?['avatar'], 36, 36,
                      type: "avatar"),
                ),
                Gaps.hGap12,
                Text(
                  "${userInfo?['lastname'] ?? ""} ${userInfo?['firstname'] ?? ""}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Gaps.vGap12,
            _buildInfoTag("ID chủ đề #${thread['id']}"),
            Gaps.vGap12,
            _buildInfoTag("Học phần: ${thread['coursename'] ?? ""}"),
            if (userReply != null) ...[
              Gaps.vGap12,
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: imageFromNetwork(userReply['avatar'], 36, 36,
                        type: "avatar"),
                  ),
                  Gaps.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userReply['lastname'] ?? ""} ${userReply['firstname'] ?? ""}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (thread['last_reply_time'] != null &&
                            thread['last_reply_time'] != 0)
                          Text(
                            "đã trả lời lúc ${formatTimestamp(thread['last_reply_time'], showTime: true)}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            Gaps.vGap16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusStr,
                style: TextStyle(
                  color: statusTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grayBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRouter.hd72CreateQuestion,
          arguments: Hd72CreateQuestionArg(courseId: widget.arg.courseId),
        ).then((_) => _fetchData());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
      ),
      child: const Text(
        "Đặt câu hỏi",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
