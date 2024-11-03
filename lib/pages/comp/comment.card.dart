import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialwall/core/constants/constants.dart';
import 'package:socialwall/models/comment_model.dart';
import 'package:socialwall/controller/posts_controller.dart';
import 'package:socialwall/pages/comp/error_text.dart';
import 'package:socialwall/pages/comp/loader.dart';
import "package:routemaster/routemaster.dart";
import 'package:socialwall/controller/auth_controller.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final int depth;
  final int limit;
  final String type;

  const CommentCard({
    super.key,
    required this.comment,
    required this.depth,
    this.limit = 4,
    this.type = 'Post',
  });

  void upvoteComm(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvoteComm(comment);
  }

  void downvoteComm(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvoteComm(comment);
  }

  void navToAddComment(BuildContext context, String commentId) {
    Routemaster.of(context)
        .push('/post/${comment.postId}/comments/${commentId}');
  }

  Widget displayComments(BuildContext context, Comment comment, int depth,
      String type, int limit) {
    if (type == 'Post') {
      if (depth >= limit) {
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => navToAddComment(context, comment.id),
                child: const Text('View All Replies'),
              ),
            ),
          ],
        );
      }
      return CommentCard(comment: comment, depth: depth + 1);
    } else if (type == 'Comment') {
      if (depth >= limit) {
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => navToAddComment(context, comment.id),
                child: const Text('View All Replies'),
              ),
            ),
          ],
        );
      }
      return CommentCard(
          comment: comment, depth: depth + 1, limit: 6, type: 'Comment');
    }
    return Container();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(24, 158, 158, 158), // Colors.grey.shade300
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
          left: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
          right: BorderSide(
            color: Colors.grey,
            width: 0,
          ),
          bottom: BorderSide(
            color: Colors.grey,
            width: 0,
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                comment.profilePic,
              ),
              radius: 15,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(comment.text),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => navToAddComment(context, comment.id),
              icon: const Icon(Icons.reply),
            ),
            GestureDetector(
              onTap: () => navToAddComment(context, comment.id),
              child: const Text(
                'Reply',
                style: TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => upvoteComm(ref),
              icon: Icon(Constants.up,
                  size: 30,
                  color:
                      comment.upvotes.contains(user.uid) ? Colors.red : null),
            ),
            Text(
              '${comment.upvotes.length - comment.downvotes.length == 0 ? 'Like' : comment.upvotes.length - comment.downvotes.length}',
              style: const TextStyle(fontSize: 17),
            ),
            IconButton(
              onPressed: () => downvoteComm(ref),
              icon: Icon(Constants.down,
                  size: 30,
                  color: comment.downvotes.contains(user.uid)
                      ? Colors.blue
                      : null),
            ),
          ],
        ),
        const SizedBox(),
        ref.watch(getCommentRepliesProvider(comment.id)).when(
              data: (data) {
                return Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.isEmpty)
                        Container()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final replyComment = data[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0), // Adjust padding here
                              child: displayComments(
                                  context, replyComment, depth, type, limit),
                            );
                          },
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
      ]),
    );
  }
}
