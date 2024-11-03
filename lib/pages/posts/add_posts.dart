import "dart:io";
import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:socialwall/controller/community_controller.dart";
import "package:socialwall/controller/posts_controller.dart";
import "package:socialwall/core/utils.dart";
import "package:socialwall/models/community.dart";
import "package:socialwall/pages/comp/error_text.dart";
import "package:socialwall/pages/comp/loader.dart";

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  bool isAnonymous = false;
  File? bannerFile;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (titleController.text.isNotEmpty) {
      String title = titleController.text.trim();
      String? description = descriptionController.text.isNotEmpty
          ? descriptionController.text.trim()
          : null;

      if (bannerFile == null && description != null) {
        ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: title,
            selectedCommunity: selectedCommunity ?? communities[0],
            isAnonymous: isAnonymous,
            description: description);
      } else if (bannerFile != null) {
        ref.read(postControllerProvider.notifier).sharePost(
            context: context,
            title: title,
            selectedCommunity: selectedCommunity ?? communities[0],
            file: bannerFile,
            isAnonymous: isAnonymous,
            description: description);
      } else {
        showSnackBar(context, 'Please enter at least one field');
      }
    } else {
      showSnackBar(context, 'Please enter a title');
    }
    resetForm();
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    setState(() {
      bannerFile = null;
      isAnonymous = false;
      selectedCommunity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(  
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add Post',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: sharePost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Share',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          thickness: 0.5,
                          height: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title input
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Enter Title here',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 10),

                  // Image input section
                  GestureDetector(
                    onTap: selectBannerImage,
                    child: DottedBorder(
                      radius: const Radius.circular(10),
                      dashPattern: const [10, 4],
                      strokeCap: StrokeCap.round,
                      borderType: BorderType.RRect,
                      color: Colors.black,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: bannerFile != null
                            ? Image.file(bannerFile!)
                            : const Center(child: Icon(Icons.camera_alt)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Text post description input
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Enter Description here (optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLines: 6,
                  ),
                  const SizedBox(height: 20),

                  // Anonymous switch
                  Row(
                    children: [
                      const Text('Anonymous:', style: TextStyle(fontSize: 17)),
                      Switch.adaptive(
                        value: isAnonymous,
                        onChanged: (val) {
                          setState(() {
                            isAnonymous = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Community selection dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Department:',
                          style: TextStyle(fontSize: 17)),
                      ref.watch(userCommunitiesProvider).when(
                            data: (data) {
                              communities = data;
                              if (data.isEmpty) {
                                return const SizedBox();
                              }
                              return DropdownButton<Community>(
                                value: selectedCommunity ?? data[0],
                                items: data
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.id),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedCommunity = val;
                                  });
                                },
                              );
                            },
                            error: (error, stackTrace) =>
                                ErrorText(error: error.toString()),
                            loading: () => const Loader(),
                          ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
