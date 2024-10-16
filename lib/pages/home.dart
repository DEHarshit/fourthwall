import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:socialwall/controller/auth_controller.dart";
import "package:socialwall/core/constants/constants.dart";
import "package:socialwall/pages/comp/prodrawer.dart";
import "package:socialwall/pages/delegates/search_community.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          //search

          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => displayDrawer(context),
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.propic),
              ),
            );
          }),
        ],
      ),

      body: Constants.tabWidgets[_page],
      endDrawer: const ProfileList(),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: ''),
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
    );
  }
}
