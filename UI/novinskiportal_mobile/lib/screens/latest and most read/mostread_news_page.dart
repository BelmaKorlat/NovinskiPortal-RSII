import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/models/article/news_mode.dart';
import 'package:novinskiportal_mobile/screens/latest%20and%20most%20read/base_news_page.dart';

class MostReadNewsPage extends BaseNewsPage {
  const MostReadNewsPage({super.key, super.onModeChanged})
    : super(initialMode: NewsMode.mostread);

  @override
  State<MostReadNewsPage> createState() => MostReadNewsPageState();
}

class MostReadNewsPageState extends BaseNewsPageState<MostReadNewsPage> {}
