import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/error/failures.dart';
import '../repositories/shoutbox_repository.dart';

/// Use case for deleting a shoutbox message (admin only)
class DeleteShoutboxMessage {
  final ShoutboxRepository repository;

  DeleteShoutboxMessage(this.repository);

  /// Execute the use case to delete a message
  /// 
  /// [messageId] - ID of the message to delete
  /// 
  /// Returns [Right] with success message on success, [Left] with failure on error
  Future<Either<Failure, String>> call(int messageId) async {
    if (messageId <= 0) {
      return Left(ValidationFailure('shoutbox_invalid_message_id'.tr()));
    }

    return await repository.deleteMessage(messageId);
  }
}
