import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:routemaster/routemaster.dart";
import "package:socialwall/controller/auth_controller.dart";
import "package:socialwall/controller/user_controller.dart";
import "package:socialwall/pages/comp/error_text.dart";
import "package:socialwall/pages/comp/loader.dart";
import "package:socialwall/pages/comp/post_card.dart";

class UserProfile extends ConsumerWidget {
  final String uid;
  const UserProfile({
    super.key,
    required this.uid,
  });

void navToEditUser(BuildContext context){
  Routemaster.of(context).push('/user/$uid/edit');
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewer = ref.read(userProvider);
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  //user banner

                  SliverAppBar(
                    expandedHeight: 250,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child:
                              Image.network(user.probanner, fit: BoxFit.cover),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding:
                              const EdgeInsets.all(20).copyWith(bottom: 70),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.propic),
                            radius: 45,
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(20),
                          child: ElevatedButton.icon(
                            onPressed: () => navToEditUser(context),
                            icon: const Icon(Icons.edit),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            label: const Text("Edit Profile"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          //user profile

                          Row(
                            children: [
                              //department name
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(thickness: 2),
                        ],
                      ),
                    ),
                  ),
                ];
              },

            //display posts

              body: ref.watch(getUserPostsProvider(uid)).when(data: (data){
                return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final post = data[index];
                        return viewer?.uid==post.uid ? PostCard(post: post) : post.isAnonymous? const SizedBox(height: 0,) :
                          PostCard(post: post);
                      },
                    );
              }, error: (error, stackTrace) {return ErrorText(error: error.toString());},
            loading: () => const Loader()),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
