import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:socialwall/controller/community_controller.dart';
import 'package:socialwall/controller/question_controller.dart';
import 'package:socialwall/core/utils.dart';
import 'package:socialwall/models/community.dart';
import 'package:socialwall/pages/comp/error_text.dart';
import 'package:socialwall/pages/comp/loader.dart';

class AddQuestionPaperScreen extends ConsumerStatefulWidget {
  final String name;
  const AddQuestionPaperScreen({super.key, required this.name});

  @override
  ConsumerState<AddQuestionPaperScreen> createState() =>
      _AddQuestionPaperScreenState();
}

class _AddQuestionPaperScreenState
    extends ConsumerState<AddQuestionPaperScreen> {
  File? pdfFile;
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  List<Community> communities = [];
  Community? selectedCommunity;
  String? selectedCategory; // Default is null initially
  String selectedDate = '';

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    dateController.dispose();
  }

  Future<FilePickerResult?> pickPdfFile() async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
  }

  void selectPdfFile() async {
    final result = await pickPdfFile();
    if (result != null) {
      setState(() {
        pdfFile = File(result.files.first.path!);
      });
    }
  }

  void shareQuestionPaper() {
    if (titleController.text.isNotEmpty && pdfFile != null) {
      String title = titleController.text.trim();
      String date = dateController.text.trim();

      ref.read(questionControllerProvider.notifier).shareQuestion(
            context: context,
            title: title,
            communityName: widget.name,
            category: selectedCategory!,
            date: date,
            file: pdfFile,
          );

      resetForm();
    } else {
      showSnackBar(context, 'Please fill in all required fields');
    }
  }

  void resetForm() {
    titleController.clear();
    dateController.clear();
    setState(() {
      pdfFile = null;
      selectedCategory = communities.isNotEmpty
          ? communities[0].subjects.first
          : null; // Set default to the first subject
      selectedDate = '';
      selectedCommunity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final communityStream = ref.watch(getCommunityByNameProvider(widget.name));
    final isLoading = ref.watch(questionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Question Paper',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: shareQuestionPaper,
            child: const Text(
              'Share',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Set the color here
              ),
            ),
          ),

          const SizedBox(width: 16), // Add some space after the button
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Title input
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Enter Question Paper Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 10),

                  // File input section for PDF
                  GestureDetector(
                    onTap: selectPdfFile,
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
                        child: pdfFile != null
                            ? Center(child: Text(pdfFile!.path.split('/').last))
                            : const Center(child: Icon(Icons.picture_as_pdf)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Text post description input (optional)
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Enter Date',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category selection dropdown (fetch subjects from community)
                  communityStream.when(
                    data: (community) {
                      final subjects = community.subjects;
                      // Set the default value for category if available
                      if (selectedCategory == null && subjects.isNotEmpty) {
                        selectedCategory = subjects.first;
                      }
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Select Category:',
                                  style: TextStyle(fontSize: 17)),
                              DropdownButton<String>(
                                value: selectedCategory,
                                items: subjects
                                    .map((category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedCategory = val!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => ErrorText(error: error.toString()),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
