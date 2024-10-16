import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialwall/controller/posts_controller.dart';
import 'package:socialwall/pages/comp/comment.card.dart';
import 'package:socialwall/pages/comp/error_text.dart';
import 'package:socialwall/pages/comp/loader.dart';
import 'package:socialwall/pages/comp/post_card.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(String postId) {
    final post = ref.read(getPostByIdProvider(postId)).requireValue;
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverPadding(
                    padding: const EdgeInsets.all(0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          PostCard(post: data),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: ref.watch(getPostCommentsProvider(widget.postId)).when(
                    data: (data) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final comment = data[index];
                          return CommentCard(comment: comment);
                        },
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
          color: Colors.blueAccent,
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
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'What are your thoughts?',
                      filled: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                  child: IconButton(
                    alignment: Alignment.topCenter,
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
