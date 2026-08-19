import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_assessment.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/assessment_result_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_assessment_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/quiz_result_args.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_quiz_result_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LectureQuizScreen extends StatefulWidget {
  const LectureQuizScreen({super.key, required this.lectureId});
  final String lectureId;

  @override
  State<LectureQuizScreen> createState() => _LectureQuizScreenState();
}

class _LectureQuizScreenState extends State<LectureQuizScreen> {
  late final LectureAssessmentBloc _assessmentBloc;
  late final AssessmentResultBloc _resultBloc;
  final Map<int, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _assessmentBloc = sl<LectureAssessmentBloc>()
      ..add(FetchAssessmentEvent(widget.lectureId));
    _resultBloc = sl<AssessmentResultBloc>();
  }

  @override
  void dispose() {
    _assessmentBloc.close();
    _resultBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _assessmentBloc),
        BlocProvider.value(value: _resultBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        appBar: AppBar(
          backgroundColor: AppColors.studentPrimary,
          foregroundColor: AppColors.white,
          title: Text(LocaleKeys.education_start_quiz.tr()),
        ),
        body: BlocListener<AssessmentResultBloc, AssessmentResultState>(
          listener: (context, resultState) {
            if (!resultState.isSuccess || resultState.data == null) return;
            final assessment = _assessmentBloc.state.data;
            if (assessment == null) return;
            context.pushReplacement(
              LectureQuizResultRoute.name,
              extra: QuizResultArgs(
                assessment: assessment,
                result: resultState.data!,
              ),
            );
          },
          child: BlocBuilder<LectureAssessmentBloc, LectureAssessmentState>(
            builder: (context, state) {
              if (state.isError) {
                return LectureErrorView(
                  message: state.errorMessage,
                  onRetry: () => _assessmentBloc.add(
                    FetchAssessmentEvent(widget.lectureId),
                  ),
                );
              }
              if (state.isLoading || state.isInit) {
                return const Center(child: CircularProgressIndicator());
              }
              final assessment = state.data;
              if (assessment == null) {
                return LectureEmptyView(
                  icon: LucideIcons.clipboardX,
                  message: LocaleKeys.education_no_quiz_available.tr(),
                );
              }
              return _QuizBody(
                assessment: assessment,
                selectedAnswers: _selectedAnswers,
                onSelect: (qIndex, choiceIndex) =>
                    setState(() => _selectedAnswers[qIndex] = choiceIndex),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.assessment,
    required this.selectedAnswers,
    required this.onSelect,
  });

  final LectureAssessment assessment;
  final Map<int, int> selectedAnswers;
  final void Function(int questionIndex, int choiceIndex) onSelect;

  @override
  Widget build(BuildContext context) {
    final allAnswered = selectedAnswers.length == assessment.questions.length;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: assessment.questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, qIndex) {
              final question = assessment.questions[qIndex];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${qIndex + 1}. ${question.question}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(question.choices.length, (choiceIndex) {
                      final selected =
                          selectedAnswers[qIndex] == choiceIndex;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onSelect(qIndex, choiceIndex),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.studentPrimary.withValues(alpha: 0.1)
                                  : AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColors.studentPrimary
                                    : AppColors.gray200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? LucideIcons.circleCheck
                                      : LucideIcons.circle,
                                  size: 18,
                                  color: selected
                                      ? AppColors.studentPrimary
                                      : AppColors.slate400,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    question.choices[choiceIndex],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.slate700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: BlocBuilder<AssessmentResultBloc, AssessmentResultState>(
              builder: (context, resultState) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.studentPrimary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: allAnswered && !resultState.isLoading
                      ? () {
                          final ordered = List.generate(
                            assessment.questions.length,
                            (i) => selectedAnswers[i]!,
                          );
                          context.read<AssessmentResultBloc>().add(
                            SubmitAnswersEvent(
                              assessmentId: assessment.id,
                              answers: ordered,
                            ),
                          );
                        }
                      : null,
                  child: resultState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(LocaleKeys.education_submit_answers.tr()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
