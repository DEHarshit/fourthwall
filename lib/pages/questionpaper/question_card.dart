import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:socialwall/controller/auth_controller.dart';
import 'package:socialwall/controller/question_controller.dart';
import 'package:socialwall/core/constants/constants.dart';
import 'package:socialwall/models/question_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pdf_view_page.dart';

class QuestionCard extends ConsumerWidget {
  final Question question;
  const QuestionCard({
    Key? key,
    required this.question,
  }) : super(key: key);

  void navToComments(BuildContext context, String questionId) {
    Routemaster.of(context).push('/question/$questionId/comments');
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(questionControllerProvider.notifier).upvote(question);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(questionControllerProvider.notifier).downvote(question);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return GestureDetector(
      onTap: () => navToComments(context, question.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        question.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Text(
                        'Subject: ${question.type}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Date: ${question.date}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Posted by ${question.username}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ), 
            ),
            const Divider(thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upvotes, Downvotes, and Comments
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Constants.up,
                            size: 25,
                            color: question.upvotes.contains(user.uid)
                                ? Colors.red
                                : null),
                        onPressed: () => upvotePost(ref),
                      ),
                      Text(
                        '${question.upvotes.length - question.downvotes.length == 0 ? '0' : question.upvotes.length - question.downvotes.length}',
                        style: const TextStyle(fontSize: 17),
                      ),
                      IconButton(
                        icon: Icon(Constants.down,
                            size: 25,
                            color: question.downvotes.contains(user.uid)
                                ? Colors.blue
                                : null),
                        onPressed: () => downvotePost(ref),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.comment),
                        onPressed: () => navToComments(context, question.id),
                      ),
                      Text('${question.commentCount}'),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          try {
                            final filePath = await downloadPDF(question.link);
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PDFViewPage(pdfUrl: filePath),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to download file: $e')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'View PDF',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> downloadPDF(String url) async {
    try {
      Dio dio = Dio();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String fileName = url.split('/').last;
      String filePath = '$tempPath/$fileName';

      await dio.download(url, filePath);
      return filePath;
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }
}
