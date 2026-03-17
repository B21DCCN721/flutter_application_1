import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';

class NotificationItem extends StatelessWidget {
  final dynamic notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['read'] == true;
    final String subject = notification['subject'] ?? '';
    final String smallMessage = notification['smallmessage'] ?? '';
    final String timestamp = notification['timestampcreated'] ?? '';
    final String timePretty = notification['timecreatedpretty'] ?? '';
    final String avatarUrl = notification['pictureuserfrom'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead ? AppColors.border : const Color(0xFFC5CEFA),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildDefaultAvatar(isRead),
                          )
                        : _buildDefaultAvatar(isRead),
                  ),
                  // Unread dot badge
                  if (!isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isRead ? FontWeight.w400 : FontWeight.w600,
                        color: isRead
                            ? AppColors.textLight
                            : AppColors.textDark,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (smallMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        smallMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Timestamp row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: isRead
                              ? Colors.grey[400]
                              : AppColors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timestamp,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isRead
                                ? Colors.grey[400]
                                : AppColors.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (timePretty.isNotEmpty) ...[
                          Text(
                            ' · $timePretty',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isRead) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isRead ? AppColors.grayBg : AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        Icons.person,
        size: 26,
        color: isRead ? Colors.grey[400] : AppColors.primary.withOpacity(0.5),
      ),
    );
  }
}
