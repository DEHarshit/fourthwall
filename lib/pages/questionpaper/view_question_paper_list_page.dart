import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialwall/controller/question_controller.dart';
import 'package:socialwall/pages/questionpaper/question_card.dart';


class ViewQuestionPaperListPage extends ConsumerWidget {
  final String name;

  const ViewQuestionPaperListPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionPapersStream = ref.watch(getCommunityQuestionsProvider(name));

    return Scaffold(
      body: questionPapersStream.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No question papers available.'));
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return QuestionCard(question: question);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
