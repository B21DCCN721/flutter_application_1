import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_application_1/service/auth_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/presentation/router/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/service/file_api.dart';
import 'package:flutter_application_1/utils/local_storage.dart';
import 'package:flutter_application_1/constants/env.dart';
import 'package:oktoast/oktoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isAvatarLoading = false;
  Map<String, dynamic> user = {
    "fullname": "",
    "userpictureurl": "",
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
  String? _localAvatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        String filePath = image.path;

        setState(() {
          _isAvatarLoading = true;
        });

        String token = await LocalStorage.getString(Env.token) ?? "";

        // 1. Upload file to get itemId
        var uploadResponse = await FileApi.uploadFile(
          token: token,
          filePath: filePath,
        );

        if (uploadResponse != null &&
            uploadResponse is List &&
            uploadResponse.isNotEmpty) {
          String itemId = "${uploadResponse[0]['itemid']}";

          // 2. Update avatar using itemId
          final updateRes = await AuthApi.updateAvatar(itemId: itemId);

          if (updateRes != null) {
            // 3. Call user API to get updated data
            await _getUser();

            setState(() {
              _localAvatarPath =
                  null; // Clear local preview to show network image
            });

            showToast("Cập nhật ảnh đại diện thành công");
          } else {
            showToast("Cập nhật ảnh đại diện thất bại");
          }
        } else {
          showToast("Tải ảnh lên thất bại");
        }
      }
    } catch (e) {
      logger("ProfileScreen:_pickAndUploadAvatar Error: $e");
      showToast("Có lỗi xảy ra khi cập nhật ảnh");
    } finally {
      if (mounted) {
        setState(() {
          _isAvatarLoading = false;
        });
      }
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Gaps.vGap24,
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: "Chụp ảnh",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadAvatar(ImageSource.camera);
                  },
                ),
                Gaps.vGap12,
                const Divider(color: AppColors.border),
                Gaps.vGap12,
                _buildPickerOption(
                  icon: Icons.image,
                  label: "Chọn ảnh có sẵn",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadAvatar(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            Gaps.hGap16,
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getUser() async {
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
                      SizedBox(
                        height:
                            240, // Height of header (180) + half of avatar overflow (60)
                        child: Stack(
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
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ),
                            // Avatar
                            Positioned(
                              bottom: 0,
                              child: Stack(
                                clipBehavior: Clip.none,
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
                                          color:
                                              Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFFEEEEEE),
                                          backgroundImage: _localAvatarPath !=
                                                  null
                                              ? FileImage(File(_localAvatarPath!))
                                              : (user['userpictureurl'] != null &&
                                                      user['userpictureurl']
                                                          .isNotEmpty
                                                  ? NetworkImage(
                                                      user['userpictureurl'])
                                                  : null) as ImageProvider?,
                                          radius: 60,
                                          child: (_localAvatarPath == null &&
                                                  (user['userpictureurl'] ==
                                                          null ||
                                                      user['userpictureurl']
                                                          .isEmpty))
                                              ? const Icon(Icons.person,
                                                  size: 80, color: Colors.white)
                                              : null,
                                        ),
                                        if (_isAvatarLoading)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _isAvatarLoading ? null : () => _showImagePicker(context),
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
