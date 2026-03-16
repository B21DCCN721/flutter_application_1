import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/hd72_question_detail.dart';
import 'package:flutter_application_1/service/hd72_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/image_from_network.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/models/args/hd72_create_question.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/utils/toast.dart';


class Hd72QuestionDetailScreen extends StatefulWidget {
  final Hd72QuestionDetailArg arg;
  const Hd72QuestionDetailScreen({super.key, required this.arg});

  @override
  State<Hd72QuestionDetailScreen> createState() =>
      _Hd72QuestionDetailScreenState();
}

class _Hd72QuestionDetailScreenState extends State<Hd72QuestionDetailScreen> {
  bool _isLoading = true;
  dynamic _data;
  List<dynamic> _postList = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await Hd72Api.questionDetail(
          threadId: int.parse(widget.arg.threadId));
      final userId = await LocalStorage.getString(Env.userId);
      if (res['data'] != null) {
        setState(() {
          _data = res['data'];
          _postList = _data['data_answer_reply'] ?? [];
          _currentUserId = userId;
        });
      }
    } catch (e) {
      logger("Hd72QuestionDetailScreen:_fetchDetail Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadFile(String? url) async {
    if (url == null || url.isEmpty) {
      Toast.show("Đường dẫn tệp không hợp lệ");
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Toast.show("Không thể mở tệp này");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.grayBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Hỏi đáp 72: ${_data?['data_course']?['fullname'] ?? ""}",
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _fetchDetail,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      if (_postList.isNotEmpty)
                        _buildMainHeader(_postList[0]['answer']),
                      Gaps.vGap24,
                      ..._postList.map((post) => _buildPostItem(post)),
                      Gaps.vGap80, // Space for bottom button
                    ],
                  ),
                ),
                if (_shouldShowAskMore())
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildAskMoreButton(),
                  ),
              ],
            ),
    );
  }

  bool _shouldShowAskMore() {
    if (_data == null || _postList.isEmpty || _currentUserId == null) {
      return false;
    }
    final firstAnswer = _postList[0]['answer'];
    if (firstAnswer == null) return false;

    // Condition: User is the author AND major status is answered (or as per data source)
    final authorId = firstAnswer['info_user']?['id']?.toString();
    final status = _data['status']?.toString(); // or firstAnswer['status']

    return authorId == _currentUserId && status == "answered";
  }

  Widget _buildAskMoreButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRouter.hd72AddQuestion,
          arguments: Hd72CreateQuestionArg(
            courseId: widget.arg.courseId,
            threadId: widget.arg.threadId,
          ),
        ).then((_) => _fetchDetail());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: const Text(
          "Đặt thêm câu hỏi",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
    );
  }

  Widget _buildMainHeader(dynamic answer) {
    if (answer == null) return const SizedBox();

    String statusStr = "Chủ đề mở";
    Color statusColor = Colors.blue.shade50;
    Color statusTextColor = Colors.blue.shade700;

    final String status = _data['status'] ?? "";
    if (status == "waiting") {
      statusStr = "Chờ trả lời";
      statusColor = Colors.orange.shade50;
      statusTextColor = Colors.orange.shade700;
    } else if (status == "closed") {
      statusStr = "Đã đóng";
      statusColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer['answername'] ?? "",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Gaps.vGap12,
          Text(
            formatTimestamp(answer['time'], showTime: true),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
          Gaps.vGap16,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusStr,
              style: TextStyle(
                color: statusTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(dynamic post) {
    final answer = post['answer'];
    final reply = post['reply'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info Header for Answer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.grayBg.withOpacity(0.5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: imageFromNetwork(answer['info_user']?['avatar'], 40, 40,
                    type: "avatar"),
              ),
              Gaps.hGap12,
              Text(
                "${answer['info_user']?['lastname'] ?? ""} ${answer['info_user']?['firstname'] ?? ""}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        // Answer Description
        Padding(
          padding: const EdgeInsets.all(16),
          child: Html(
            data: answer['answerdes'] ?? "",
            style: {
              "body": Style(
                fontSize: FontSize(16),
                color: AppColors.textDark,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
            },
          ),
        ),
        // Attachment if available
        if (answer['attach'] != null && answer['attach'].toString().isNotEmpty)
          _buildAttachment(answer['attach'].toString()),
        // Teacher's Reply if exists
        if (reply != null && reply is Map && reply.isNotEmpty)
          _buildReplySection(reply),
        const Divider(height: 1, thickness: 1, color: AppColors.grayBg),
      ],
    );
  }

  Widget _buildReplySection(dynamic reply) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageFromNetwork(reply['info_user']?['avatar'], 32, 32,
                    type: "avatar"),
              ),
              Gaps.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${reply['info_user']?['lastname'] ?? ""} ${reply['info_user']?['firstname'] ?? ""}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      "Giảng viên phản hồi",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (reply['time'] != null)
                Text(
                  formatTimestamp(reply['time'], showTime: true),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
            ],
          ),
          Gaps.vGap12,
          Html(
            data: reply['replydes'] ?? "",
            style: {
              "body": Style(
                fontSize: FontSize(15),
                color: AppColors.textDark,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(String url) {
    // Extract filename from URL
    String fileName = url.split('/').last;
    try {
      fileName = Uri.decodeComponent(fileName);
    } catch (_) {}

    return InkWell(
      onTap: () => _downloadFile(url),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grayBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, color: AppColors.primary),
            Gaps.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Text(
                    "Nhấn để tải về",
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.download, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
