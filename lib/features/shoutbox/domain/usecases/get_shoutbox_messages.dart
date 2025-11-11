import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shoutbox_message.dart';
import '../repositories/shoutbox_repository.dart';

/// Use case for getting shoutbox messages
class GetShoutboxMessages {
  final ShoutboxRepository repository;

  GetShoutboxMessages(this.repository);

  /// Execute the use case to get messages
  /// 
  /// [afterId] - Get messages after this ID (0 for all messages)
  /// [limit] - Maximum number of messages to return (default: 50)
  /// 
  /// Returns [Right] with list of messages on success, [Left] with failure on error
  Future<Either<Failure, List<ShoutboxMessage>>> call({
    int afterId = 0,
    int limit = 50,
  }) async {
    return await repository.getMessages(
      afterId: afterId,
      limit: limit,
    );
  }
}
