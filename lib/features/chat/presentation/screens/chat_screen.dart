import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ChatScreen({super.key, required this.orderId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _messageController.clear();

    final sendMessageUseCase = ref.read(sendMessageUseCaseProvider);
    await sendMessageUseCase(
      orderId: widget.orderId,
      senderId: user.id,
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.orderId));
    final orderAsync = ref.watch(orderDetailsProvider(widget.orderId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: orderAsync.when(
          data: (order) {
            String title = l10n.chat;
            if (order != null) {
              title = currentUser?.role == 'provider'
                  ? l10n.customer
                  : l10n.provider;
              title += ' #${order.id.substring(0, 4).toUpperCase()}';
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (order != null) _chatStatusBadge(context, order.status),
              ],
            );
          },
          loading: () => Text(l10n.loading),
          error: (e, s) => Text(l10n.chat),
        ),
      ),
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.03),
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noMessagesYet,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(l10n.startConversation),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 80,
                        bottom: 20,
                        left: 16,
                        right: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUser?.id;
                        return _MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text(l10n.anErrorOccurred(err.toString()))),
                ),
              ),

              // Input Field
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surface
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: l10n.typeAMessage,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chatStatusBadge(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    String statusText;
    switch (status) {
      case 'pending':
        statusText = l10n.statusPending;
        break;
      case 'accepted':
        statusText = l10n.statusAccepted;
        break;
      case 'picked_up':
        statusText = l10n.statusPickedUp;
        break;
      case 'delivered':
        statusText = l10n.statusDelivered;
        break;
      default:
        statusText = l10n.statusUnknown;
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : (isDark ? theme.colorScheme.surface : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: !isMe
                    ? Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : theme.colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
