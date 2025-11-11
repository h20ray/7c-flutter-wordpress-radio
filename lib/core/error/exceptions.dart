/// Base exception class
class AppException implements Exception {
  final String message;

  const AppException([this.message = 'An error occurred']);

  @override
  String toString() => message;
}

/// Server exception - thrown when API returns error
class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}

/// Cache exception - thrown when local storage fails
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

/// Network exception - thrown when there's no internet
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

/// Validation exception - thrown when input validation fails
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation error']);
}

/// Rate limit exception - thrown when rate limit is exceeded
class RateLimitException extends AppException {
  const RateLimitException([super.message = 'Rate limit exceeded']);
}

/// API unavailable exception - thrown when API endpoint is not available (404)
class ApiUnavailableException extends AppException {
  const ApiUnavailableException([super.message = 'API endpoint not available']);
}


