// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shoutbox_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ShoutboxEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoutboxEventCopyWith<$Res> {
  factory $ShoutboxEventCopyWith(
          ShoutboxEvent value, $Res Function(ShoutboxEvent) then) =
      _$ShoutboxEventCopyWithImpl<$Res, ShoutboxEvent>;
}

/// @nodoc
class _$ShoutboxEventCopyWithImpl<$Res, $Val extends ShoutboxEvent>
    implements $ShoutboxEventCopyWith<$Res> {
  _$ShoutboxEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$FetchMessagesImplCopyWith<$Res> {
  factory _$$FetchMessagesImplCopyWith(
          _$FetchMessagesImpl value, $Res Function(_$FetchMessagesImpl) then) =
      __$$FetchMessagesImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int afterId, int limit});
}

/// @nodoc
class __$$FetchMessagesImplCopyWithImpl<$Res>
    extends _$ShoutboxEventCopyWithImpl<$Res, _$FetchMessagesImpl>
    implements _$$FetchMessagesImplCopyWith<$Res> {
  __$$FetchMessagesImplCopyWithImpl(
      _$FetchMessagesImpl _value, $Res Function(_$FetchMessagesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? afterId = null,
    Object? limit = null,
  }) {
    return _then(_$FetchMessagesImpl(
      afterId: null == afterId
          ? _value.afterId
          : afterId // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FetchMessagesImpl implements FetchMessages {
  const _$FetchMessagesImpl({this.afterId = 0, this.limit = 50});

  @override
  @JsonKey()
  final int afterId;
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'ShoutboxEvent.fetchMessages(afterId: $afterId, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchMessagesImpl &&
            (identical(other.afterId, afterId) || other.afterId == afterId) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, afterId, limit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchMessagesImplCopyWith<_$FetchMessagesImpl> get copyWith =>
      __$$FetchMessagesImplCopyWithImpl<_$FetchMessagesImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) {
    return fetchMessages(afterId, limit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) {
    return fetchMessages?.call(afterId, limit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) {
    if (fetchMessages != null) {
      return fetchMessages(afterId, limit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) {
    return fetchMessages(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) {
    return fetchMessages?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) {
    if (fetchMessages != null) {
      return fetchMessages(this);
    }
    return orElse();
  }
}

abstract class FetchMessages implements ShoutboxEvent {
  const factory FetchMessages({final int afterId, final int limit}) =
      _$FetchMessagesImpl;

  int get afterId;
  int get limit;
  @JsonKey(ignore: true)
  _$$FetchMessagesImplCopyWith<_$FetchMessagesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SendMessageImplCopyWith<$Res> {
  factory _$$SendMessageImplCopyWith(
          _$SendMessageImpl value, $Res Function(_$SendMessageImpl) then) =
      __$$SendMessageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String username, String message});
}

/// @nodoc
class __$$SendMessageImplCopyWithImpl<$Res>
    extends _$ShoutboxEventCopyWithImpl<$Res, _$SendMessageImpl>
    implements _$$SendMessageImplCopyWith<$Res> {
  __$$SendMessageImplCopyWithImpl(
      _$SendMessageImpl _value, $Res Function(_$SendMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? message = null,
  }) {
    return _then(_$SendMessageImpl(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SendMessageImpl implements SendMessage {
  const _$SendMessageImpl({required this.username, required this.message});

  @override
  final String username;
  @override
  final String message;

  @override
  String toString() {
    return 'ShoutboxEvent.sendMessage(username: $username, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendMessageImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, username, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SendMessageImplCopyWith<_$SendMessageImpl> get copyWith =>
      __$$SendMessageImplCopyWithImpl<_$SendMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) {
    return sendMessage(username, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) {
    return sendMessage?.call(username, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) {
    if (sendMessage != null) {
      return sendMessage(username, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) {
    return sendMessage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) {
    return sendMessage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) {
    if (sendMessage != null) {
      return sendMessage(this);
    }
    return orElse();
  }
}

abstract class SendMessage implements ShoutboxEvent {
  const factory SendMessage(
      {required final String username,
      required final String message}) = _$SendMessageImpl;

  String get username;
  String get message;
  @JsonKey(ignore: true)
  _$$SendMessageImplCopyWith<_$SendMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteMessageImplCopyWith<$Res> {
  factory _$$DeleteMessageImplCopyWith(
          _$DeleteMessageImpl value, $Res Function(_$DeleteMessageImpl) then) =
      __$$DeleteMessageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int messageId});
}

/// @nodoc
class __$$DeleteMessageImplCopyWithImpl<$Res>
    extends _$ShoutboxEventCopyWithImpl<$Res, _$DeleteMessageImpl>
    implements _$$DeleteMessageImplCopyWith<$Res> {
  __$$DeleteMessageImplCopyWithImpl(
      _$DeleteMessageImpl _value, $Res Function(_$DeleteMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
  }) {
    return _then(_$DeleteMessageImpl(
      null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DeleteMessageImpl implements DeleteMessage {
  const _$DeleteMessageImpl(this.messageId);

  @override
  final int messageId;

  @override
  String toString() {
    return 'ShoutboxEvent.deleteMessage(messageId: $messageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteMessageImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, messageId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteMessageImplCopyWith<_$DeleteMessageImpl> get copyWith =>
      __$$DeleteMessageImplCopyWithImpl<_$DeleteMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) {
    return deleteMessage(messageId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) {
    return deleteMessage?.call(messageId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) {
    if (deleteMessage != null) {
      return deleteMessage(messageId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) {
    return deleteMessage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) {
    return deleteMessage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) {
    if (deleteMessage != null) {
      return deleteMessage(this);
    }
    return orElse();
  }
}

abstract class DeleteMessage implements ShoutboxEvent {
  const factory DeleteMessage(final int messageId) = _$DeleteMessageImpl;

  int get messageId;
  @JsonKey(ignore: true)
  _$$DeleteMessageImplCopyWith<_$DeleteMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StartPollingImplCopyWith<$Res> {
  factory _$$StartPollingImplCopyWith(
          _$StartPollingImpl value, $Res Function(_$StartPollingImpl) then) =
      __$$StartPollingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StartPollingImplCopyWithImpl<$Res>
    extends _$ShoutboxEventCopyWithImpl<$Res, _$StartPollingImpl>
    implements _$$StartPollingImplCopyWith<$Res> {
  __$$StartPollingImplCopyWithImpl(
      _$StartPollingImpl _value, $Res Function(_$StartPollingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$StartPollingImpl implements StartPolling {
  const _$StartPollingImpl();

  @override
  String toString() {
    return 'ShoutboxEvent.startPolling()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StartPollingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) {
    return startPolling();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) {
    return startPolling?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) {
    if (startPolling != null) {
      return startPolling();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) {
    return startPolling(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) {
    return startPolling?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) {
    if (startPolling != null) {
      return startPolling(this);
    }
    return orElse();
  }
}

abstract class StartPolling implements ShoutboxEvent {
  const factory StartPolling() = _$StartPollingImpl;
}

/// @nodoc
abstract class _$$StopPollingImplCopyWith<$Res> {
  factory _$$StopPollingImplCopyWith(
          _$StopPollingImpl value, $Res Function(_$StopPollingImpl) then) =
      __$$StopPollingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StopPollingImplCopyWithImpl<$Res>
    extends _$ShoutboxEventCopyWithImpl<$Res, _$StopPollingImpl>
    implements _$$StopPollingImplCopyWith<$Res> {
  __$$StopPollingImplCopyWithImpl(
      _$StopPollingImpl _value, $Res Function(_$StopPollingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$StopPollingImpl implements StopPolling {
  const _$StopPollingImpl();

  @override
  String toString() {
    return 'ShoutboxEvent.stopPolling()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StopPollingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) {
    return stopPolling();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) {
    return stopPolling?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) {
    if (stopPolling != null) {
      return stopPolling();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) {
    return stopPolling(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) {
    return stopPolling?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) {
    if (stopPolling != null) {
      return stopPolling(this);
    }
    return orElse();
  }
}

abstract class StopPolling implements ShoutboxEvent {
  const factory StopPolling() = _$StopPollingImpl;
}

/// @nodoc
abstract class _$$RefreshMessagesImplCopyWith<$Res> {
  factory _$$RefreshMessagesImplCopyWith(_$RefreshMessagesImpl value,
          $Res Function(_$RefreshMessagesImpl) then) =
      __$$RefreshMessagesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RefreshMessagesImplCopyWithImpl<$Res>
    extends _$ShoutboxEventCopyWithImpl<$Res, _$RefreshMessagesImpl>
    implements _$$RefreshMessagesImplCopyWith<$Res> {
  __$$RefreshMessagesImplCopyWithImpl(
      _$RefreshMessagesImpl _value, $Res Function(_$RefreshMessagesImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RefreshMessagesImpl implements RefreshMessages {
  const _$RefreshMessagesImpl();

  @override
  String toString() {
    return 'ShoutboxEvent.refreshMessages()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RefreshMessagesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) {
    return refreshMessages();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) {
    return refreshMessages?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) {
    if (refreshMessages != null) {
      return refreshMessages();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) {
    return refreshMessages(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) {
    return refreshMessages?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) {
    if (refreshMessages != null) {
      return refreshMessages(this);
    }
    return orElse();
  }
}

abstract class RefreshMessages implements ShoutboxEvent {
  const factory RefreshMessages() = _$RefreshMessagesImpl;
}

/// @nodoc
abstract class _$$ClearMessagesImplCopyWith<$Res> {
  factory _$$ClearMessagesImplCopyWith(
          _$ClearMessagesImpl value, $Res Function(_$ClearMessagesImpl) then) =
      __$$ClearMessagesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearMessagesImplCopyWithImpl<$Res>
    extends _$ShoutboxEventCopyWithImpl<$Res, _$ClearMessagesImpl>
    implements _$$ClearMessagesImplCopyWith<$Res> {
  __$$ClearMessagesImplCopyWithImpl(
      _$ClearMessagesImpl _value, $Res Function(_$ClearMessagesImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ClearMessagesImpl implements ClearMessages {
  const _$ClearMessagesImpl();

  @override
  String toString() {
    return 'ShoutboxEvent.clearMessages()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearMessagesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int afterId, int limit) fetchMessages,
    required TResult Function(String username, String message) sendMessage,
    required TResult Function(int messageId) deleteMessage,
    required TResult Function() startPolling,
    required TResult Function() stopPolling,
    required TResult Function() refreshMessages,
    required TResult Function() clearMessages,
  }) {
    return clearMessages();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int afterId, int limit)? fetchMessages,
    TResult? Function(String username, String message)? sendMessage,
    TResult? Function(int messageId)? deleteMessage,
    TResult? Function()? startPolling,
    TResult? Function()? stopPolling,
    TResult? Function()? refreshMessages,
    TResult? Function()? clearMessages,
  }) {
    return clearMessages?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int afterId, int limit)? fetchMessages,
    TResult Function(String username, String message)? sendMessage,
    TResult Function(int messageId)? deleteMessage,
    TResult Function()? startPolling,
    TResult Function()? stopPolling,
    TResult Function()? refreshMessages,
    TResult Function()? clearMessages,
    required TResult orElse(),
  }) {
    if (clearMessages != null) {
      return clearMessages();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FetchMessages value) fetchMessages,
    required TResult Function(SendMessage value) sendMessage,
    required TResult Function(DeleteMessage value) deleteMessage,
    required TResult Function(StartPolling value) startPolling,
    required TResult Function(StopPolling value) stopPolling,
    required TResult Function(RefreshMessages value) refreshMessages,
    required TResult Function(ClearMessages value) clearMessages,
  }) {
    return clearMessages(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FetchMessages value)? fetchMessages,
    TResult? Function(SendMessage value)? sendMessage,
    TResult? Function(DeleteMessage value)? deleteMessage,
    TResult? Function(StartPolling value)? startPolling,
    TResult? Function(StopPolling value)? stopPolling,
    TResult? Function(RefreshMessages value)? refreshMessages,
    TResult? Function(ClearMessages value)? clearMessages,
  }) {
    return clearMessages?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FetchMessages value)? fetchMessages,
    TResult Function(SendMessage value)? sendMessage,
    TResult Function(DeleteMessage value)? deleteMessage,
    TResult Function(StartPolling value)? startPolling,
    TResult Function(StopPolling value)? stopPolling,
    TResult Function(RefreshMessages value)? refreshMessages,
    TResult Function(ClearMessages value)? clearMessages,
    required TResult orElse(),
  }) {
    if (clearMessages != null) {
      return clearMessages(this);
    }
    return orElse();
  }
}

abstract class ClearMessages implements ShoutboxEvent {
  const factory ClearMessages() = _$ClearMessagesImpl;
}
