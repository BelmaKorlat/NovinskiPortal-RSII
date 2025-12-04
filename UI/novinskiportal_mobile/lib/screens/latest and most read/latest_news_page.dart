import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/models/article/news_mode.dart';
import 'package:novinskiportal_mobile/screens/latest%20and%20most%20read/base_news_page.dart';

class LatestNewsPage extends BaseNewsPage {
  const LatestNewsPage({super.key, super.onModeChanged})
    : super(initialMode: NewsMode.latest);

  @override
  State<LatestNewsPage> createState() => LatestNewsPageState();
}

class LatestNewsPageState extends BaseNewsPageState<LatestNewsPage> {
  // Možeš dodati dodatne metode specifične za LatestNewsPage ako treba
}
