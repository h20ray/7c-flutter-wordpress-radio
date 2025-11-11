import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class StreamFailure extends Failure {
  const StreamFailure([super.message = 'Stream connection failed']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Connection timeout']);
}

class BufferFailure extends Failure {
  const BufferFailure([super.message = 'Buffering failed']);
}

class ConfigurationFailure extends Failure {
  const ConfigurationFailure([super.message = 'Invalid configuration']);
}

class NotificationFailure extends Failure {
  const NotificationFailure([super.message = 'Notification update failed']);
}

class AlbumArtFailure extends Failure {
  const AlbumArtFailure([super.message = 'Album art fetch failed']);
}

class OfflineFailure extends Failure {
  const OfflineFailure([super.message = 'Operation failed - device is offline']);
}

class RequestCancellationFailure extends Failure {
  const RequestCancellationFailure([super.message = 'Request was cancelled']);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Rate limit exceeded']);
}

