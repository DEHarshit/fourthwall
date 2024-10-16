import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:routemaster/routemaster.dart";
import "package:socialwall/controller/auth_controller.dart";
import "package:socialwall/controller/community_controller.dart";
import "package:socialwall/models/community.dart";
import "package:socialwall/pages/comp/error_text.dart";
import "package:socialwall/pages/comp/loader.dart";
import "package:socialwall/pages/comp/post_card.dart";

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({
    super.key,
    required this.name,
  });

  void navToTools(BuildContext context){
    Routemaster.of(context).push('/$name/mod-tools');
  }

  void joinDepartment(WidgetRef ref,Community department, BuildContext context){
    ref.read(communityControllerProvider.notifier).joinDepartment(department, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user= ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [

                  //community banner

                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                            child: Image.network(community.banner,
                                fit: BoxFit.cover)),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          //community profile

                          Row(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(community.avatar),
                                  radius: 35,
                                ),
                              ),
                              
                          //department name

                              SizedBox(width: 35),
                              Text(
                                community.name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          //count of members

                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${community.members.length} members'
                            )
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              community.mods.contains(user.uid)

                              //mod button

                              ? OutlinedButton(
                                onPressed: () => navToTools(context),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                ),
                                child: const Text('Tools'),
                              )

                              //join button

                              : OutlinedButton(
                                onPressed: () => joinDepartment(ref,community,context),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                ),
                                child: Text(community.members.contains(user.uid) ? 'Joined' : 'Join'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ];
              },


              body: ref.watch(getCommunityPostsProvider(name)).when(data: (data){
                return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final post = data[index];
                        return PostCard(post: post);
                      },
                    );
              }, error: (error, stackTrace) {return ErrorText(error: error.toString());},
            loading: () => const Loader()),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),),
    );
  }
}
