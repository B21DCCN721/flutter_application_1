import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/args/quiz_detail.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:flutter_application_1/service/subject_api.dart';
import 'package:flutter_application_1/service/task_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/format_timestamp.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/widgets/task_card.dart';
import 'package:flutter_application_1/widgets/filter_button.dart';

class LearningTaskScreen extends StatefulWidget {
  const LearningTaskScreen({super.key});

  @override
  State<LearningTaskScreen> createState() => _LearningTaskScreenState();
}

class _LearningTaskScreenState extends State<LearningTaskScreen> {
  bool _isloading = true;
  String _selectedFilter = "all";
  String _selectedSubject = "";
  String _selectedStatus = "";
  List<Map<String, dynamic>> tasks = [];

  List<Map<String, String>> _subjects = [];

  final List<Map<String, dynamic>> _statuses = [
    {"name": "Tất cả trạng thái", "value": ""},
    {"name": "Chưa hoàn thành", "value": "0"},
    {"name": "Đã hoàn thành", "value": "1"}
  ];

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

  void _getListTask() async {
    try {
      final res = await TaskApi.listCompletion(
          timeline: _selectedFilter,
          courseId: _selectedSubject,
          status: _selectedStatus);
      setState(() {
        if (res['statuses'] != null) {
          tasks = (res['statuses'] as List).map((task) {
            return {
              "title": task['fullname'] ?? "No Title",
              "subject": task['coursename'] ?? "No Subject",
              "status":
                  task['state'] == 0 ? "Chưa hoàn thành" : "Đã hoàn thành",
              "deadline": task['deadline'] != null
                  ? formatTimestamp(task['deadline'])
                  : null,
              "cmid": task['cmid']?.toString() ?? "",
              "modname": task['modname']?.toString() ?? "",
              "courseid": task['courseid']?.toString() ?? "",
              "instance": task['instance']?.toString() ?? "",
            };
          }).toList();
        }
        _isloading = false;
      });
    } catch (e) {
      logger(e.toString());
      setState(() {
        _isloading = false;
      });
    }
  }

  void _getListSubject() async {
    try {
      final res = await SubjectAPI.list();
      setState(() {
        if (res['data'] != null) {
          _subjects = (res['data'] as List).map((subject) {
            return {
              "name": subject['fullname']?.toString() ?? "",
              "value": subject['courseid']?.toString() ?? "",
            };
          }).toList();
          // Add "All" option if it's not there
          if (!_subjects.any((s) => s['value'] == "")) {
            _subjects.insert(0, {"name": "Tất cả học phần", "value": ""});
          }
        }
      });
    } catch (e) {
      logger(e.toString());
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getListTask();
    _getListSubject();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      "Nhiệm vụ học tập",
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
                      title: "Sắp tới",
                      value: "upcoming",
                      selectedValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                          _getListTask();
                        });
                      },
                    ),
                    FilterButton(
                      title: "Tuần này",
                      value: "this_week",
                      selectedValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                          _getListTask();
                        });
                      },
                    ),
                    FilterButton(
                      title: "Tất cả",
                      value: "all",
                      selectedValue: _selectedFilter,
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                          _getListTask();
                        });
                      },
                    ),
                  ],
                ),
                Gaps.vGap16,
                // Dropdown filters
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            key: const ValueKey('subject'),
                            isExpanded: true,
                            hint: const Text("Học phần",
                                style: TextStyle(
                                    color: AppColors.textLight, fontSize: 16)),
                            value: _selectedSubject,
                            items: _subjects.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject['value'],
                                child: Text(subject['name']!),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedSubject = newValue ?? "";
                                _getListTask();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Gaps.hGap12,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            key: const ValueKey('status'),
                            isExpanded: true,
                            hint: const Text("Trạng thái",
                                style: TextStyle(
                                    color: AppColors.textLight, fontSize: 16)),
                            value: _selectedStatus,
                            items: _statuses.map((status) {
                              return DropdownMenuItem<String>(
                                value: status['value'],
                                child: Text(status['name']!),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedStatus = newValue ?? "all";
                                _getListTask();
                              });
                            },
                          ),
                        ),
                      ),
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
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            title: task['title'] ?? "",
                            modName: task['modname'] ?? "",
                            subject: task['subject'] ?? "",
                            status: task['status'] ?? "",
                            deadline: task['deadline'],
                            onTap: () => _handleTaskTap(
                              cmid: task['cmid'] ?? "",
                              modName: task['modname'] ?? "",
                              courseId: task['courseid'] ?? "",
                              instance: task['instance'] ?? "",
                            ),
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
