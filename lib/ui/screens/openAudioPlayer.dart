import 'dart:ui';

import 'package:share/share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:webfeed/webfeed.dart';
import 'package:just_audio/just_audio.dart';
import 'home.dart';
import 'trasmissioneitem.dart';

class trasmissione {
  String title;
  String link;
  String datePublished;
  String enclosure;
  String summary;
  final String? image;
  String nomedelloshow;
  Duration position = Duration.zero;

  trasmissione({
    required this.title,
    required this.link,
    required this.datePublished,
    required this.enclosure,
    required this.summary,
    required this.image,
    required this.nomedelloshow,
  });
}

void openAudioPlayer(
    String url, trasmissione mediumArticle, BuildContext context) {
  String url2 = "https://www.radio20158.org" + url;
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AudioPlayerScreen(
              url2,
              mediumArticle.title,
              mediumArticle.summary,
              mediumArticle.link,
              mediumArticle.image.toString(),
              mediumArticle.nomedelloshow)));
}

class AudioPlayerScreen extends StatefulWidget {
  final String url;
  final String mediumArticletitle;
  final String mediumArticleDescription;
  final String mediumArticleLink;
  final String itunesImage;
  final String mediumArticleNome;

  AudioPlayerScreen(
    this.url,
    this.mediumArticletitle,
    this.mediumArticleDescription,
    this.mediumArticleLink,
    this.itunesImage,
    this.mediumArticleNome,
  );

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.url);

      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Duration? _duration = _audioPlayer.duration ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediumArticleNome),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/images/placeholder.png',
                    image: widget.itunesImage.toString(),
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16), // add some spacing between the rows

            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.mediumArticletitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )),
                ],
              ),
            ),
            SizedBox(height: 16), // add some spacing between the rows
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.forward_30),
                    onPressed: () async {
                      Duration newPosition =
                          _audioPlayer.position + Duration(seconds: 30);
                      await _audioPlayer.seek(newPosition);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.pause),
                    onPressed: () async {
                      await _audioPlayer.pause();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                    ),
                    onPressed: () async {
                      await _audioPlayer.play();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.replay_30),
                    onPressed: () async {
                      Duration newPosition =
                          _audioPlayer.position + Duration(seconds: -30);
                      await _audioPlayer.seek(newPosition);
                    },
                  ),
                ],
              ),
            ),

            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder:
                  (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                final Duration position = snapshot.data ?? Duration.zero;
                final String positionText =
                    position.toString().split('.').first;
                final String durationText =
                    _duration.toString().split('.').first;
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    _duration = _audioPlayer.duration;
                    setState(() {}); // Force a rebuild of the widget
                    return Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: _duration?.inSeconds.toDouble() ?? 0.0,
                          onChanged: (double value) {
                            setState(() {
                              _audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$positionText/$durationText',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: 16), // add some spacing between the rows

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {
                                final String testoDaCondividere =
                                    "Ascolta la trasmissione: " +
                                        widget.mediumArticletitle +
                                        " su " +
                                        widget.mediumArticleLink +
                                        "\n" +
                                        "Segui \#radio20158 sui social";
                                Share.share(testoDaCondividere);
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
