import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/auth_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/presentation/router/index.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> user = {
    "fullname": "",
    "avatar": "",
    "username": "",
    "phone": "",
    "email": "",
    "address": "",
    "school_msv": "",
    "school_nganh": "",
    "school_ngay_qdnh": "",
    "school_so_qdnh": "",
    "nam_sinh": "",
  };
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    try {
      final response = await AuthApi.user();
      if (response != null && response['data'] != null) {
        if (mounted) {
          setState(() {
            user = response['data'];
          });
        }
      }
    } catch (e) {
      logger("ProfileScreen Error: $e");
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Column(
              children: [
                // Fixed Header Section
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Curved Header Background
                          ClipPath(
                            clipper: HeaderClipper(),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              color: AppColors.primary,
                            ),
                          ),
                          // Back Button
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 10,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          // Avatar
                          Positioned(
                            bottom: -60,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    backgroundColor: Color(0xFFEEEEEE),
                                    child: Icon(Icons.person,
                                        size: 80, color: Colors.white),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    child: const Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 70),
                      // User Name
                      Text(
                        user['fullname'] ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Gaps.vGap24,
                      const Divider(color: AppColors.border, thickness: 1),
                    ],
                  ),
                ),
                // Scrollable Information Selection
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIconInfoRow(Icons.calendar_today_outlined,
                            user['nam_sinh'] ?? ""),
                        Gaps.vGap12,
                        _buildIconInfoRow(
                            Icons.email_outlined, user['email'] ?? ""),
                        Gaps.vGap12,
                        _buildIconInfoRow(
                            Icons.phone_outlined, user['phone'] ?? ""),
                        Gaps.vGap24,
                        _buildLabelValueRow(
                            "Tài khoản", user['username'] ?? ""),
                        _buildLabelValueRow("Lớp", user['school_lop'] ?? ""),
                        _buildLabelValueRow(
                            "Mã sinh viên", user['school_msv'] ?? ""),
                        _buildLabelValueRow(
                            "Ngành", user['school_nganh'] ?? ""),
                        _buildLabelValueRow(
                            "Số QĐNH", user['school_so_qdnh'] ?? ""),
                        _buildLabelValueRow(
                            "Ngày QĐNH", user['school_ngay_qdnh'] ?? ""),
                        _buildLabelValueRow("Địa chỉ", ""),
                        Gaps.vGap16,
                        const Text(
                          "Ảnh xác thực",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                        Gaps.vGap12,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAuthImage(
                                'https://images.unsplash.com/photo-1471897488648-5eae4ac6686b?q=80&w=200'),
                            _buildAuthImage(
                                'https://images.unsplash.com/photo-1522850949506-59c3592125a1?q=80&w=200'),
                            _buildAuthImage(
                                'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=200'),
                          ],
                        ),
                        Gaps.vGap32,
                        // Change Password Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRouter.changePassword);
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5F5F7),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Đổi mật khẩu",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        Gaps.vGap24,
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildIconInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        Gaps.hGap16,
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
          if (value.isNotEmpty) Gaps.vGap4,
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthImage(String imageUrl) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height + 50, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
