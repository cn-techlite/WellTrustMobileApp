import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class ChatMessageModel {
  final String initials;
  final String senderName;
  final String time;
  final String text;
  final bool isMe;

  ChatMessageModel({
    required this.initials,
    required this.senderName,
    required this.time,
    required this.text,
    required this.isMe,
  });
}

class MessagesBottomSheet extends StatefulWidget {
  const MessagesBottomSheet({super.key});

  @override
  State<MessagesBottomSheet> createState() => _MessagesBottomSheetState();
}

class _MessagesBottomSheetState extends State<MessagesBottomSheet> {
  final messageController = TextEditingController();

  final messages = [
    ChatMessageModel(
      initials: "MR",
      senderName: "Maria Reyes",
      time: "08:14",
      text:
          "Morning Samir — Mrs Henderson's bath visit is going to be tricky today. She was anxious yesterday. Take your time, no pressure on the next visit.",
      isMe: false,
    ),
    ChatMessageModel(
      initials: "SO",
      senderName: "You",
      time: "08:16",
      text: "Will do. I'll add a calming routine note for next carer.",
      isMe: true,
    ),
    ChatMessageModel(
      initials: "MR",
      senderName: "Maria Reyes",
      time: "08:17",
      text:
          "Brilliant, thank you. Also — Mr Davies's wife called. He had a wobbly night. Please give them extra time at the morning call.",
      isMe: false,
    ),
    ChatMessageModel(
      initials: "JL",
      senderName: "Jenna L.",
      time: "11:32",
      text:
          "Sam I'm running 10 min late to Mrs O'Connor — traffic on the A14. Could you flex your lunch round to start with Mrs Patel first?",
      isMe: false,
    ),
  ];

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessageModel(
          initials: "SO",
          senderName: "You",
          time: "Now",
          text: text,
          isMe: true,
        ),
      );
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * .92,
        decoration: const BoxDecoration(
          color: Color(0xfffbfaf7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            addVerticalSpacing(1),
            Container(
              width: 62,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffd7d0bf),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "💬 Messages",
                          color: AppColors.black,
                          type: AppTextType.titleLarge,
                          fontWeight: FontWeight.w800,
                        ),
                        SizedBox(height: 6),
                        AppText(
                          text: "Chat with co-ordinator and fellow carers",
                          color: Color(0xff8a877f),
                          type: AppTextType.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xfffaf8f3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 1, color: const Color(0xffded6c7)),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _ChatBubble(message: messages[index]);
                },
              ),
            ),

            _MessageInputBar(
              controller: messageController,
              onSend: sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isMe) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .68,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff24447f),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AppText(
                      text: message.text,
                      color: Colors.white,
                      type: AppTextType.bodyMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  addVerticalSpacing(1),
                  AppText(
                    text: "${message.senderName} · ${message.time}",
                    color: const Color(0xff8a877f),
                    type: AppTextType.bodySmall,
                  ),
                ],
              ),
            ),
            addHorizontalSpacing(2),
            _ChatAvatar(
              initials: message.initials,
              color: const Color(0xff24447f),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChatAvatar(
            initials: message.initials,
            color: const Color(0xffbd9650),
          ),
          addHorizontalSpacing(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .68,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffded6c7)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AppText(
                    text: message.text,
                    color: AppColors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                addVerticalSpacing(1),
                AppText(
                  text: "${message.senderName} · ${message.time}",
                  color: const Color(0xff8a877f),
                  type: AppTextType.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  final String initials;
  final Color color;

  const _ChatAvatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: AppText(
        text: initials,
        color: Colors.white,
        type: AppTextType.bodySmall,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GlobalTextField(
              textController: controller,
              fieldName: "Type a message...",
              keyBoardType: TextInputType.text,
            ),
          ),
          addHorizontalSpacing(2),
          SizedBox(
            width: 96,
            child: AppButton(
              text: "Send",
              onPressed: onSend,
              btnColor: const Color(0xff24447f),
              textColor: Colors.white,
              borderRadius: 14,
            ),
          ),
        ],
      ),
    );
  }
}
