import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/shoutbox_bloc.dart';
import '../bloc/shoutbox_event.dart';
import '../bloc/shoutbox_state.dart';
import '../widgets/shoutbox_message_bubble.dart';
import '../widgets/shoutbox_input_field.dart';
import '../widgets/username_input_dialog.dart';

/// Main shoutbox page
class ShoutboxPage extends StatefulWidget {
  const ShoutboxPage({super.key});

  @override
  State<ShoutboxPage> createState() => _ShoutboxPageState();
}

class _ShoutboxPageState extends State<ShoutboxPage> {
  final ScrollController _scrollController = ScrollController();
  String? _username;
  bool _hasShownUsernameDialog = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _initializeShoutbox();
  }

  @override
  void dispose() {
    // Stop polling when page is disposed
    try {
      context.read<ShoutboxBloc>().add(const StopPolling());
    } catch (e) {
      // Ignore errors during dispose
    }
    _scrollController.dispose();
    super.dispose();
  }

  /// Load saved username from SharedPreferences
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('shoutbox_username');
    });
  }

  /// Save username to SharedPreferences
  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shoutbox_username', username);
    setState(() {
      _username = username;
    });
  }

  /// Initialize shoutbox by fetching initial messages
  void _initializeShoutbox() {
    try {
      // Fetch all messages first on initial load to avoid last_id issues
      // This ensures we get the complete message history without server-side bugs
      context.read<ShoutboxBloc>().add(const FetchMessages(afterId: 0));
    } catch (e) {
      // Ignore initialization errors
    }
  }

  /// Show username input dialog if username is not set
  void _showUsernameDialogIfNeeded() {
    if (_username == null && !_hasShownUsernameDialog) {
      _hasShownUsernameDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUsernameDialog();
      });
    }
  }

  /// Show username input dialog
  Future<void> _showUsernameDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UsernameInputDialog(),
    );

    if (result != null && result.isNotEmpty) {
      await _saveUsername(result);
    }
  }

  /// Handle send message
  void _handleSendMessage(String message) {
    if (_username == null || _username!.isEmpty) {
      _showUsernameDialog();
      return;
    }

    context.read<ShoutboxBloc>().add(
          SendMessage(
            username: _username!,
            message: message,
          ),
        );
  }

  /// Auto-scroll to bottom when new messages arrive
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // With reverse: true, 0.0 is the bottom (newest messages)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ShoutboxBloc, ShoutboxState>(
          builder: (context, state) {
            return Row(
              children: [
                Text('shoutbox_title'.tr()),
                if (state is ShoutboxLoaded && state.isPolling) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ShoutboxBloc>().add(const RefreshMessages());
            },
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: BlocConsumer<ShoutboxBloc, ShoutboxState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            loaded: (messages, lastMessageId, isPolling, isSending) {
              // Show username dialog if needed
              _showUsernameDialogIfNeeded();
              
              // Auto-scroll to bottom when new messages arrive
              if (messages.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
            },
            apiUnavailable: () {
              // Show a snackbar to inform user that shoutbox is unavailable
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('shoutbox_unavailable_message'.tr()),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            error: (message, previousMessages) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              // Messages list
              Expanded(
                child: state.when(
                  initial: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  apiUnavailable: () => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'shoutbox_unavailable'.tr(),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'shoutbox_unavailable_message'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ShoutboxBloc>().add(const RefreshMessages());
                          },
                          child: Text('shoutbox_retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                  loaded: (messages, lastMessageId, isPolling, isSending) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'shoutbox_empty_state'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'shoutbox_empty_state_subtitle'.tr(),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ShoutboxBloc>().add(const RefreshMessages());
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Show newest messages at bottom
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          // Reverse index to show newest at bottom
                          final message = messages[messages.length - 1 - index];
                          return ShoutboxMessageBubble(
                            message: message,
                          );
                        },
                      ),
                    );
                  },
                  error: (message, previousMessages) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'shoutbox_network_error'.tr(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ShoutboxBloc>().add(const RefreshMessages());
                            },
                            child: Text('shoutbox_retry'.tr()),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Input field
              BlocBuilder<ShoutboxBloc, ShoutboxState>(
                builder: (context, state) {
                  final isSending = state.maybeWhen(
                    loaded: (messages, lastMessageId, isPolling, isSending) => isSending,
                    orElse: () => false,
                  );

                  final isApiUnavailable = state.maybeWhen(
                    apiUnavailable: () => true,
                    orElse: () => false,
                  );

                  return ShoutboxInputField(
                    onSendMessage: _handleSendMessage,
                    isSending: isSending,
                    username: _username,
                    isDisabled: isApiUnavailable,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
