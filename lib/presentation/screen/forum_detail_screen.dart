import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/models/args/forum_detail.dart';
import 'package:flutter_application_1/models/args/forum_detail_post.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/forum_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/image_from_network.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/utils/toast.dart';
import 'package:flutter_html/flutter_html.dart';

class ForumDetailScreen extends StatefulWidget {
  final ForumDetailArg arg;
  const ForumDetailScreen({super.key, required this.arg});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final List<String> filters = [
    "Tất cả chủ đề",
    "Đang theo dõi",
    "Chủ đề nổi bật"
  ];
  int selectedFilterIndex = 0;
  dynamic resForum;
  List<dynamic> currentDiscussions = [];
  bool _isLoading = true;
  String? loadingFollowId;

  void _fetchData(int index) async {
    setState(() {
      _isLoading = true;
      selectedFilterIndex = index;
      currentDiscussions = [];
    });

    try {
      dynamic response;
      if (index == 0) {
        response = await ForumApi.detailForum(id: widget.arg.forumId);
        if (response['success'] == true) {
          resForum = response['data'];
          currentDiscussions = response['data']['discussion'] ?? [];
        }
      } else if (index == 1) {
        response = await ForumApi.listFollow();
        currentDiscussions = response['data'] ?? [];
      } else if (index == 2) {
        response = await ForumApi.listPopular(forumid: widget.arg.forumId);
        currentDiscussions = response['data'] ?? [];
      }
    } catch (e) {
      logger("ForumDetailScreen:_fetchData Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateFollow(int discusId, int forumId, int isFollow) async {
    setState(() {
      loadingFollowId = discusId.toString();
    });
    try {
      String token = await LocalStorage.getString(Env.token);
      await ForumApi.updateFollow(
          token: token,
          discusId: discusId,
          forumId: forumId,
          isFollow: isFollow);

      Toast.show(isFollow == 1 ? "Đã theo dõi" : "Đã huỷ theo dõi");
      _fetchData(selectedFilterIndex);
    } catch (e) {
      logger("ForumDetailScreen:_updateFollow Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          loadingFollowId = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Gaps.vGap16,
                      if (currentDiscussions.isNotEmpty)
                        ...currentDiscussions.map<Widget>(
                            (discussion) => _buildDiscussionCard(discussion))
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Không có thảo luận nào"),
                          ),
                        ),
                      Gaps.vGap24,
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 20, left: 4, right: 16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    resForum != null ? resForum['coursename'] : "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Gaps.vGap16,
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${resForum?['total_discussion'] ?? 0} chủ đề",
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (resForum?['check_join'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5D6A7).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Đã tham gia",
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => _fetchData(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscussionCard(Map<String, dynamic> discussion) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.forumDetailPost,
          arguments: ForumDetailPostArg(
            discussionId:
                (discussion['id'] ?? discussion['discussionid']).toString(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              discussion['name'] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Gaps.vGap8,
            Text(
              discussion['createdtime'] ?? "",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
            Gaps.vGap16,
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: imageFromNetwork(
                      discussion['usercreatedpicture'],
                      44,
                      44,
                    ),
                  ),
                ),
                Gaps.hGap12,
                Expanded(
                  child: Text(
                    discussion['usercreated'] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Gaps.vGap16,
            Html(
              data: discussion['intro'] ?? "",
              style: {
                "body": Style(
                    fontSize: FontSize(16),
                    color: Colors.black,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero),
                "p": Style(margin: Margins.zero),
              },
            ),
            Gaps.vGap24,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${discussion['totalpost'] ?? 0} câu trả lời",
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
                if (discussion['reply'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Đã trả lời",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    final discusId =
                        discussion['id'] ?? discussion['discussionid'];
                    final forumId = discussion['forumid'] ??
                        (resForum != null ? resForum['forumid'] : 0);
                    final bool isCurrentlySubscribed =
                        (discussion['sub'] == true || selectedFilterIndex == 1);

                    if (discusId != null &&
                        forumId != 0 &&
                        loadingFollowId == null) {
                      _updateFollow(
                          int.parse(discusId.toString()),
                          int.parse(forumId.toString()),
                          isCurrentlySubscribed ? 0 : 1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: loadingFollowId ==
                          (discussion['id'] ?? discussion['discussionid'])
                              .toString()
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          (discussion['sub'] == true ||
                                  selectedFilterIndex == 1)
                              ? "Huỷ theo dõi"
                              : "Theo dõi",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
