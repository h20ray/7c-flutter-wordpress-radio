import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget for inputting shoutbox messages
class ShoutboxInputField extends StatefulWidget {
  final Function(String message) onSendMessage;
  final bool isSending;
  final String? username;
  final bool isDisabled;

  const ShoutboxInputField({
    super.key,
    required this.onSendMessage,
    required this.isSending,
    this.username,
    this.isDisabled = false,
  });

  @override
  State<ShoutboxInputField> createState() => _ShoutboxInputFieldState();
}

class _ShoutboxInputFieldState extends State<ShoutboxInputField> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Send message
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && !widget.isSending && !widget.isDisabled) {
      widget.onSendMessage(message);
      _messageController.clear();
      _focusNode.unfocus();
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUsername = widget.username != null && widget.username!.isNotEmpty;

    return Column(
      children: [
        // Username indicator
        if (!hasUsername)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.errorContainer,
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.onErrorContainer,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'shoutbox_username_required'.tr(),
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        // API unavailable indicator
        if (widget.isDisabled)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'shoutbox_unavailable_short'.tr(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        // Input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              // Message input row
              Row(
                children: [
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      enabled: hasUsername && !widget.isSending && !widget.isDisabled,
                      maxLines: null,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.isDisabled
                            ? 'shoutbox_unavailable_hint'.tr()
                            : hasUsername
                                ? 'shoutbox_message_placeholder'.tr()
                                : 'shoutbox_set_username_hint'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: widget.isDisabled
                            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                            : theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        counterText: '', // Hide character counter
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: hasUsername && !widget.isSending && !widget.isDisabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: hasUsername && !widget.isSending && !widget.isDisabled ? _sendMessage : null,
                      icon: widget.isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: hasUsername && !widget.isSending && !widget.isDisabled
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                      tooltip: widget.isDisabled ? 'shoutbox_unavailable_hint'.tr() : 'shoutbox_send'.tr(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
