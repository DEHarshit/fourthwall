import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'category_management_page.dart';
import 'view_question_paper_list_page.dart';

class QuestionsScreen extends ConsumerWidget {
  final String name;

  const QuestionsScreen({
    Key? key,
    required this.name,
  }) : super(key: key);

  void navToCategory(BuildContext context) {
    Routemaster.of(context).push('/$name/question-paper/category');
  }

  void navToAddQuestion(BuildContext context) {
    Routemaster.of(context).push('/$name/question-paper/add');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, List<String>> questionPapersByCategory = {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Paper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_file),
                      title: const Text('Upload Question Paper'),
                      onTap: () {
                        navToAddQuestion(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Add Category'),
                      onTap: () {
                        navToCategory(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ViewQuestionPaperListPage(name: name
      ),
    );
  }
}
