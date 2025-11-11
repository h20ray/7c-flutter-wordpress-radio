import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/error/failures.dart';
import '../entities/shoutbox_message.dart';
import '../repositories/shoutbox_repository.dart';

/// Use case for sending a shoutbox message
class SendShoutboxMessage {
  final ShoutboxRepository repository;

  SendShoutboxMessage(this.repository);

  /// Execute the use case to send a message
  /// 
  /// [username] - Display name for the message
  /// [message] - Message content
  /// 
  /// Returns [Right] with the created message on success, [Left] with failure on error
  Future<Either<Failure, ShoutboxMessage>> call({
    required String username,
    required String message,
  }) async {
    // Validate inputs
    if (username.trim().isEmpty) {
      return Left(ValidationFailure('shoutbox_username_required_validation'.tr()));
    }

    if (message.trim().isEmpty) {
      return Left(ValidationFailure('shoutbox_message_required'.tr()));
    }

    if (username.length > 100) {
      return Left(ValidationFailure('shoutbox_username_too_long_validation'.tr()));
    }

    if (message.length > 500) {
      return Left(ValidationFailure('shoutbox_message_too_long'.tr()));
    }

    return await repository.sendMessage(
      username: username.trim(),
      message: message.trim(),
    );
  }
}
