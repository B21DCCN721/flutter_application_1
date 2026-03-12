import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/course_api.dart';
import 'package:flutter_application_1/service/task_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/get_course_description.dart';
import 'package:flutter_application_1/utils/image_from_network.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/widgets/lesson_item.dart';
import 'package:flutter_application_1/widgets/course_task_item.dart';
import 'package:flutter_html/flutter_html.dart';

class CourseDetailScreen extends StatefulWidget {
  final String id;
  const CourseDetailScreen({super.key, required this.id});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool showHeader = false;
  int selectedTabIndex = 0;
  bool isDescriptionExpanded = false;
  List<Map<String, dynamic>> tasks = [];
  dynamic resCourse;
  final tabs = ["Tổng quan", "Bài học", "Nhiệm vụ"];
  Widget _buildTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(tabs.length, (index) {
        bool isSelected = selectedTabIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTabIndex = index;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.indigo : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: 100,
                color: isSelected ? Colors.indigo : Colors.transparent,
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildLessonsTab();
      case 2:
        return _buildTasksTab();
      default:
        return const Center(child: Text("Nội dung không tìm thấy"));
    }
  }

  Widget _buildOverviewTab() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Kế hoạch học tập học phần",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Gaps.vGap12,
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () {
              print('abc');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              side: const BorderSide(color: Colors.indigo),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month, color: Colors.indigo),
                Gaps.hGap8,
                Text('Kế hoạch học tập',
                    style: TextStyle(color: Colors.indigo)),
              ],
            ),
          ),
        ),
        Gaps.vGap24,
        const Text(
          "Mô tả học phần",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Gaps.vGap12,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isDescriptionExpanded ? null : 80,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: Html(
                data: resCourse != null
                    ? getCourseDescription(resCourse['section'][0]['summary'] ??
                        resCourse['section'][0]['summary_striptag'] ??
                        "")
                    : "",
                style: {
                  "body": Style(
                    fontSize: FontSize(15),
                    color: Colors.black87,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.5),
                  ),
                },
              ),
            ),
            if (resCourse != null &&
                (resCourse['section'][0]['summary'] ?? "").length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDescriptionExpanded = !isDescriptionExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    isDescriptionExpanded ? "Rút gọn" : "Xem thêm",
                    style: const TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        Gaps.vGap24,
        const Text(
          "Danh sách sinh viên trong khóa học",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Gaps.vGap16,
        Row(
          children: [
            ...List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.grayBg,
                  child: Icon(Icons.person, color: Colors.grey),
                ),
              );
            }),
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.grayBg,
              child: Icon(Icons.more_horiz, color: Colors.grey),
            ),
          ],
        ),
        Gaps.vGap24,
      ],
    );
  }

  Widget _buildLessonsTab() {
    if (resCourse == null || resCourse['section'] == null) {
      return const Center(child: Text("Không có dữ liệu bài học"));
    }

    final sections = resCourse['section'] as List;
    // Bỏ qua section General (index 0) theo yêu cầu
    final lessonSections = sections.skip(1).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: lessonSections.length,
      itemBuilder: (context, index) {
        final section = lessonSections[index];
        return LessonSectionItem(section: section);
      },
    );
  }

  Widget _buildTasksTab() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return CourseTaskItem(
          task: task,
          onTap: () => _handleTaskTap(
            cmid: task['cmid'] ?? "",
            modName: task['modname'] ?? "",
            courseId: task['courseid'] ?? "",
            instance: task['instance'] ?? "",
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      var currentPosition = _scrollController.position.pixels;
      if (currentPosition > 50) {
        if (!showHeader) {
          setState(() {
            showHeader = true;
          });
        }
      } else {
        if (showHeader) {
          setState(() {
            showHeader = false;
          });
        }
      }
    });
    _getDetailCourse();
    _getListTask();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _getDetailCourse() async {
    setState(() {
      _isLoading = true;
    });
    try {
      resCourse = await CourseApi.detailCourse(courseId: widget.id);
    } catch (e) {
      logger(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getListTask() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await TaskApi.listCompletion(courseId: widget.id);
      setState(() {
        if (res['statuses'] != null) {
          tasks = (res['statuses'] as List).map((task) {
            return {
              "title": task['fullname'] ?? "No Title",
              "subject": task['coursename'] ?? "No Subject",
              "status":
                  task['state'] == 0 ? "Chưa hoàn thành" : "Đã hoàn thành",
              "deadline": (task['deadline'] != null && task['deadline'] > 0)
                  ? formatTimestamp(task['deadline'])
                  : null,
              "cmid": task['cmid']?.toString() ?? "",
              "modname": task['modname']?.toString() ?? "",
              "courseid": task['courseid']?.toString() ?? "",
              "instance": task['instance']?.toString() ?? "",
            };
          }).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      logger(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleTaskTap(
      {required String cmid,
      required String modName,
      required String courseId,
      required String instance}) {
    if (modName == "quiz") {
      Navigator.pushNamed(context, AppRouter.quizDetail,
          arguments:
              QuizDetailArg(cmid: cmid, courseId: courseId, quizId: instance));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && resCourse == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            showHeader
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            resCourse != null
                                ? resCourse['course']['fullname']
                                : "",
                            style: const TextStyle(color: AppColors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: imageFromNetwork(
                            resCourse != null
                                ? resCourse['course']['image']
                                : null,
                            double.infinity,
                            300,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resCourse != null
                                ? resCourse['course']['fullname']
                                : "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gaps.vGap8,
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              Gaps.hGap12,
                              Text(
                                resCourse != null &&
                                        resCourse['teacher'] != null &&
                                        (resCourse['teacher'] as List)
                                            .isNotEmpty
                                    ? '${resCourse['teacher'][0]['lastname']} ${resCourse['teacher'][0]['firstname']}'
                                    : '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Gaps.vGap20,
                          _buildTab(),
                        ],
                      ),
                    ),
                    Gaps.vGap16,
                    Container(
                      color: AppColors.white,
                      child: _buildTabContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
