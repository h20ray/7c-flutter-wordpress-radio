// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shoutbox_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ShoutboxState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)
        loaded,
    required TResult Function() apiUnavailable,
    required TResult Function(
            String message, List<ShoutboxMessage>? previousMessages)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult? Function()? apiUnavailable,
    TResult? Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult Function()? apiUnavailable,
    TResult Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShoutboxInitial value) initial,
    required TResult Function(ShoutboxLoading value) loading,
    required TResult Function(ShoutboxLoaded value) loaded,
    required TResult Function(ShoutboxApiUnavailable value) apiUnavailable,
    required TResult Function(ShoutboxError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShoutboxInitial value)? initial,
    TResult? Function(ShoutboxLoading value)? loading,
    TResult? Function(ShoutboxLoaded value)? loaded,
    TResult? Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult? Function(ShoutboxError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShoutboxInitial value)? initial,
    TResult Function(ShoutboxLoading value)? loading,
    TResult Function(ShoutboxLoaded value)? loaded,
    TResult Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult Function(ShoutboxError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoutboxStateCopyWith<$Res> {
  factory $ShoutboxStateCopyWith(
          ShoutboxState value, $Res Function(ShoutboxState) then) =
      _$ShoutboxStateCopyWithImpl<$Res, ShoutboxState>;
}

/// @nodoc
class _$ShoutboxStateCopyWithImpl<$Res, $Val extends ShoutboxState>
    implements $ShoutboxStateCopyWith<$Res> {
  _$ShoutboxStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ShoutboxInitialImplCopyWith<$Res> {
  factory _$$ShoutboxInitialImplCopyWith(_$ShoutboxInitialImpl value,
          $Res Function(_$ShoutboxInitialImpl) then) =
      __$$ShoutboxInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ShoutboxInitialImplCopyWithImpl<$Res>
    extends _$ShoutboxStateCopyWithImpl<$Res, _$ShoutboxInitialImpl>
    implements _$$ShoutboxInitialImplCopyWith<$Res> {
  __$$ShoutboxInitialImplCopyWithImpl(
      _$ShoutboxInitialImpl _value, $Res Function(_$ShoutboxInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ShoutboxInitialImpl implements ShoutboxInitial {
  const _$ShoutboxInitialImpl();

  @override
  String toString() {
    return 'ShoutboxState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ShoutboxInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)
        loaded,
    required TResult Function() apiUnavailable,
    required TResult Function(
            String message, List<ShoutboxMessage>? previousMessages)
        error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult? Function()? apiUnavailable,
    TResult? Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult Function()? apiUnavailable,
    TResult Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShoutboxInitial value) initial,
    required TResult Function(ShoutboxLoading value) loading,
    required TResult Function(ShoutboxLoaded value) loaded,
    required TResult Function(ShoutboxApiUnavailable value) apiUnavailable,
    required TResult Function(ShoutboxError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShoutboxInitial value)? initial,
    TResult? Function(ShoutboxLoading value)? loading,
    TResult? Function(ShoutboxLoaded value)? loaded,
    TResult? Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult? Function(ShoutboxError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShoutboxInitial value)? initial,
    TResult Function(ShoutboxLoading value)? loading,
    TResult Function(ShoutboxLoaded value)? loaded,
    TResult Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult Function(ShoutboxError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class ShoutboxInitial implements ShoutboxState {
  const factory ShoutboxInitial() = _$ShoutboxInitialImpl;
}

/// @nodoc
abstract class _$$ShoutboxLoadingImplCopyWith<$Res> {
  factory _$$ShoutboxLoadingImplCopyWith(_$ShoutboxLoadingImpl value,
          $Res Function(_$ShoutboxLoadingImpl) then) =
      __$$ShoutboxLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ShoutboxLoadingImplCopyWithImpl<$Res>
    extends _$ShoutboxStateCopyWithImpl<$Res, _$ShoutboxLoadingImpl>
    implements _$$ShoutboxLoadingImplCopyWith<$Res> {
  __$$ShoutboxLoadingImplCopyWithImpl(
      _$ShoutboxLoadingImpl _value, $Res Function(_$ShoutboxLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ShoutboxLoadingImpl implements ShoutboxLoading {
  const _$ShoutboxLoadingImpl();

  @override
  String toString() {
    return 'ShoutboxState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ShoutboxLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)
        loaded,
    required TResult Function() apiUnavailable,
    required TResult Function(
            String message, List<ShoutboxMessage>? previousMessages)
        error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult? Function()? apiUnavailable,
    TResult? Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult Function()? apiUnavailable,
    TResult Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShoutboxInitial value) initial,
    required TResult Function(ShoutboxLoading value) loading,
    required TResult Function(ShoutboxLoaded value) loaded,
    required TResult Function(ShoutboxApiUnavailable value) apiUnavailable,
    required TResult Function(ShoutboxError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShoutboxInitial value)? initial,
    TResult? Function(ShoutboxLoading value)? loading,
    TResult? Function(ShoutboxLoaded value)? loaded,
    TResult? Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult? Function(ShoutboxError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShoutboxInitial value)? initial,
    TResult Function(ShoutboxLoading value)? loading,
    TResult Function(ShoutboxLoaded value)? loaded,
    TResult Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult Function(ShoutboxError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class ShoutboxLoading implements ShoutboxState {
  const factory ShoutboxLoading() = _$ShoutboxLoadingImpl;
}

/// @nodoc
abstract class _$$ShoutboxLoadedImplCopyWith<$Res> {
  factory _$$ShoutboxLoadedImplCopyWith(_$ShoutboxLoadedImpl value,
          $Res Function(_$ShoutboxLoadedImpl) then) =
      __$$ShoutboxLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<ShoutboxMessage> messages,
      int lastMessageId,
      bool isPolling,
      bool isSending});
}

/// @nodoc
class __$$ShoutboxLoadedImplCopyWithImpl<$Res>
    extends _$ShoutboxStateCopyWithImpl<$Res, _$ShoutboxLoadedImpl>
    implements _$$ShoutboxLoadedImplCopyWith<$Res> {
  __$$ShoutboxLoadedImplCopyWithImpl(
      _$ShoutboxLoadedImpl _value, $Res Function(_$ShoutboxLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? lastMessageId = null,
    Object? isPolling = null,
    Object? isSending = null,
  }) {
    return _then(_$ShoutboxLoadedImpl(
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ShoutboxMessage>,
      lastMessageId: null == lastMessageId
          ? _value.lastMessageId
          : lastMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      isPolling: null == isPolling
          ? _value.isPolling
          : isPolling // ignore: cast_nullable_to_non_nullable
              as bool,
      isSending: null == isSending
          ? _value.isSending
          : isSending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ShoutboxLoadedImpl implements ShoutboxLoaded {
  const _$ShoutboxLoadedImpl(
      {required final List<ShoutboxMessage> messages,
      this.lastMessageId = 0,
      this.isPolling = false,
      this.isSending = false})
      : _messages = messages;

  final List<ShoutboxMessage> _messages;
  @override
  List<ShoutboxMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final int lastMessageId;
  @override
  @JsonKey()
  final bool isPolling;
  @override
  @JsonKey()
  final bool isSending;

  @override
  String toString() {
    return 'ShoutboxState.loaded(messages: $messages, lastMessageId: $lastMessageId, isPolling: $isPolling, isSending: $isSending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoutboxLoadedImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.lastMessageId, lastMessageId) ||
                other.lastMessageId == lastMessageId) &&
            (identical(other.isPolling, isPolling) ||
                other.isPolling == isPolling) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      lastMessageId,
      isPolling,
      isSending);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoutboxLoadedImplCopyWith<_$ShoutboxLoadedImpl> get copyWith =>
      __$$ShoutboxLoadedImplCopyWithImpl<_$ShoutboxLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)
        loaded,
    required TResult Function() apiUnavailable,
    required TResult Function(
            String message, List<ShoutboxMessage>? previousMessages)
        error,
  }) {
    return loaded(messages, lastMessageId, isPolling, isSending);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult? Function()? apiUnavailable,
    TResult? Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
  }) {
    return loaded?.call(messages, lastMessageId, isPolling, isSending);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult Function()? apiUnavailable,
    TResult Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(messages, lastMessageId, isPolling, isSending);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShoutboxInitial value) initial,
    required TResult Function(ShoutboxLoading value) loading,
    required TResult Function(ShoutboxLoaded value) loaded,
    required TResult Function(ShoutboxApiUnavailable value) apiUnavailable,
    required TResult Function(ShoutboxError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShoutboxInitial value)? initial,
    TResult? Function(ShoutboxLoading value)? loading,
    TResult? Function(ShoutboxLoaded value)? loaded,
    TResult? Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult? Function(ShoutboxError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShoutboxInitial value)? initial,
    TResult Function(ShoutboxLoading value)? loading,
    TResult Function(ShoutboxLoaded value)? loaded,
    TResult Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult Function(ShoutboxError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class ShoutboxLoaded implements ShoutboxState {
  const factory ShoutboxLoaded(
      {required final List<ShoutboxMessage> messages,
      final int lastMessageId,
      final bool isPolling,
      final bool isSending}) = _$ShoutboxLoadedImpl;

  List<ShoutboxMessage> get messages;
  int get lastMessageId;
  bool get isPolling;
  bool get isSending;
  @JsonKey(ignore: true)
  _$$ShoutboxLoadedImplCopyWith<_$ShoutboxLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ShoutboxApiUnavailableImplCopyWith<$Res> {
  factory _$$ShoutboxApiUnavailableImplCopyWith(
          _$ShoutboxApiUnavailableImpl value,
          $Res Function(_$ShoutboxApiUnavailableImpl) then) =
      __$$ShoutboxApiUnavailableImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ShoutboxApiUnavailableImplCopyWithImpl<$Res>
    extends _$ShoutboxStateCopyWithImpl<$Res, _$ShoutboxApiUnavailableImpl>
    implements _$$ShoutboxApiUnavailableImplCopyWith<$Res> {
  __$$ShoutboxApiUnavailableImplCopyWithImpl(
      _$ShoutboxApiUnavailableImpl _value,
      $Res Function(_$ShoutboxApiUnavailableImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ShoutboxApiUnavailableImpl implements ShoutboxApiUnavailable {
  const _$ShoutboxApiUnavailableImpl();

  @override
  String toString() {
    return 'ShoutboxState.apiUnavailable()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoutboxApiUnavailableImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)
        loaded,
    required TResult Function() apiUnavailable,
    required TResult Function(
            String message, List<ShoutboxMessage>? previousMessages)
        error,
  }) {
    return apiUnavailable();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult? Function()? apiUnavailable,
    TResult? Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
  }) {
    return apiUnavailable?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult Function()? apiUnavailable,
    TResult Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
    required TResult orElse(),
  }) {
    if (apiUnavailable != null) {
      return apiUnavailable();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShoutboxInitial value) initial,
    required TResult Function(ShoutboxLoading value) loading,
    required TResult Function(ShoutboxLoaded value) loaded,
    required TResult Function(ShoutboxApiUnavailable value) apiUnavailable,
    required TResult Function(ShoutboxError value) error,
  }) {
    return apiUnavailable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShoutboxInitial value)? initial,
    TResult? Function(ShoutboxLoading value)? loading,
    TResult? Function(ShoutboxLoaded value)? loaded,
    TResult? Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult? Function(ShoutboxError value)? error,
  }) {
    return apiUnavailable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShoutboxInitial value)? initial,
    TResult Function(ShoutboxLoading value)? loading,
    TResult Function(ShoutboxLoaded value)? loaded,
    TResult Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult Function(ShoutboxError value)? error,
    required TResult orElse(),
  }) {
    if (apiUnavailable != null) {
      return apiUnavailable(this);
    }
    return orElse();
  }
}

abstract class ShoutboxApiUnavailable implements ShoutboxState {
  const factory ShoutboxApiUnavailable() = _$ShoutboxApiUnavailableImpl;
}

/// @nodoc
abstract class _$$ShoutboxErrorImplCopyWith<$Res> {
  factory _$$ShoutboxErrorImplCopyWith(
          _$ShoutboxErrorImpl value, $Res Function(_$ShoutboxErrorImpl) then) =
      __$$ShoutboxErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, List<ShoutboxMessage>? previousMessages});
}

/// @nodoc
class __$$ShoutboxErrorImplCopyWithImpl<$Res>
    extends _$ShoutboxStateCopyWithImpl<$Res, _$ShoutboxErrorImpl>
    implements _$$ShoutboxErrorImplCopyWith<$Res> {
  __$$ShoutboxErrorImplCopyWithImpl(
      _$ShoutboxErrorImpl _value, $Res Function(_$ShoutboxErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? previousMessages = freezed,
  }) {
    return _then(_$ShoutboxErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      previousMessages: freezed == previousMessages
          ? _value._previousMessages
          : previousMessages // ignore: cast_nullable_to_non_nullable
              as List<ShoutboxMessage>?,
    ));
  }
}

/// @nodoc

class _$ShoutboxErrorImpl implements ShoutboxError {
  const _$ShoutboxErrorImpl(
      {required this.message, final List<ShoutboxMessage>? previousMessages})
      : _previousMessages = previousMessages;

  @override
  final String message;
  final List<ShoutboxMessage>? _previousMessages;
  @override
  List<ShoutboxMessage>? get previousMessages {
    final value = _previousMessages;
    if (value == null) return null;
    if (_previousMessages is EqualUnmodifiableListView)
      return _previousMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ShoutboxState.error(message: $message, previousMessages: $previousMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoutboxErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._previousMessages, _previousMessages));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message,
      const DeepCollectionEquality().hash(_previousMessages));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoutboxErrorImplCopyWith<_$ShoutboxErrorImpl> get copyWith =>
      __$$ShoutboxErrorImplCopyWithImpl<_$ShoutboxErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)
        loaded,
    required TResult Function() apiUnavailable,
    required TResult Function(
            String message, List<ShoutboxMessage>? previousMessages)
        error,
  }) {
    return error(message, previousMessages);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult? Function()? apiUnavailable,
    TResult? Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
  }) {
    return error?.call(message, previousMessages);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ShoutboxMessage> messages, int lastMessageId,
            bool isPolling, bool isSending)?
        loaded,
    TResult Function()? apiUnavailable,
    TResult Function(String message, List<ShoutboxMessage>? previousMessages)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, previousMessages);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ShoutboxInitial value) initial,
    required TResult Function(ShoutboxLoading value) loading,
    required TResult Function(ShoutboxLoaded value) loaded,
    required TResult Function(ShoutboxApiUnavailable value) apiUnavailable,
    required TResult Function(ShoutboxError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ShoutboxInitial value)? initial,
    TResult? Function(ShoutboxLoading value)? loading,
    TResult? Function(ShoutboxLoaded value)? loaded,
    TResult? Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult? Function(ShoutboxError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ShoutboxInitial value)? initial,
    TResult Function(ShoutboxLoading value)? loading,
    TResult Function(ShoutboxLoaded value)? loaded,
    TResult Function(ShoutboxApiUnavailable value)? apiUnavailable,
    TResult Function(ShoutboxError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ShoutboxError implements ShoutboxState {
  const factory ShoutboxError(
      {required final String message,
      final List<ShoutboxMessage>? previousMessages}) = _$ShoutboxErrorImpl;

  String get message;
  List<ShoutboxMessage>? get previousMessages;
  @JsonKey(ignore: true)
  _$$ShoutboxErrorImplCopyWith<_$ShoutboxErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
