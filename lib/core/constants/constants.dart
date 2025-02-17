import 'package:flutter/material.dart';
import 'package:socialwall/pages/communities/communities_scr.dart';
import 'package:socialwall/pages/feeds/feeds_screen.dart';
import 'package:socialwall/pages/posts/add_posts.dart';

class Constants {
  static const logoPath= 'assets/images/logoholder.png';
  static const google='assets/images/google.png';

  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';
  static const avatarDefault =
      'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2';
      
  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
    AllCommunity(),
  ];

  static const IconData up = IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down = IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);
}