import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialwall/controller/community_controller.dart';
import 'package:socialwall/pages/comp/loader.dart';
import 'package:socialwall/models/community.dart';

class CategoryManagementPage extends ConsumerStatefulWidget {
  final String name;

  const CategoryManagementPage({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoryManagementPageState();
}

class _CategoryManagementPageState
    extends ConsumerState<CategoryManagementPage> {
  final categoryNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    categoryNameController.dispose();
  }
  void createCategory() async {
    final categoryName = categoryNameController.text.trim();

    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot be empty')),
      );
      return;
    }

    final communityController = ref.read(communityControllerProvider.notifier);

    final newCategory = categoryName;
    communityController.addCategoryToCommunity(widget.name, newCategory, context);

    categoryNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final communityData = ref.watch(getCommunityByNameProvider(widget.name));

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Add Category'),
        ),
        body: isLoading
            ? const Loader()
            : communityData.when(
                data: (community) {
                  final communitySubjects = community.subjects;
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Category Name')),
                        const SizedBox(height: 10),
                        TextField(
                          controller: categoryNameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a category name',
                            filled: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                          ),
                          maxLength: 50,
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          onPressed: createCategory,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )),
                          child: const Text('Add Category',
                              style: TextStyle(
                                fontSize: 17,
                              )),
                        ),

                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text('Available Categories'),
                        ),
                        const SizedBox(height: 10),
                        if (communitySubjects.isEmpty)
                          const Text('No categories available yet.')
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: communitySubjects
                                .map((subject) => ListTile(
                                      title: Text(subject),
                                      leading: const Icon(Icons.category),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Loader(),
                error: (error, stackTrace) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ));
  }
}
