import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/get_shoutbox_messages.dart';
import '../../domain/usecases/send_shoutbox_message.dart';
import '../../domain/usecases/delete_shoutbox_message.dart';
import '../../domain/entities/shoutbox_message.dart';
import 'shoutbox_event.dart';
import 'shoutbox_state.dart';

/// BLoC for managing shoutbox state and operations
class ShoutboxBloc extends Bloc<ShoutboxEvent, ShoutboxState> {
  final GetShoutboxMessages _getMessages;
  final SendShoutboxMessage _sendMessage;
  final DeleteShoutboxMessage _deleteMessage;

  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 3);

  ShoutboxBloc({
    required GetShoutboxMessages getMessages,
    required SendShoutboxMessage sendMessage,
    required DeleteShoutboxMessage deleteMessage,
  })  : _getMessages = getMessages,
        _sendMessage = sendMessage,
        _deleteMessage = deleteMessage,
        super(const ShoutboxState.initial()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<RefreshMessages>(_onRefreshMessages);
    on<ClearMessages>(_onClearMessages);
  }

  /// Handle fetch messages event
  Future<void> _onFetchMessages(
    FetchMessages event,
    Emitter<ShoutboxState> emit,
  ) async {
    try {
      final currentState = state;
      
      // Only show loading if we don't have existing messages (initial load)
      // Don't show loading if we already have messages and this is just a refresh
      if (currentState is! ShoutboxLoading) {
        if (currentState is! ShoutboxLoaded || currentState.messages.isEmpty) {
          emit(const ShoutboxState.loading());
        }
      }
      final result = await _getMessages(
        afterId: event.afterId,
        limit: event.limit,
      );

      result.fold(
        (failure) {
          // Check if this is an API unavailable error
          if (failure.message.contains('API endpoint not available') || 
              failure.message.contains('Shoutbox is currently unavailable')) {
            emit(const ShoutboxState.apiUnavailable());
          } else {
            emit(ShoutboxState.error(
              message: failure.message,
              previousMessages: _getCurrentMessages(),
            ));
          }
        },
        (messages) {
          final currentState = state;
          List<ShoutboxMessage> allMessages = messages;

          // If afterId = 0, this is a full refresh - replace all messages
          // If afterId > 0, this is incremental loading (polling) - merge with existing messages
          if (currentState is ShoutboxLoaded && event.afterId > 0) {
            allMessages = [...currentState.messages, ...messages];
          }

          // Remove duplicates based on ID
          allMessages = _removeDuplicateMessages(allMessages);

          // Sort by ID (chronological order)
          allMessages.sort((a, b) => a.id.compareTo(b.id));

          // Limit to last 100 messages for performance
          if (allMessages.length > 100) {
            allMessages = allMessages.skip(allMessages.length - 100).toList();
          }

          final lastMessageId = allMessages.isNotEmpty ? allMessages.last.id : 0;

          final isPolling = currentState is ShoutboxLoaded ? currentState.isPolling : false;
          emit(ShoutboxState.loaded(
            messages: allMessages,
            lastMessageId: lastMessageId,
            isPolling: isPolling,
            isSending: false,
          ));

          // Auto-start polling if not already polling and we have messages
          if (!isPolling && allMessages.isNotEmpty) {
            add(const StartPolling());
          }
        },
      );
    } catch (e) {
      // Check if this is an API unavailable exception
      if (e is ApiUnavailableException) {
        emit(const ShoutboxState.apiUnavailable());
      } else {
        emit(ShoutboxState.error(
          message: '${'shoutbox_unexpected_error'.tr()}: ${e.toString()}',
          previousMessages: _getCurrentMessages(),
        ));
      }
    }
  }

  /// Handle send message event
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ShoutboxState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ShoutboxLoaded) return;

    emit(currentState.copyWith(isSending: true));

    try {
      final result = await _sendMessage(
        username: event.username,
        message: event.message,
      );

      result.fold(
        (failure) {
          emit(ShoutboxState.error(
            message: failure.message,
            previousMessages: currentState.messages,
          ));
        },
        (newMessage) {
          // Add the new message to the list
          final updatedMessages = [...currentState.messages, newMessage];
          
          // Sort by ID and limit to 100 messages
          updatedMessages.sort((a, b) => a.id.compareTo(b.id));
          final limitedMessages = updatedMessages.length > 100
              ? updatedMessages.skip(updatedMessages.length - 100).toList()
              : updatedMessages;

          emit(ShoutboxState.loaded(
            messages: limitedMessages,
            lastMessageId: newMessage.id,
            isPolling: currentState.isPolling,
            isSending: false,
          ));
        },
      );
    } catch (e) {
      emit(ShoutboxState.error(
        message: 'Unexpected error: ${e.toString()}',
        previousMessages: currentState.messages,
      ));
    }
  }

  /// Handle delete message event
  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ShoutboxState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ShoutboxLoaded) return;

    try {
      final result = await _deleteMessage(event.messageId);

      result.fold(
        (failure) => emit(ShoutboxState.error(
          message: failure.message,
          previousMessages: currentState.messages,
        )),
        (successMessage) {
          // Remove the deleted message from the list
          final updatedMessages = currentState.messages
              .where((message) => message.id != event.messageId)
              .toList();

          emit(currentState.copyWith(messages: updatedMessages));
        },
      );
    } catch (e) {
      emit(ShoutboxState.error(
        message: 'Unexpected error: ${e.toString()}',
        previousMessages: currentState.messages,
      ));
    }
  }

  /// Handle start polling event
  void _onStartPolling(
    StartPolling event,
    Emitter<ShoutboxState> emit,
  ) {
    final currentState = state;
    if (currentState is! ShoutboxLoaded || currentState.isPolling) return;

    // Start polling timer
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      if (!isClosed) {
        // Get the current state's lastMessageId, not the one from when polling started
        final currentState = state;
        if (currentState is ShoutboxLoaded) {
          add(FetchMessages(afterId: currentState.lastMessageId));
        }
      }
    });

    emit(currentState.copyWith(isPolling: true));
  }

  /// Handle stop polling event
  void _onStopPolling(
    StopPolling event,
    Emitter<ShoutboxState> emit,
  ) {
    final currentState = state;
    if (currentState is! ShoutboxLoaded || !currentState.isPolling) return;

    // Stop polling timer
    _pollingTimer?.cancel();
    _pollingTimer = null;

    emit(currentState.copyWith(isPolling: false));
  }

  /// Handle refresh messages event
  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<ShoutboxState> emit,
  ) async {
    // Always show loading for manual refresh
    emit(const ShoutboxState.loading());
    add(const FetchMessages(afterId: 0));
  }

  /// Handle clear messages event
  void _onClearMessages(
    ClearMessages event,
    Emitter<ShoutboxState> emit,
  ) {
    emit(const ShoutboxState.initial());
  }

  /// Get current messages from state
  List<ShoutboxMessage> _getCurrentMessages() {
    final currentState = state;
    if (currentState is ShoutboxLoaded) {
      return currentState.messages;
    }
    return [];
  }

  /// Remove duplicate messages based on ID
  List<ShoutboxMessage> _removeDuplicateMessages(List<ShoutboxMessage> messages) {
    final seen = <int>{};
    return messages.where((message) => seen.add(message.id)).toList();
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
