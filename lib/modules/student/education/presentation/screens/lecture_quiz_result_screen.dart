import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/assessment_result.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/assessment_review_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/quiz_result_args.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LectureQuizResultScreen extends StatefulWidget {
  const LectureQuizResultScreen({super.key, required this.args});
  final QuizResultArgs? args;

  @override
  State<LectureQuizResultScreen> createState() =>
      _LectureQuizResultScreenState();
}

class _LectureQuizResultScreenState extends State<LectureQuizResultScreen> {
  late final AssessmentReviewBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<AssessmentReviewBloc>();
    final args = widget.args;
    if (args != null) {
      _bloc.add(FetchAssessmentResultEvent(assessmentId: args.assessment.id));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.studentPrimary,
        foregroundColor: AppColors.white,
        title: Text(LocaleKeys.education_quiz_result_title.tr()),
        automaticallyImplyLeading: false,
      ),
      body: args == null
          ? Center(child: Text(LocaleKeys.education_no_result.tr()))
          : BlocBuilder<AssessmentReviewBloc, AssessmentReviewState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state.isLoading || state.isInit) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.isError) {
                  return LectureErrorView(
                    message: state.errorMessage,
                    onRetry: () => _bloc.add(
                      FetchAssessmentResultEvent(
                        assessmentId: args.assessment.id,
                      ),
                    ),
                  );
                }
                final review = state.data;
                if (review == null) {
                  return Center(child: Text(LocaleKeys.education_no_result.tr()));
                }
                return _ResultBody(
                  assessment: args.assessment,
                  review: review,
                );
              },
            ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.assessment, required this.review});
  final LectureAssessment assessment;
  final AssessmentResult review;

  @override
  Widget build(BuildContext context) {
    final total = review.totalQuestions > 0
        ? review.totalQuestions
        : assessment.questions.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              Text(
                '${review.correctCount} / $total',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.studentPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${review.percentage.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 14, color: AppColors.slate500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(review.breakdown.length, (i) {
          final item = review.breakdown[i];
          final choices = item.index < assessment.questions.length
              ? assessment.questions[item.index].choices
              : const <String>[];
          return _BreakdownCard(
            number: item.index + 1,
            question: item.question,
            choices: choices,
            selectedIndex: item.selectedIndex,
            correctAnswerIndex: item.correctAnswerIndex,
            isCorrect: item.isCorrect,
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
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.number,
    required this.question,
    required this.choices,
    required this.selectedIndex,
    required this.correctAnswerIndex,
    required this.isCorrect,
  });

  final int number;
  final String question;
  final List<String> choices;
  final int? selectedIndex;
  final int correctAnswerIndex;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCorrect ? LucideIcons.circleCheck : LucideIcons.circleX,
                size: 18,
                color: isCorrect ? AppColors.green : AppColors.red600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$number. $question',
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
          ...List.generate(choices.length, (choiceIndex) {
            final isTheCorrectChoice = choiceIndex == correctAnswerIndex;
            final isSelected = choiceIndex == selectedIndex;
            Color? bg;
            if (isTheCorrectChoice) {
              bg = AppColors.greenAccent;
            } else if (isSelected && !isCorrect) {
              bg = AppColors.red100;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                choices[choiceIndex],
                style: const TextStyle(fontSize: 12, color: AppColors.slate700),
              ),
            );
          }),
          if (selectedIndex == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                LocaleKeys.education_unanswered.tr(),
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.slate400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
