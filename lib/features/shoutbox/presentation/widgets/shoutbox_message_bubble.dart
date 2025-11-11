import 'package:flutter/material.dart';
import 'dart:math';
import '../../domain/entities/shoutbox_message.dart';

/// Widget for displaying a single shoutbox message
class ShoutboxMessageBubble extends StatelessWidget {
  final ShoutboxMessage message;

  const ShoutboxMessageBubble({
    super.key,
    required this.message,
  });

  /// Generate a consistent color for the username
  /// Avoids red (reserved for admin) and uses safe colors
  Color _generateAvatarColor(String username) {
    if (username.isEmpty) return Colors.grey;
    
    // Create a deterministic seed from username
    final seed = username.hashCode;
    final random = Random(seed);
    
    // Define safe colors (avoiding red and very dark colors)
    final safeColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.brown,
      Colors.blueGrey,
    ];
    
    return safeColors[random.nextInt(safeColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = message.isAdmin;
    final avatarColor = isAdmin ? Colors.red : _generateAvatarColor(message.username);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: avatarColor,
            child: Text(
              message.username.isNotEmpty ? message.username[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and timestamp
                Row(
                  children: [
                    Text(
                      message.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAdmin ? Colors.red : avatarColor,
                        fontSize: 14,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      message.exactTimeDisplay,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Message text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: avatarColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit/Delete functionality disabled
        ],
      ),
    );
  }

}
