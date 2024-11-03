import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:socialwall/controller/auth_controller.dart';
import 'package:socialwall/controller/community_controller.dart';
import 'package:socialwall/controller/posts_controller.dart';
import 'package:socialwall/core/constants/constants.dart';
import 'package:socialwall/models/post_model.dart';
import 'package:socialwall/pages/comp/error_text.dart';
import 'package:socialwall/pages/comp/loader.dart';
import 'package:socialwall/pages/comp/post_image.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void navToUser(BuildContext context) {
    Routemaster.of(context).push('/user/${post.uid}');
  }

  void navToCommunity(BuildContext context) {
    Routemaster.of(context).push('/${post.communityName}');
  }

  void navToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  void reportPost(BuildContext context, String userId) {
    TextEditingController reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Post"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter the reason for reporting this post:'),
              const SizedBox(height: 10),
              TextField(
                controller: reportController,
                decoration: const InputDecoration(
                  hintText: 'Enter reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final reportReason = reportController.text;
                if (reportReason.isNotEmpty) {
                  submitReport(context, userId, reportReason);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for reporting.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // report submission
  void submitReport(BuildContext context, String userId, String reason) {
    //firebase logic :<
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted: $reason'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showAlertDialog(WidgetRef ref, BuildContext context) {
    Widget continueButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        Navigator.of(context).pop();
        deletePost(ref, context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Post"),
      content: const Text("Are you sure you want to delete this post?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.link != null;
    final isTypeText = post.description != null;
    final user = ref.watch(userProvider)!;
    return GestureDetector(
        onTap: () => navToComments(context),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white70,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => navToCommunity(context),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              post.communityProfile),
                                          radius: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.communityId,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),

                                            //username

                                            post.isAnonymous
                                                ? const Text(
                                                    'Anonymous',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  )
                                                : GestureDetector(
                                                    onTap: () =>
                                                        navToUser(context),
                                                    child: Text(
                                                      post.username,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  //delete icon

                                  if (post.uid == user.uid)
                                    IconButton(
                                        onPressed: () =>
                                            showAlertDialog(ref, context),
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red)),

                                  if (post.uid != user.uid)
                                    IconButton(
                                      onPressed: () =>
                                          reportPost(context, user.uid),
                                      icon: const Icon(Icons.report,
                                          color: Colors.orange),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey),
                                ),
                              ),
                              
                              if (isTypeText)
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17),
                                    child: Text(post.description!,
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ),
                                ),
                              if (isTypeImage)
                                GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostImage(imageUrl: post.link!),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.45,
                                      width: double.infinity,
                                      child: Image.network(post.link!,
                                          fit: BoxFit.cover),
                                    )),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => upvotePost(ref),
                                        icon: Icon(Constants.up,
                                            size: 30,
                                            color:
                                                post.upvotes.contains(user.uid)
                                                    ? Colors.red
                                                    : null),
                                      ),
                                      Text(
                                        '${post.upvotes.length - post.downvotes.length == 0 ? 'Like' : post.upvotes.length - post.downvotes.length}',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                      IconButton(
                                        onPressed: () => downvotePost(ref),
                                        icon: Icon(Constants.down,
                                            size: 30,
                                            color: post.downvotes
                                                    .contains(user.uid)
                                                ? Colors.blue
                                                : null),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => navToComments(context),
                                        icon: const Icon(
                                          Icons.comment_bank_outlined,
                                          size: 30,
                                        ),
                                      ),
                                      Text(
                                        '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                    ],
                                  ),

                                  //mod tool

                                  ref
                                      .watch(getCommunityByNameProvider(
                                          post.communityName))
                                      .when(
                                          data: (data) {
                                            if (data.mods.contains(user.uid)) {
                                              return IconButton(
                                                onPressed: () =>
                                                    showAlertDialog(
                                                        ref, context),
                                                icon: const Icon(
                                                  Icons.delete_forever_outlined,
                                                ),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                          error: (error, stackTrace) =>
                                              ErrorText(
                                                error: error.toString(),
                                              ),
                                          loading: () => const Loader())
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ));
  }
}
