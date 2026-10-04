import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/my_documents_screen.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/home_screen.dart';
import 'package:well_trust_mobile_app/features/messages/data/model/message_thread.dart';
import 'package:well_trust_mobile_app/features/messages/presentation/state/providers/message_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = [...ref.watch(messagesProvider).threads]
      ..sort((a, b) => b.lastAt.compareTo(a.lastAt));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'Messages', messagesActive: true),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                children: [
                  DesignButton(
                    'New message to the office',
                    onPressed: () =>
                        navigateToRoute(context, const NewMessagePage()),
                  ),
                  addVerticalSpacing(2.13),
                  if (threads.isEmpty)
                    const _EmptyMessages()
                  else
                    ...threads.map(
                      (thread) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MessageTile(
                          thread: thread,
                          onTap: () => navigateToRoute(
                            context,
                            MessageThreadPage(threadId: thread.id),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final MessageThread thread;
  final VoidCallback onTap;

  const _MessageTile({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final last = thread.lastEntry;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(
                  color: thread.unread ? AppColors.gold : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              addHorizontalSpacing(3.08),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            text: thread.party,
                            type: AppTextType.bodySmall,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        addHorizontalSpacing(2.05),
                        AppText(
                          text: _messageWhen(thread.lastAt),
                          type: AppTextType.labelLarge,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                    addVerticalSpacing(0.24),
                    AppText(
                      text: thread.subject,
                      type: AppTextType.bodySmall,
                      color: AppColors.ink,
                      fontWeight: thread.unread
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    addVerticalSpacing(0.24),
                    AppText(
                      text: '${last.mine ? 'You: ' : ''}${last.body}',
                      type: AppTextType.bodySmall,
                      color: AppColors.muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      child: Column(
        children: [
          AppText(
            text: 'No messages',
            type: AppTextType.bodySmall,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(0.59),
          AppText(
            text: 'Messages from the office appear here.',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MessageThreadPage extends ConsumerStatefulWidget {
  final String threadId;

  const MessageThreadPage({super.key, required this.threadId});

  @override
  ConsumerState<MessageThreadPage> createState() => _MessageThreadPageState();
}

class _MessageThreadPageState extends ConsumerState<MessageThreadPage> {
  final replyController = TextEditingController();
  String? error;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(messagesProvider.notifier).markRead(widget.threadId),
    );
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<void> sendReply() async {
    if (replyController.text.trim().isEmpty) {
      setState(() => error = 'Write a reply.');
      return;
    }
    try {
      await ref
          .read(messagesProvider.notifier)
          .reply(widget.threadId, replyController.text);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
      return;
    }
    replyController.clear();
    setState(() => error = null);
  }

  void openAction(MessageThread thread) {
    if (thread.actionRoute == 'rota') {
      navigateAndRemoveUntilRoute(context, const HomeScreenPage(imdex: 1));
    } else if (thread.actionRoute == 'documents') {
      navigateToRoute(context, const DocumentsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(messagesProvider).threads;
    MessageThread? thread;
    for (final item in threads) {
      if (item.id == widget.threadId) {
        thread = item;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(
            title: 'Message',
            showBack: true,
            messagesActive: true,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: thread == null
                  ? Center(
                      child: AppText(
                        text: 'Message not found.',
                        type: AppTextType.bodySmall,
                        color: AppColors.muted,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                      children: [
                        AppText(
                          text: thread.subject,
                          type: AppTextType.titleMedium,
                          color: AppColors.ink,
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w700,
                        ),
                        addVerticalSpacing(0.24),
                        AppText(
                          text: 'With ${thread.party}',
                          type: AppTextType.bodySmall,
                          color: AppColors.muted,
                        ),
                        if (thread.actionLabel != null) ...[
                          addVerticalSpacing(2.13),
                          DesignButton(
                            thread.actionLabel!,
                            secondary: true,
                            onPressed: () => openAction(thread!),
                          ),
                        ],
                        addVerticalSpacing(2.13),
                        for (final entry in thread.entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MessageBubble(entry: entry),
                          ),
                        addVerticalSpacing(0.95),
                        DesignCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: 'Reply',
                                type: AppTextType.bodySmall,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                              addVerticalSpacing(0.71),
                              GlobalTextField(
                                fieldName: 'Type your reply...',
                                keyBoardType: TextInputType.multiline,
                                textController: replyController,
                                minLines: 3,
                                maxLines: 5,
                                maxLength: 1000,
                                removeSpace: false,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (_) {
                                  if (error != null) {
                                    setState(() => error = null);
                                  }
                                },
                              ),
                              if (error != null) ...[
                                addVerticalSpacing(1.18),
                                AppText(
                                  text: error!,
                                  type: AppTextType.bodySmall,
                                  color: AppColors.rose,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                              addVerticalSpacing(1.66),
                              DesignButton('Send reply', onPressed: sendReply),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntry entry;

  const _MessageBubble({required this.entry});

  @override
  Widget build(BuildContext context) {
    final foreground = entry.mine ? AppColors.onPrimary : AppColors.ink;
    return Align(
      alignment: entry.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: entry.mine ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: entry.mine ? Colors.transparent : AppColors.line,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(entry.mine ? 16 : 4),
            bottomRight: Radius.circular(entry.mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: entry.body,
              type: AppTextType.bodySmall,
              color: foreground,
            ),
            addVerticalSpacing(0.47),
            AppText(
              text: DateFormat('d MMM, HH:mm').format(entry.at),
              type: AppTextType.labelMedium,
              color: foreground.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}

class NewMessagePage extends ConsumerStatefulWidget {
  const NewMessagePage({super.key});

  @override
  ConsumerState<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends ConsumerState<NewMessagePage> {
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();
  String? recipient;
  String? error;

  @override
  void dispose() {
    subjectController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (recipient == null ||
        subjectController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty) {
      setState(() => error = 'Choose who to message and complete each field.');
      return;
    }
    late final String id;
    try {
      id = await ref
          .read(messagesProvider.notifier)
          .compose(
            to: recipient!,
            subject: subjectController.text,
            body: bodyController.text,
          );
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
      return;
    }
    if (!mounted) return;
    navigateAndReplaceRoute(context, MessageThreadPage(threadId: id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(
            title: 'New message',
            showBack: true,
            messagesActive: true,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                children: [
                  DesignCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('To'),
                        GlobalSearchableDropdown<String>(
                          title: 'Choose who to message',
                          hintText: 'Choose who to message',
                          value: recipient,
                          options: const [
                            SearchableDropdownOption(
                              value: 'Management',
                              label: 'Management',
                            ),
                            SearchableDropdownOption(
                              value: 'Admin',
                              label: 'Admin',
                            ),
                            SearchableDropdownOption(
                              value: 'Office',
                              label: 'Office',
                            ),
                          ],
                          onChanged: (value) => setState(() {
                            recipient = value;
                            error = null;
                          }),
                        ),
                        addVerticalSpacing(1.90),
                        const _FieldLabel('Subject'),
                        GlobalTextField(
                          fieldName: 'Subject',
                          keyBoardType: TextInputType.text,
                          textController: subjectController,
                          maxLength: 80,
                          removeSpace: false,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => setState(() => error = null),
                        ),
                        addVerticalSpacing(1.90),
                        const _FieldLabel('Message'),
                        GlobalTextField(
                          fieldName: 'Message',
                          keyBoardType: TextInputType.multiline,
                          textController: bodyController,
                          minLines: 6,
                          maxLines: 8,
                          maxLength: 2000,
                          removeSpace: false,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => setState(() => error = null),
                        ),
                        if (error != null) ...[
                          addVerticalSpacing(1.42),
                          AppText(
                            text: error!,
                            type: AppTextType.bodySmall,
                            color: AppColors.rose,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                        addVerticalSpacing(2.37),
                        DesignButton('Send message', onPressed: send),
                      ],
                    ),
                  ),
                  addVerticalSpacing(0.95),
                  AppText(
                    text:
                        'For anything urgent, call the office. Messages are not read straight away.',
                    type: AppTextType.labelLarge,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AppText(
        text: text,
        type: AppTextType.bodySmall,
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

String _messageWhen(DateTime at) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(at.year, at.month, at.day);
  if (date == today) return DateFormat('HH:mm').format(at);
  if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('d MMM').format(at);
}
