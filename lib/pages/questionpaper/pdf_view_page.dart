import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
class PDFViewPage extends StatefulWidget {
  final String pdfUrl;

  const PDFViewPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  int currentPage = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Question Paper'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Page $currentPage',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfUrl,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            onPageChanged: (int? currentPage, int? _) {
              if (currentPage != null) {
                setState(() {
                  this.currentPage = currentPage + 1;
                });
              }
            },
            onPageError: (page, error) {
              print("Error on page $page: $error");
            },
            onRender: (_) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
