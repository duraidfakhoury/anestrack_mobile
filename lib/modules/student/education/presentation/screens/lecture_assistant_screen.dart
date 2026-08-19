import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// UI-only: no backend endpoint exists for chat/assistant yet.
class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

class LectureAssistantScreen extends StatefulWidget {
  const LectureAssistantScreen({super.key, required this.lectureId, this.lecture});
  final String lectureId;
  final Lecture? lecture;

  @override
  State<LectureAssistantScreen> createState() => _LectureAssistantScreenState();
}

class _LectureAssistantScreenState extends State<LectureAssistantScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isReplying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isReplying) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isReplying = true;
    });
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: LocaleKeys.education_assistant_not_available.tr(),
            isUser: false,
          ),
        );
        _isReplying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.purple600,
        foregroundColor: AppColors.white,
        title: Text(widget.lecture?.title ?? LocaleKeys.education_assistant_title.tr()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.sparkles,
                              size: 40,
                              color: AppColors.purple600,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              LocaleKeys.education_assistant_title.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final message = _messages[i];
                        return Align(
                          alignment: message.isUser
                              ? AlignmentDirectional.centerEnd
                              : AlignmentDirectional.centerStart,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? AppColors.purple600
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: message.isUser
                                  ? null
                                  : Border.all(color: AppColors.gray100),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: message.isUser
                                    ? AppColors.white
                                    : AppColors.slate700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: LocaleKeys.education_assistant_input_hint.tr(),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.gray200),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.purple600,
                    ),
                    onPressed: _send,
                    icon: const Icon(LucideIcons.send, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
