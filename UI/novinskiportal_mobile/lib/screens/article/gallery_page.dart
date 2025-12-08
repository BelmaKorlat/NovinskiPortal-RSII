import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/api_client.dart';

class GalleryPage extends StatefulWidget {
  final List<String> photos; // relativne putanje iz baze
  final int initialIndex; // na koju sliku da se otvori

  const GalleryPage({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (ctx, index) {
          final url = ApiClient.resolveUrl(widget.photos[index]);

          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: Image.network(url, fit: BoxFit.contain)),
          );
        },
      ),
    );
  }
}
