import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/shoutbox_message.dart';
import '../../domain/repositories/shoutbox_repository.dart';
import '../datasources/shoutbox_remote_datasource.dart';

/// Implementation of shoutbox repository
class ShoutboxRepositoryImpl implements ShoutboxRepository {
  final ShoutboxRemoteDataSource remoteDataSource;

  ShoutboxRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ShoutboxMessage>>> getMessages({
    int afterId = 0,
    int limit = 50,
  }) async {
    try {
      final messageModels = await remoteDataSource.getMessages(
        afterId: afterId,
        limit: limit,
      );

      final messages = messageModels.map((model) => model.toEntity()).toList();
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiUnavailableException catch (e) {
      return Left(ServerFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${'shoutbox_unexpected_error'.tr()}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ShoutboxMessage>> sendMessage({
    required String username,
    required String message,
  }) async {
    try {
      final messageModel = await remoteDataSource.sendMessage(
        username: username,
        message: message,
      );

      return Right(messageModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiUnavailableException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${'shoutbox_unexpected_error'.tr()}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> deleteMessage(int messageId) async {
    try {
      final result = await remoteDataSource.deleteMessage(messageId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiUnavailableException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${'shoutbox_unexpected_error'.tr()}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getLatestMessageId() async {
    try {
      final latestId = await remoteDataSource.getLatestMessageId();
      return Right(latestId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiUnavailableException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${'shoutbox_unexpected_error'.tr()}: ${e.toString()}'));
    }
  }
}
