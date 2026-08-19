import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/quiz_result_args.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LectureQuizResultScreen extends StatelessWidget {
  const LectureQuizResultScreen({super.key, required this.args});
  final QuizResultArgs? args;

  @override
  Widget build(BuildContext context) {
    final args = this.args;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.education_quiz_result_title.tr())),
        body: Center(child: Text(LocaleKeys.education_no_result.tr())),
      );
    }

    final total = args.assessment.questions.length;
    final correct = args.result.correctCount;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.studentPrimary,
        foregroundColor: AppColors.white,
        title: Text(LocaleKeys.education_quiz_result_title.tr()),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '$correct / $total',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.studentPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${args.result.score.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 14, color: AppColors.slate500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(total, (i) {
            final question = args.assessment.questions[i];
            final selectedIndex =
                i < args.result.answers.length ? args.result.answers[i] : -1;
            final isCorrect = selectedIndex == question.correctAnswerIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCorrect ? AppColors.green : AppColors.red200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? LucideIcons.circleCheck : LucideIcons.circleX,
                        size: 18,
                        color: isCorrect ? AppColors.green : AppColors.red600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${i + 1}. ${question.question}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(question.choices.length, (choiceIndex) {
                    final isTheCorrectChoice =
                        choiceIndex == question.correctAnswerIndex;
                    final isSelected = choiceIndex == selectedIndex;
                    Color? bg;
                    if (isTheCorrectChoice) {
                      bg = AppColors.greenAccent;
                    } else if (isSelected && !isCorrect) {
                      bg = AppColors.red100;
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        question.choices[choiceIndex],
                        style: const TextStyle(fontSize: 12, color: AppColors.slate700),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.studentPrimary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => context.pop(),
              child: Text(LocaleKeys.education_back_to_lecture.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
