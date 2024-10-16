import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:routemaster/routemaster.dart";

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double boxSize=120;
    double iconSize= 60;

    void navToType(BuildContext context, String type){
      Routemaster.of(context).push('/add-posts/$type');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: ()=> navToType(context,'image'),
          child:
            SizedBox(
              height: boxSize,
              width: boxSize,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 16,
                child: Center(
                  child: Icon(Icons.image_outlined,size: iconSize,),
                ),
              ),
            ),
        ),
        GestureDetector(
           onTap: ()=> navToType(context,'text'),
          child:
            SizedBox(
              height: boxSize,
              width: boxSize,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 16,
                child: Center(
                  child: Icon(Icons.font_download_outlined,size: iconSize,),
                ),
              ),
            ),
        ),
        GestureDetector(
           onTap: ()=> navToType(context,'link'),
          child:
            SizedBox(
              height: boxSize,
              width: boxSize,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 16,
                child: Center(
                  child: Icon(Icons.link_outlined,size: iconSize,),
                ),
              ),
            ),
        ),
      ],
    );
  }
}
