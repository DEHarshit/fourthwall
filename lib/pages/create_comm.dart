import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialwall/controller/community_controller.dart';
import 'package:socialwall/pages/comp/loader.dart';



class CreateCommunity extends ConsumerStatefulWidget {
  const CreateCommunity({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityState();
}

class _CreateCommunityState extends ConsumerState<ConsumerStatefulWidget> {
  final communityNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    ref.read(communityControllerProvider.notifier).createCommunity(
          communityNameController.text.trim(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Create a community'),
        ),
        body: isLoading? const Loader() : Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Align(
                  alignment: Alignment.topLeft, child: Text('Community Name')),
              const SizedBox(height: 10),

              // text field

              TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                     RegExp(r'\s')),
                ],


                controller: communityNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter a departmet name',
                  filled: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                maxLength: 50,
              ),

              
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: createCommunity,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                child: const Text('Create Community',
                    style: TextStyle(
                      fontSize: 17,
                    )),
              ),
            ],
          ),
        ));
  }
}
