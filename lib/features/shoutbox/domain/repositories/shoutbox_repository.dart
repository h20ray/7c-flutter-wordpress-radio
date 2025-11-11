import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shoutbox_message.dart';

/// Repository interface for shoutbox operations
abstract class ShoutboxRepository {
  /// Get messages newer than a specific ID
  /// Returns [Right] with list of messages on success, [Left] with failure on error
  Future<Either<Failure, List<ShoutboxMessage>>> getMessages({
    int afterId = 0,
    int limit = 50,
  });

  /// Send a new message
  /// Returns [Right] with the created message on success, [Left] with failure on error
  Future<Either<Failure, ShoutboxMessage>> sendMessage({
    required String username,
    required String message,
  });

  /// Delete a message (admin only)
  /// Returns [Right] with success message on success, [Left] with failure on error
  Future<Either<Failure, String>> deleteMessage(int messageId);

  /// Get the latest message ID
  /// Returns [Right] with the latest ID on success, [Left] with failure on error
  Future<Either<Failure, int>> getLatestMessageId();
}
