import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'topbar.dart';

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
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final GlobalKey<ScaffoldState> _bottomKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      appBar: RadioAppBar(
        scaffoldKey: _scaffoldKey,
      ),
      body: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
        return Center(
          child: Column(
            mainAxisAlignment: orientation == Orientation.portrait
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/images/placeholder.png',
                    image: widget.itunesImage.toString(),
                    fit: BoxFit.cover,
                    width: orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.8
                        : MediaQuery.of(context).size.width * 0.4,
                  ),
                ],
              ),

              SizedBox(height: 16), // add some spacing between the rows

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.mediumArticletitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )),
                ],
              ),

              SizedBox(height: 16), // add some spacing between the rows
              Flexible(
                child: Row(
                  mainAxisAlignment: orientation == Orientation.portrait
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
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

                  final Duration remaining =
                      _duration != null ? _duration! - position : Duration.zero;

                  final String remainingText =
                      '${remaining.toString().split('.').first}';
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$positionText',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '$remainingText',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
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
        );
      }),
      bottomNavigationBar: BottomBarAppBar(key: _bottomKey),
    );
  }
}
