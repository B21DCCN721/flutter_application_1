import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/result_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/widgets/result_item.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoading = true;
  String _selectedStatus = "";
  String _selectedCondition = "";
  List<Map<String, dynamic>> _allResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getResult();
  }

  void _getResult() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await ResultApi.resultCourse(
        status: _selectedStatus,
        condition: _selectedCondition,
      );
      setState(() {
        _allResults = List<Map<String, dynamic>>.from(res);
        _filterResults();
      });
    } catch (e) {
      logger("Error fetching results: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResults = _allResults.where((item) {
        final subject = (item["ten_mon"] ?? "").toString().toLowerCase();
        final status = (item["trang_thai"] ?? "").toString().toLowerCase();
        return subject.contains(query) || status.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Kết quả học tập",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: "Kết quả"),
              Tab(text: "Điểm TK"),
              Tab(text: "DS miễn môn"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildResultsTab(),
            const Center(child: Text("Điểm TK")),
            const Center(child: Text("DS miễn môn")),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tìm kiếm",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
              ),
              Gaps.vGap8,
              TextField(
                controller: _searchController,
                onChanged: (_) => _filterResults(),
                decoration: InputDecoration(
                  hintText: "Nhập từ khóa",
                  hintStyle: const TextStyle(color: AppColors.gray),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterResults();
                          },
                        )
                      : null,
                ),
              ),
              Gaps.vGap16,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Trạng thái",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                        Gaps.vGap8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: const [
                                DropdownMenuItem(
                                    value: "", child: Text("Tất cả")),
                                DropdownMenuItem(
                                    value: "Đang học", child: Text("Đang học")),
                                DropdownMenuItem(
                                    value: "Đã hoàn thành",
                                    child: Text("Đã hoàn thành")),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedStatus = val ?? "";
                                });
                                _getResult();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Gaps.hGap16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Điều kiện dự thi",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                        Gaps.vGap8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCondition,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: const [
                                DropdownMenuItem(
                                    value: "", child: Text("Tất cả")),
                                DropdownMenuItem(
                                    value: "qualify",
                                    child: Text("Đủ điều kiện")),
                                DropdownMenuItem(
                                    value: "ban", child: Text("Cấm thi")),
                                DropdownMenuItem(
                                    value: "postponement",
                                    child: Text("Hoãn thi")),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedCondition = val ?? "";
                                });
                                _getResult();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Gaps.vGap16,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.grayBg,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Học phần",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Trạng thái",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredResults.isEmpty
                  ? const Center(child: Text("Không có dữ liệu"))
                  : ListView.separated(
                      itemCount: _filteredResults.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                      itemBuilder: (context, index) {
                        final item = _filteredResults[index];
                        return ResultItem(
                          item: {
                            "id":
                                (item["courseid"] ?? item["id"])?.toString() ??
                                    "",
                            "subject": item["ten_mon"]?.toString() ?? "",
                            "status": item["trang_thai"]?.toString() ?? "",
                            "startDate": item["ngay_bat_dau"]?.toString() ?? "",
                            "examDate":
                                item["ngay_thi_du_kien"]?.toString() ?? "",
                            "processScore":
                                item["diem_qua_trinh"]?.toString() ?? "",
                          },
                        );
                      },
                    ),
        )
      ],
    );
  }
}
