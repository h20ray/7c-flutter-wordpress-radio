import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';

/// Represents a shoutbox message entity
class ShoutboxMessage extends Equatable {
  final int id;
  final int userId;
  final String username;
  final String message;
  final DateTime createdAt;
  final bool isAdmin;
  final String? relativeTime; // Optional field from API

  const ShoutboxMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.message,
    required this.createdAt,
    required this.isAdmin,
    this.relativeTime,
  });

  /// Create a copy of this message with updated fields
  ShoutboxMessage copyWith({
    int? id,
    int? userId,
    String? username,
    String? message,
    DateTime? createdAt,
    bool? isAdmin,
    String? relativeTime,
  }) {
    return ShoutboxMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      relativeTime: relativeTime ?? this.relativeTime,
    );
  }

  /// Check if this is an anonymous message
  bool get isAnonymous => userId == 0;

  /// Get relative time string (e.g., "2 minutes ago")
  /// Uses API-provided relativeTime if available, otherwise calculates locally
  String get relativeTimeDisplay {
    if (relativeTime != null && relativeTime!.isNotEmpty) {
      return relativeTime!;
    }
    
    // Fallback to local calculation
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'shoutbox_just_now'.tr();
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${'shoutbox_minutes_ago'.tr()}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${'shoutbox_hours_ago'.tr()}';
    } else {
      return '${difference.inDays}${'shoutbox_days_ago'.tr()}';
    }
  }

  /// Get exact date and time string (e.g., "Dec 15, 2024 2:30 PM")
  String get exactTimeDisplay {
    // Format: "MMM dd, yyyy h:mm a" (e.g., "Dec 15, 2024 2:30 PM")
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[createdAt.month - 1];
    final day = createdAt.day.toString().padLeft(2, '0');
    final year = createdAt.year;
    
    // Format time in 12-hour format
    final hour = createdAt.hour == 0 ? 12 : (createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour);
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour < 12 ? 'AM' : 'PM';
    
    return '$month $day, $year $hour:$minute $period';
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_admin': isAdmin,
      if (relativeTime != null) 'relative_time': relativeTime,
    };
  }

  /// Create from JSON map
  factory ShoutboxMessage.fromJson(Map<String, dynamic> json) {
    return ShoutboxMessage(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAdmin: json['is_admin'] as bool? ?? false,
      relativeTime: json['relative_time'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        message,
        createdAt,
        isAdmin,
        relativeTime,
      ];

  @override
  String toString() {
    return 'ShoutboxMessage(id: $id, userId: $userId, username: $username, message: $message, createdAt: $createdAt, isAdmin: $isAdmin, relativeTime: $relativeTime)';
  }
}
