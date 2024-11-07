import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialwall/controller/posts_controller.dart';
import 'package:socialwall/controller/question_controller.dart';
import 'package:socialwall/pages/comp/comment.card.dart';
import 'package:socialwall/pages/comp/error_text.dart';
import 'package:socialwall/pages/comp/loader.dart';
import 'package:socialwall/pages/comp/post_card.dart';
import 'package:socialwall/models/comment_model.dart';
import 'package:socialwall/pages/questionpaper/question_card.dart';

class QuestionCommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const QuestionCommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuestionCommentsScreenState();
}

class _QuestionCommentsScreenState extends ConsumerState<QuestionCommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(String postId) {
    final question = ref.read(getQuestionByIdProvider(postId)).requireValue;
    String type = 'post';
    ref.read(questionControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          question: question,
          type: type,
        );
    setState(() {
      commentController.text = '';
    });
  }


  CommentCard displayComments(Comment comment) {
    return CommentCard(comment: comment,depth: 0);
  }

  /* 
  Expanded(
        child: Column(children: [
      CommentCard(comment: comment),
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            final comment = data[index];
            return (CommentCard(comment: comment));
          },
        ),
      ),
    ]));
    
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getQuestionByIdProvider(widget.postId)).when(
            data: (data) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverPadding(
                    padding: const EdgeInsets.all(0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          QuestionCard(question: data),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: ref.watch(getQuestionCommentsProvider(widget.postId)).when(
                    data: (data) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Comments . . .',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (data.isEmpty)
                              const Center(child: Text('No comments yet.'))
                            else
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final comment = data[index];
                                    return displayComments(comment);
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    error: (error, stackTrace) => ErrorText(
                      error: error.toString(),
                    ),
                    loading: () => const Loader(),
                  ),
            ),
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          alignment: Alignment.center,
          height: 45,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            border: Border.all(
              color: Colors.blueAccent,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: SizedBox(
                  height: 35,
                  width: 50,
                  child: TextField(
                    style: const TextStyle(fontSize: 15),
                    controller: commentController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'What are your thoughts?',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  child: IconButton(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 7),
                      onPressed: () => addComment(widget.postId),
                      icon: const Icon(Icons.send))),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}
