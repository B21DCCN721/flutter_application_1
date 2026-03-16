import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/search.dart';
import 'package:flutter_application_1/service/course_api.dart';
import 'package:flutter_application_1/service/task_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/widgets/course_card.dart';
import 'package:flutter_application_1/widgets/task_card.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/models/args/forum_detail.dart';
import 'package:flutter_application_1/models/args/do_file.dart';

class SearchScreen extends StatefulWidget {
  final SearchArg arg;
  const SearchScreen({super.key, required this.arg});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;
  List<String> _recentSearches = [];
  Timer? _debounce;
  final String _historyKey = "search_history";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadHistory() async {
    final historyStr = await LocalStorage.getString(_historyKey);
    if (historyStr.isNotEmpty) {
      try {
        final List<dynamic> history = jsonDecode(historyStr);
        setState(() {
          _recentSearches = history.cast<String>();
        });
      } catch (e) {
        logger("SearchScreen: Error loading history: $e");
      }
    }
  }

  void _saveSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    String cleanKeyword = keyword.trim();
    if (_recentSearches.contains(cleanKeyword)) {
      _recentSearches.remove(cleanKeyword);
    }
    _recentSearches.insert(0, cleanKeyword);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await LocalStorage.putString(_historyKey, jsonEncode(_recentSearches));
    setState(() {});
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query, saveHistory: false);
    });
  }

  void _performSearch(String query, {bool saveHistory = true}) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.arg.type == SearchType.course) {
        final res = await CourseApi.listCourses(search: query);
        final List<dynamic> courseList = res['courses'] ?? [];
        _results = courseList.map((course) {
          final teachers = course['teachers'] as List?;
          final teacher = (teachers != null && teachers.isNotEmpty)
              ? teachers[0]
              : {'firstname': '', 'lastname': ''};

          String examDate = course['ngay_thi'] ?? "";
          if (examDate.trim().isEmpty || examDate == "Ngày A ") {
            examDate = formatTimestamp(course['date_exam']);
          }

          return {
            'type': 'course',
            'id': course['id'].toString(),
            'title': course['fullname'] ?? '',
            'firstname': teacher['firstname'] ?? '',
            'lastname': teacher['lastname'] ?? '',
            'studyTime': formatTimestamp(course['startdate']),
            'examDate': examDate,
            'progress': (course['progress'] as num?) != null
                ? (course['progress'] as num).toDouble() / 100.0
                : 0.0,
            'imagePath': course['courseimage'] ?? '',
          };
        }).toList();
      } else {
        final res = await TaskApi.listCompletion(search: query);
        if (res['statuses'] != null) {
          _results = (res['statuses'] as List).map((task) {
            return {
              'type': 'task',
              "title": task['fullname'] ?? "No Title",
              "subject": task['coursename'] ?? "No Subject",
              "status": task['state'] == 0 ? "Chưa hoàn thành" : "Đã hoàn thành",
              "deadline": (task['deadline'] != null && task['deadline'] > 0)
                  ? formatTimestamp(task['deadline'], showTime: true)
                  : null,
              "cmid": task['cmid']?.toString() ?? "",
              "modname": task['modname']?.toString() ?? "",
              "courseid": task['courseid']?.toString() ?? "",
              "instance": task['instance']?.toString() ?? "",
            };
          }).toList();
        }
      }
      if (saveHistory) {
        _saveSearch(query);
      }
    } catch (e) {
      logger("SearchScreen: Error searching: $e");
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
        title: _buildSearchField(),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (_searchController.text.isEmpty && _recentSearches.isNotEmpty)
            _buildRecentSearches(),
          if (_results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Tìm thấy ${_results.length} kết quả",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(child: Text("Không có kết quả tìm kiếm"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          if (item['type'] == 'course') {
                            return CourseCard(
                              id: item['id'],
                              title: item['title'],
                              firstname: item['firstname'],
                              lastname: item['lastname'],
                              progress: item['progress'],
                              studyTime: item['studyTime'],
                              examDate: item['examDate'],
                              imagePath: item['imagePath'],
                              onTap: () => Navigator.pushNamed(
                                  context, AppRouter.courseDetail,
                                  arguments: item['id']),
                            );
                          } else {
                            return TaskCard(
                              title: item['title'],
                              modName: item['modname'],
                              subject: item['subject'],
                              status: item['status'],
                              deadline: item['deadline'],
                              onTap: () => _handleTaskTap(item),
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: _onSearchChanged,
      onSubmitted: (value) => _performSearch(value, saveHistory: true),
      decoration: InputDecoration(
        hintText: "Tìm kiếm ${widget.arg.type == SearchType.course ? 'khóa học' : 'nhiệm vụ'}...",
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _results = [];
                  });
                },
              )
            : null,
      ),
      style: const TextStyle(fontSize: 16, color: AppColors.textDark),
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tìm kiếm gần đây",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await LocalStorage.remove(_historyKey);
                  setState(() {
                    _recentSearches = [];
                  });
                },
                child: const Text("Xóa tất cả", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _recentSearches.map((keyword) {
              return ActionChip(
                label: Text(keyword),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                onPressed: () {
                  _searchController.text = keyword;
                  _performSearch(keyword);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _handleTaskTap(Map<String, dynamic> task) {
    final cmid = task['cmid'] ?? "";
    final modName = task['modname'] ?? "";
    final courseId = task['courseid'] ?? "";
    final instance = task['instance'] ?? "";

    switch (modName) {
      case "quiz":
        Navigator.pushNamed(context, AppRouter.quizDetail,
            arguments: QuizDetailArg(
                cmid: cmid, courseId: courseId, quizId: instance));
        break;
      case "forum":
        Navigator.pushNamed(context, AppRouter.forumDetail,
            arguments: ForumDetailArg(forumId: instance));
        break;
      case "assign":
        Navigator.pushNamed(context, AppRouter.doFile,
            arguments:
                DoFileArg(cmid: cmid, courseId: courseId, assignId: instance));
        break;
      default:
        break;
    }
  }
}
