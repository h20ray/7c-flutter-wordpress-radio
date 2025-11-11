import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/shoutbox_message.dart';

part 'shoutbox_state.freezed.dart';

/// States for the shoutbox BLoC
@freezed
class ShoutboxState with _$ShoutboxState {
  /// Initial state
  const factory ShoutboxState.initial() = ShoutboxInitial;

  /// Loading state
  const factory ShoutboxState.loading() = ShoutboxLoading;

  /// Loaded state with messages
  const factory ShoutboxState.loaded({
    required List<ShoutboxMessage> messages,
    @Default(0) int lastMessageId,
    @Default(false) bool isPolling,
    @Default(false) bool isSending,
  }) = ShoutboxLoaded;

  /// API unavailable state (when endpoint returns 404)
  const factory ShoutboxState.apiUnavailable() = ShoutboxApiUnavailable;

  /// Error state
  const factory ShoutboxState.error({
    required String message,
    List<ShoutboxMessage>? previousMessages,
  }) = ShoutboxError;
}
