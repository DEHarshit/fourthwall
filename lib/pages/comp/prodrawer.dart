import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:routemaster/routemaster.dart";
import "package:socialwall/controller/auth_controller.dart";
import "package:socialwall/controller/community_controller.dart";
import "package:socialwall/models/community.dart";
import "package:socialwall/pages/comp/error_text.dart";
import "package:socialwall/pages/comp/loader.dart";

class ProfileList extends ConsumerWidget {
  const ProfileList({super.key});

  //log out

  void logOut(WidgetRef ref){
    ref.read(authControllerProvider.notifier).logOut();
  }

  //create community

  void navToCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  //department info

  void navToDepartment(BuildContext context, Community department) {
    Routemaster.of(context).push(department.name);
  }

  //profile info

  void navToProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/user/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
          child: Column(children: [
        //user profile
        CircleAvatar(backgroundImage: NetworkImage(user.propic),radius: 80,),

        SizedBox(height: 20,),
        //user name
        Text(user.name,style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),),

        SizedBox(height: 20,),

        Divider(
          color: Colors.black,
        ),

        //my profile

        ListTile(
          title: const Text('My Profile'),
          leading: const Icon(Icons.account_circle_outlined),
          onTap: ()=>navToProfile(context,user.uid),
        ),

        //create community
        ListTile(
          title: const Text('Create a community'),
          leading: const Icon(Icons.add),
          onTap: () => navToCommunity(context),
        ),

        //sign out

         ListTile(
          title: const Text('Sign Out'),
          leading: const Icon(Icons.logout_outlined),
          onTap: () => logOut(ref),
        ),

        Divider(
          color: Colors.black,
        ),
        ListTile(
          title: const Text('Your Communities'),
        ),
        //department list
        ref.watch(userCommunitiesProvider).when(
                    data: (communities) => Expanded(
                      child: ListView.builder(
                        itemCount: communities.length,
                        itemBuilder: (BuildContext context, int index) {
                          final community = communities[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                            title: Text(community.name),
                            onTap: () => navToDepartment(context, community),
                        );
                      }),
                ),
            error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                ),
            loading: () => const Loader()),
      ])),
    );
  }
}
