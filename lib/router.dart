import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:socialwall/pages/add_mods.dart';
import 'package:socialwall/pages/questionpaper/category_management_page.dart';
import 'package:socialwall/pages/questionpaper/community_question.dart';
import 'package:socialwall/pages/communities/community_reports.dart';
import 'package:socialwall/pages/communityscr.dart';
import 'package:socialwall/pages/create_comm.dart';
import 'package:socialwall/pages/edit_comm.dart';
import 'package:socialwall/pages/home.dart';
import 'package:socialwall/pages/login.dart';
import 'package:socialwall/pages/posts/add_posts_type.dart';
import 'package:socialwall/pages/posts/comments_scr.dart';
import 'package:socialwall/pages/posts/add_comments.dart';
import 'package:socialwall/pages/questionpaper/question_comments.dart';
import 'package:socialwall/pages/questionpaper/upload_question_paper_page.dart';
import 'package:socialwall/pages/tools.dart';
import 'package:socialwall/pages/userprofile/edit_profile.dart';
import 'package:socialwall/pages/userprofile/profile.dart';

//loggetOut
final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

//loggedIn
final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateCommunity()),
  '/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )),
  '/:name/mod-tools': (routeData) => MaterialPage(
          child: ToolsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/:name/edit-depart': (routeData) => MaterialPage(
          child: EditDepartment(
        name: routeData.pathParameters['name']!,
      )),
  '/:name/add-mods': (routeData) => MaterialPage(
          child: AddModsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/:name/report-screen': (routeData) => MaterialPage(
          child: ReportsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/:name/question-paper': (routeData) => MaterialPage(
          child: QuestionsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/question/:postId/comments': (route) => MaterialPage(
      child: QuestionCommentsScreen(postId: route.pathParameters['postId']!)),
  '/:name/question-paper/add': (routeData) => MaterialPage(
          child: AddQuestionPaperScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/:name/question-paper/category': (routeData) => MaterialPage(
          child: CategoryManagementPage(
        name: routeData.pathParameters['name']!,
      )),
  '/user/:uid': (routeData) => MaterialPage(
          child: UserProfile(
        uid: routeData.pathParameters['uid']!,
      )),
  '/user/:uid/edit': (routeData) => MaterialPage(
          child: EditProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/add-posts/:type': (routeData) => MaterialPage(
        child: AddPostTypes(type: routeData.pathParameters['type']!),
      ),
  '/post/:postId/comments': (route) => MaterialPage(
      child: CommentsScreen(postId: route.pathParameters['postId']!)),
  '/post/:postId/comments/:commentId': (route) => MaterialPage(
        child: AddCommentsScreen(commentId: route.pathParameters['commentId']!),
      )
});
