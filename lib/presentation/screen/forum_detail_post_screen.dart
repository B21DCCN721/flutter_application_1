import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/forum_detail_post.dart';
import 'package:flutter_application_1/service/forum_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/image_from_network.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/utils/toast.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/utils/local_storage.dart';

class ForumDetailPostScreen extends StatefulWidget {
  final ForumDetailPostArg arg;
  const ForumDetailPostScreen({super.key, required this.arg});

  @override
  State<ForumDetailPostScreen> createState() => _ForumDetailPostScreenState();
}

class _ForumDetailPostScreenState extends State<ForumDetailPostScreen> {
  bool _isLoading = true;
  List<dynamic> _posts = [];
  Map<int, List<dynamic>> _commentTree = {};
  dynamic _rootPost;
  int _totalReply = 0;
  int _totalLike = 0;
  bool _isFollowLoading = false;
  final Map<int, TextEditingController> _replyControllers = {};

  @override
  void dispose() {
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final int? discussionId = int.tryParse(widget.arg.discussionId);
      if (discussionId == null) {
        Toast.show("ID thảo luận không hợp lệ");
        return;
      }

      final results = await Future.wait([
        ForumApi.discussDetail(discussionId: discussionId),
        ForumApi.listReply(discussionId: discussionId),
      ]);

      dynamic detailData = results[0];
      dynamic replyData = results[1];

      // Robust check: Moodle APIs sometimes return lists containing the object
      if (detailData is List && detailData.isNotEmpty) {
        detailData = detailData[0];
      }
      if (replyData is List && replyData.isNotEmpty) {
        replyData = replyData[0];
      }

      if (detailData is Map && detailData['post'] != null) {
        _rootPost = detailData['post'];
      }

      if (replyData is Map && replyData['post'] != null) {
        final rawPosts = replyData['post'];
        if (rawPosts is List) {
          _posts = rawPosts;
        } else if (rawPosts is Map) {
          // If it's a single object instead of a list
          _posts = [rawPosts];
        }
        _totalReply =
            int.tryParse(replyData['totalreply']?.toString() ?? "0") ?? 0;
        _totalLike =
            int.tryParse(replyData['totallike']?.toString() ?? "0") ?? 0;
        _buildCommentTree();
      }
    } catch (e) {
      logger("ForumDetailPostScreen:_fetchData Error: $e");
      Toast.show("Không thể tải nội dung bài viết");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _buildCommentTree() {
    _commentTree = {};
    if (_posts.isEmpty) return;

    for (var post in _posts) {
      if (post is! Map) continue;
      final rawParentId = post['parentid'];
      if (rawParentId != null) {
        int parentId = int.tryParse(rawParentId.toString()) ?? 0;
        if (!_commentTree.containsKey(parentId)) {
          _commentTree[parentId] = [];
        }
        _commentTree[parentId]!.add(post);
      }
    }
  }

  void _toggleFollow() async {
    if (_rootPost == null || _isFollowLoading) return;

    setState(() {
      _isFollowLoading = true;
    });

    try {
      final String token = await LocalStorage.getString(Env.token);
      final int discussionId = _rootPost['discussionid'] ?? 0;
      final int forumId = _rootPost['forumid'] ?? 0;
      final bool isCurrentlySubscribed = _rootPost['sub'] == true;
      final int targetState = isCurrentlySubscribed ? 0 : 1;

      final response = await ForumApi.updateFollow(
        token: token,
        discusId: discussionId,
        forumId: forumId,
        isFollow: targetState,
      );

      if (response != null && response['exception'] == null) {
        Toast.show(targetState == 1 ? "Đã theo dõi" : "Đã huỷ theo dõi");
        setState(() {
          _rootPost['sub'] = (targetState == 1);
        });
      }
    } catch (e) {
      logger("ForumDetailPostScreen:_toggleFollow Error: $e");
      Toast.show("Không thể thực hiện yêu cầu");
    } finally {
      if (mounted) {
        setState(() {
          _isFollowLoading = false;
        });
      }
    }
  }

  void _onLikePressed(dynamic post, bool isRoot) async {
    if (post == null) return;
    final int postId = int.tryParse(post['id']?.toString() ?? "") ?? 0;
    if (postId == 0) return;

    bool currentIsLike = false;
    if (post['user'] != null && post['user'] is Map) {
      currentIsLike = post['user']['islike'] == true;
    } else {
      currentIsLike = post['islike'] == true;
    }

    final int targetState = currentIsLike ? 0 : 1;

    try {
      final response =
          await ForumApi.likePost(postId: postId, isLike: targetState);
      if (response != null && response['exception'] == null) {
        setState(() {
          if (isRoot) {
            if (post['user'] != null && post['user'] is Map) {
              post['user']['islike'] = (targetState == 1);
            } else {
              post['islike'] = (targetState == 1);
            }
            if (targetState == 1) _totalLike++; else if (_totalLike > 0) _totalLike--;
          } else {
            // Find in _posts to ensure object consistency
            for (var p in _posts) {
              if (p['id'] == postId) {
                if (p['user'] != null && p['user'] is Map) {
                  p['user']['islike'] = (targetState == 1);
                } else {
                  p['islike'] = (targetState == 1);
                }
                
                int currentLikes = int.tryParse(p['like']?.toString() ?? "0") ?? 0;
                p['like'] = targetState == 1 ? currentLikes + 1 : (currentLikes > 0 ? currentLikes - 1 : 0);
                break;
              }
            }
          }
        });
      }
    } catch (e) {
      logger("ForumDetailPostScreen:_onLikePressed Error: $e");
    }
  }

  void _submitReply(dynamic targetPost, bool isRoot) async {
    if (targetPost == null) return;

    final int postId = int.tryParse(targetPost['id']?.toString() ?? "") ?? 0;
    if (postId == 0) return;

    final controller = _replyControllers[postId];
    if (controller == null || controller.text.trim().isEmpty) {
      Toast.show("Vui lòng nhập nội dung");
      return;
    }

    final String message = controller.text.trim();
    // Use 'subject' for root post, and 'replysubject' for sub-comments
    final String subject = isRoot
        ? (targetPost['subject'] ?? targetPost['name'] ?? "Re: Thảo luận")
        : (targetPost['replysubject'] ?? "Re: Thảo luận");

    try {
      final response = await ForumApi.replyDiscuss(
        postId: postId,
        subject: subject,
        message: message,
      );

      if (response != null && response['exception'] == null) {
        Toast.show("Đã gửi phản hồi");
        controller.clear();
        FocusScope.of(context).unfocus();
        _fetchData(); // Refresh list to show new comment
      } else {
        Toast.show(response?['message'] ?? "Gửi phản hồi thất bại");
      }
    } catch (e) {
      logger("ForumDetailPostScreen:_submitReply Error: $e");
      Toast.show("Không thể gửi phản hồi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: Text(
          _rootPost != null ? _rootPost['coursefullname'] ?? "Diên đàn" : "",
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMainPost(),
                  Gaps.vGap24,
                  if (_rootPost != null && _rootPost['canreply'] == true)
                    _buildReplyInput("Trả lời bài viết", _rootPost, true),
                  Gaps.vGap24,
                  Text(
                    "$_totalReply câu trả lời",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Gaps.vGap16,
                  ..._buildComments(),
                  Gaps.vGap32,
                ],
              ),
            ),
    );
  }

  Widget _buildMainPost() {
    if (_rootPost == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _rootPost['subject'] ?? "",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Gaps.vGap12,
        Text(
          formatTimestamp(_rootPost['created']),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Gaps.vGap16,
        Row(
          children: [
            if (_rootPost['outstand'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Gaps.hGap4,
                    Text(
                      "Chủ đề nổi bật",
                      style: TextStyle(color: Color(0xFFB08900), fontSize: 13),
                    ),
                  ],
                ),
              ),
            if (_rootPost['outstand'] == true) Gaps.hGap12,
            Expanded(
              child: ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: _isFollowLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_rootPost['sub'] == true
                        ? "Huỷ theo dõi chủ đề"
                        : "Theo dõi chủ đề"),
              ),
            ),
          ],
        ),
        Gaps.vGap24,
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: imageFromNetwork(_rootPost['userpictureurl'], 50, 50,
                  type: "avatar"),
            ),
            Gaps.hGap12,
            Text(
              _rootPost['userfullname'] ?? "",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        Gaps.vGap16,
        Html(
          data: _rootPost['message'] ?? "",
          style: {
            "body": Style(
              fontSize: FontSize(16),
              color: AppColors.textDark,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
        ),
        Gaps.vGap16,
        Row(
          children: [
            _buildLikeButton(
              _rootPost['id'] ?? 0,
              isLiked: (_rootPost['user'] != null &&
                      _rootPost['user'] is Map)
                  ? (_rootPost['user']['islike'] == true)
                  : (_rootPost['islike'] == true),
              onTap: () => _onLikePressed(_rootPost, true),
            ),
            Gaps.hGap12,
            Text("$_totalLike lượt thích",
                style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text("$_totalReply bình luận",
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildLikeButton(int id, {bool isLiked = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              size: 20,
              color: isLiked ? AppColors.primary : AppColors.textDark,
            ),
            Gaps.hGap8,
            Text(
              isLiked ? "Đã thích" : "Thích",
              style: TextStyle(
                fontSize: 15,
                color: isLiked ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(String hint, dynamic targetPost, bool isRoot) {
    if (targetPost == null) return const SizedBox();
    final int postId = int.tryParse(targetPost['id']?.toString() ?? "0") ?? 0;

    if (!_replyControllers.containsKey(postId)) {
      _replyControllers[postId] = TextEditingController();
    }
    final controller = _replyControllers[postId]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              onSubmitted: (_) => _submitReply(targetPost, isRoot),
            ),
          ),
          IconButton(
            onPressed: () => _submitReply(targetPost, isRoot),
            icon: const Icon(Icons.send, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildComments() {
    if (_rootPost == null) return [];
    List<Widget> commentWidgets = [];

    // Ensure ID is treated correctly as key
    int rootId = int.tryParse(_rootPost['id']?.toString() ?? "") ?? 0;
    List<dynamic> topLevelComments = _commentTree[rootId] ?? [];

    for (var comment in topLevelComments) {
      commentWidgets.add(_buildCommentItem(comment, 0));
    }

    return commentWidgets;
  }

  Widget _buildCommentItem(dynamic comment, int depth) {
    // depth 0: Level 1
    // depth 1: Level 2
    // depth 2: Level 3
    // Any depth > 2 will be treated as Level 3 (no more indentation)
    double leftPadding = depth > 2 ? 40.0 : (depth * 20.0);

    List<dynamic> replies = [];
    if (comment['id'] != null) {
      int commentId = int.tryParse(comment['id'].toString()) ?? 0;
      replies = _commentTree[commentId] ?? [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: leftPadding, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: imageFromNetwork(comment['user']?['image'], 40, 40,
                        type: "avatar"),
                  ),
                  Gaps.hGap12,
                  Expanded(
                    child: Text(
                      comment['user']?['fullname'] ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    comment['timecreated']?.toString() ?? "",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              Gaps.vGap12,
              Html(
                data: comment['message'] ?? "",
                style: {
                  "body": Style(
                    fontSize: FontSize(15),
                    color: AppColors.textDark,
                    margin: Margins.zero,
                  ),
                },
              ),
              Gaps.vGap12,
              Row(
                children: [
                  _buildLikeButton(
                    comment['id'],
                    isLiked: (comment['user'] != null &&
                            comment['user'] is Map)
                        ? (comment['user']['islike'] == true)
                        : (comment['islike'] == true),
                    onTap: () => _onLikePressed(comment, false),
                  ),
                  Gaps.hGap12,
                  Text("${comment['like'] ?? 0} lượt thích",
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
              Gaps.vGap12,
              if (comment['canreply'] == true)
                _buildReplyInput("Trả lời", comment, false),
            ],
          ),
        ),
        // Recursive build for replies
        ...replies.map((reply) => _buildCommentItem(reply, depth + 1)),
      ],
    );
  }
}
