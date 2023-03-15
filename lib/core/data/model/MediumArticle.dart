import 'package:flutter/foundation.dart';
import 'package:webfeed/domain/itunes/itunes_image.dart';

class MediumArticle {
  String title;
  String link;
  String datePublished;
  Uri enclosure;

  ItunesImage itunesImage;

  MediumArticle({
    required this.title,
    required this.link,
    required this.datePublished,
    required enclosure,
    required this.itunesImage,
  }) : enclosure = Uri.parse(enclosure as String);
}
