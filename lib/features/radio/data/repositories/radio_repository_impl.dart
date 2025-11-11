import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/radio_entity.dart';
import '../../domain/repositories/radio_repository.dart';
import '../datasources/radio_remote_datasource.dart';

class RadioRepositoryImpl implements RadioRepository {
  final RadioRemoteDataSource remoteDataSource;

  RadioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RadioEntity>> getRadioConfig() async {
    try {
      final remoteRadioConfig = await remoteDataSource.getRadioConfig();
      return Right(remoteRadioConfig.toEntity());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return const Left(NetworkFailure('Connection timeout'));
      } else if (e.response?.statusCode == 404) {
        return const Left(ServerFailure('Radio config not found'));
      } else {
        return const Left(ServerFailure('Server error occurred'));
      }
    } catch (e) {
      return const Left(ServerFailure('Unexpected error occurred'));
    }
  }
}
