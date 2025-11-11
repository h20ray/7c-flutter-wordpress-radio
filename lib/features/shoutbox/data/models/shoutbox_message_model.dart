import '../../domain/entities/shoutbox_message.dart';

/// Data model for shoutbox message
class ShoutboxMessageModel extends ShoutboxMessage {
  const ShoutboxMessageModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.message,
    required super.createdAt,
    required super.isAdmin,
    super.relativeTime,
  });

  /// Create from JSON map
  factory ShoutboxMessageModel.fromJson(Map<String, dynamic> json) {
    return ShoutboxMessageModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAdmin: json['is_admin'] as bool? ?? false,
      relativeTime: json['relative_time'] as String?,
    );
  }

  /// Convert to JSON map
  @override
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

  /// Create from entity
  factory ShoutboxMessageModel.fromEntity(ShoutboxMessage entity) {
    return ShoutboxMessageModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      message: entity.message,
      createdAt: entity.createdAt,
      isAdmin: entity.isAdmin,
      relativeTime: entity.relativeTime,
    );
  }

  /// Convert to entity
  ShoutboxMessage toEntity() {
    return ShoutboxMessage(
      id: id,
      userId: userId,
      username: username,
      message: message,
      createdAt: createdAt,
      isAdmin: isAdmin,
      relativeTime: relativeTime,
    );
  }
}
