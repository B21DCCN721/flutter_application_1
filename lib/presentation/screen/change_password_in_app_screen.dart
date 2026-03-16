import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/auth_api.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/theme/gaps.dart';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter_application_1/utils/toast.dart';

class ChangePasswordInAppScreen extends StatefulWidget {
  const ChangePasswordInAppScreen({super.key});

  @override
  State<ChangePasswordInAppScreen> createState() =>
      _ChangePasswordInAppScreenState();
}

class _ChangePasswordInAppScreenState extends State<ChangePasswordInAppScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String _fullname = "";

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _getUser() async {
    try {
      final response = await AuthApi.user();
      if (response != null && response['data'] != null) {
        if (mounted) {
          setState(() {
            _fullname = response['data']['fullname'] ?? "";
          });
        }
      }
    } catch (e) {
      logger("ChangePasswordScreen getUser Error: $e");
    }
  }

  void _handleChangePassword() async {
    try {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        // Show error message
        Toast.show("Mật khẩu mới và xác nhận mật khẩu không khớp");
        return;
      }
      if (_newPasswordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty ||
          _oldPasswordController.text.isEmpty) {
        Toast.show("Vui lòng điền đầy đủ thông tin.");
        return;
      }
      await AuthApi.updatePasswordFromOld(
          password: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmNewPassword: _confirmPasswordController.text);
      Toast.show("Đổi mật khẩu thành công");
    } catch (e) {
      logger("ChangePasswordScreen changePassword Error: $e");
      Toast.show("Đổi mật khẩu thất bại");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with clipper and avatar
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
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
                      child: Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            // User Name

            Text(
              _fullname.isEmpty ? "Nguyễn Thị Ngân" : _fullname,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Gaps.vGap32,
            // Title
            const Text(
              "Đổi mật khẩu",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Gaps.vGap24,
            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPasswordField(
                      label: "Mật khẩu cũ",
                      hintText: "Nhập mật khẩu cũ",
                      controller: _oldPasswordController,
                      isVisible: _isOldPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isOldPasswordVisible = !_isOldPasswordVisible;
                        });
                      },
                    ),
                    Gaps.vGap20,
                    _buildPasswordField(
                      label: "Mật khẩu mới",
                      hintText: "Nhập mật khẩu mới",
                      controller: _newPasswordController,
                      isVisible: _isNewPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    Gaps.vGap20,
                    _buildPasswordField(
                      label: "Xác nhận mật khẩu mới",
                      hintText: "Nhập lại mật khẩu mới",
                      controller: _confirmPasswordController,
                      isVisible: _isConfirmPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    Gaps.vGap40,
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _handleChangePassword();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Xác nhận",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Gaps.vGap40,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gaps.vGap8,
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.black54,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
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
