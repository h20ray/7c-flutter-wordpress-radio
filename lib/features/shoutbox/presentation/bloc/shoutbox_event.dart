import 'package:freezed_annotation/freezed_annotation.dart';

part 'shoutbox_event.freezed.dart';

/// Events for the shoutbox BLoC
@freezed
class ShoutboxEvent with _$ShoutboxEvent {
  /// Fetch messages from the server
  const factory ShoutboxEvent.fetchMessages({
    @Default(0) int afterId,
    @Default(50) int limit,
  }) = FetchMessages;

  /// Send a new message
  const factory ShoutboxEvent.sendMessage({
    required String username,
    required String message,
  }) = SendMessage;

  /// Delete a message (admin only)
  const factory ShoutboxEvent.deleteMessage(int messageId) = DeleteMessage;

  /// Start polling for new messages
  const factory ShoutboxEvent.startPolling() = StartPolling;

  /// Stop polling for new messages
  const factory ShoutboxEvent.stopPolling() = StopPolling;

  /// Refresh messages (pull-to-refresh)
  const factory ShoutboxEvent.refreshMessages() = RefreshMessages;

  /// Clear all messages from state
  const factory ShoutboxEvent.clearMessages() = ClearMessages;
}
