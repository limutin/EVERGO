import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/notification_model.dart';
import '../controllers/commuter_controller.dart';

class CommuterNotificationsScreen extends StatelessWidget {
  const CommuterNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CommuterController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Obx(() {
                    final unreadCount = ctrl.unreadNotificationCount;
                    if (unreadCount > 0) {
                      return TextButton(
                        onPressed: ctrl.markAllNotificationsRead,
                        child: Text(
                          'Mark all read',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: Obx(() {
                final notifications = ctrl.notifications;

                if (notifications.isEmpty) {
                  return _EmptyNotifications();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NotificationCard(
                        notification: notif,
                        onTap: () => ctrl.markNotificationAsRead(notif.id),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.busArrival:
        return Icons.directions_bus_rounded;
      case NotificationType.delay:
        return Icons.warning_rounded;
      case NotificationType.scheduleChange:
        return Icons.schedule_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.busArrival:
        return AppColors.success;
      case NotificationType.delay:
        return AppColors.warning;
      case NotificationType.scheduleChange:
        return AppColors.accent;
      case NotificationType.system:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(notification.timestamp);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.cardDark
                : AppColors.cardDark2,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.dividerDark
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
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

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see important updates here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
