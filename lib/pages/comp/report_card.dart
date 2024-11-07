import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:socialwall/controller/auth_controller.dart';
import 'package:socialwall/controller/community_controller.dart';
import 'package:socialwall/controller/posts_controller.dart';
import 'package:socialwall/core/constants/constants.dart';
import 'package:socialwall/models/report_model.dart';
import 'package:socialwall/models/post_model.dart';
import 'package:socialwall/pages/comp/error_text.dart';
import 'package:socialwall/pages/comp/loader.dart';
import 'package:socialwall/pages/comp/post_card.dart';
import 'package:socialwall/pages/comp/post_image.dart';
import 'package:socialwall/controller/reports_controller.dart';

final isTextVisibleProvider = StateProvider<bool>((ref) => false);

class ReportCard extends ConsumerWidget {
  final Report report;

  const ReportCard({
    super.key,
    required this.report,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(reportControllerProvider.notifier).deleteReport(report, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextVisible = ref.watch(isTextVisibleProvider);
    final postAsyncValue = ref.watch(getPostByIdProvider(report.postId));

    return postAsyncValue.when(
      data: (post) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100], 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCard(post: post, reportId: report.id),

              const SizedBox(height: 10), 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => deletePost(ref, context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Resolve Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      ref.read(isTextVisibleProvider.notifier).state = !isTextVisible;
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isTextVisible ? 'Hide Reports' : 'Show Reports',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), 

              if (isTextVisible)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < report.text.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}. ',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.text[i],
                                  style: const TextStyle(
                                    color: Colors.red, 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < report.text.length - 1) Divider(), 
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Loader(),
      error: (error, stackTrace) => ErrorText(error: error.toString()),
    );
  }
}
