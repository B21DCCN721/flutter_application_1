import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/course_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/widgets/course_card.dart';
import 'package:flutter_application_1/widgets/filter_button.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isloading = true;
  String _selectedFilter = "all";
  List<Map<String, dynamic>> courses = [];

  void _handleCourseTap(String id) {
    Navigator.pushNamed(context, AppRouter.courseDetail, arguments: id);
  }

  void _getListCourses() async {
    try {
      final res = await CourseApi.listCourses(classification: _selectedFilter);
      final List<dynamic> courseList = res['courses'] ?? [];
      setState(() {
        courses = courseList.map((course) {
          final teachers = course['teachers'] as List?;
          final teacher = (teachers != null && teachers.isNotEmpty)
              ? teachers[0]
              : {'firstname': '', 'lastname': ''};

          String examDate = course['ngay_thi'] ?? "";
          if (examDate.trim().isEmpty || examDate == "Ngày A ") {
            examDate = formatTimestamp(course['date_exam']);
          }

          return {
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
      });
    } catch (e) {
      logger("Error fetching courses: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isloading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _getListCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Khóa học của tôi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          print("Search");
                        },
                        icon: const Icon(Icons.search, color: Colors.grey)),
                  ],
                ),
                Gaps.vGap16,
                Row(
                  children: [
                    FilterButton(
                      title: "Tất cả",
                      value: "all",
                      selectedValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                          _isloading = true;
                        });
                        _getListCourses();
                      },
                    ),
                    FilterButton(
                      title: "Đang học",
                      value: "inprogress",
                      selectedValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                          _isloading = true;
                        });
                        _getListCourses();
                      },
                    ),
                    FilterButton(
                      title: "Đã hoàn thành",
                      value: "past",
                      selectedValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                          _isloading = true;
                        });
                        _getListCourses();
                      },
                    ),
                  ],
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isloading
                    ? const Center(child: CircularProgressIndicator())
                    : courses.isEmpty
                        ? const Center(child: Text("Không có khóa học nào"))
                        : ListView.builder(
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return CourseCard(
                                id: course['id'],
                                title: course['title'],
                                firstname: course['firstname'],
                                lastname: course['lastname'],
                                progress: course['progress'],
                                studyTime: course['studyTime'],
                                examDate: course['examDate'],
                                imagePath: course['imagePath'],
                                onTap: () => _handleCourseTap(course['id']),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
