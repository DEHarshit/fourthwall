import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:socialwall/controller/community_controller.dart";
import "package:socialwall/controller/posts_controller.dart";
import "package:socialwall/pages/comp/error_text.dart";
import "package:socialwall/pages/comp/loader.dart";
import "package:socialwall/pages/comp/post_card.dart";

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(
            data: (communities) => ref.watch(userPostsProvider(communities)).when(
                  data: (data) {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final post = data[index];
                        return PostCard(post: post);
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return ErrorText(
                      error: error.toString(),
                    );
                  },
                  loading: () => const Loader(),
                ),
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          );
  }
}
