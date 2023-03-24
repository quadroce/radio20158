import 'package:share/share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:webfeed/webfeed.dart';
import 'package:just_audio/just_audio.dart';
import 'topbar.dart';

class Home extends StatefulWidget {
  final RssFeed feed; // add a Feed parameter to the Home widget

  const Home({Key? key, required this.feed})
      : super(key: key); // add the Feed parameter to the constructor

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<trasmissione> _mediumArticles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final trasmissione article;
  late final AudioPlayer audioPlayer;

  Future<void> loadMoreData() async {
    //  final feed = await getMediumRSSFeedData(_currentPage);

    List<RssItem> items = widget.feed.items ?? [];

    for (RssItem rssItem in items) {
      if (rssItem.description != null) {
        trasmissione mediumArticle = trasmissione(
          title: rssItem.title!,
          link: rssItem.link!,
          datePublished: rssItem.pubDate.toString(),
          enclosure: rssItem.enclosure!.url!,
          summary: rssItem.itunes!.summary.toString(),
          image: rssItem.itunes?.image.toString(),
          nomedelloshow: rssItem.categories.toString(),
        );

        _mediumArticles.add(mediumArticle);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('it_IT', null);

    List<RssItem> items = widget.feed.items ?? [];
    String removeEpisode(String title) {
      RegExp regex = RegExp(r'S\d+E\d+');
      return title.replaceAll(regex, '').trim();
    }

    for (RssItem rssItem in items) {
      if (rssItem.description != null) {
        trasmissione mediumArticle = trasmissione(
          title: rssItem.title!,
          link: rssItem.link!,
          datePublished: rssItem.pubDate.toString(),
          enclosure: rssItem.enclosure!.url!,
          summary: rssItem.itunes!.summary!,
          image: rssItem.itunes?.image?.href != null
              ? Uri.parse(rssItem.itunes!.image!.href!).toString()
              : null,
          nomedelloshow: removeEpisode(rssItem.title!),
        );

        _mediumArticles.add(mediumArticle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              trailing: Icon(Icons.close),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('tutti gli episodi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListView.builder(
                      shrinkWrap: true,
                      itemCount: _mediumArticles.length,
                      itemBuilder: (BuildContext context, int index) {
                        final article = _mediumArticles[index];
                        final audioPlayer = _audioPlayer;

                        return TrasmissioneItem(
                          article: article,
                          audioPlayer: audioPlayer,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Radio20158'),
              subtitle: Text('STORIE, VOCI E SUONI FUORI DAL CORTILE'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RadioWidget()),
                );
              },
            ),
            ListTile(
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.facebook),
                    onPressed: () {
                      try {
                        () async {
                          final Uri url =
                              Uri.parse('https://www.facebook.com/radio20158');

                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }();
                      } catch (e) {
                        print('An error occurred: $e');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.instagram,
                        color: Color.fromRGBO(235, 143, 6, 1)),
                    onPressed: () {
                      try {
                        () async {
                          final Uri url = Uri.parse(
                              'https://www.instagram.com/radio_20158');

                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }();
                      } catch (e) {
                        print('An error occurred: $e');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.link_outlined),
                    onPressed: () {
                      try {
                        () async {
                          final Uri url =
                              Uri.parse('https://www.radio20158.org');

                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }();
                      } catch (e) {
                        print('An error occurred: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}

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

class TrasmissioneItem extends StatelessWidget {
  final trasmissione article;
  final AudioPlayer audioPlayer;

  TrasmissioneItem({required this.article, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 50, // set the width of the image
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/placeholder.png',
            image: article.image!,
            fit: BoxFit.cover, // set the image fit to cover the box
          ),
        ),
        title: Text(article.title),
        subtitle: Text(
          DateFormat('dd MMMM y', 'it_IT').format(
            DateTime.parse(article.datePublished),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            openAudioPlayer(
              article.enclosure.toString(),
              article,
              context,
            );
          },
          child: Text("ascolta"),
        ),
      ),
    );
  }
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
    bool _isPlaying = false;
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
                      setState(() {
                        _isPlaying = true;
                      });
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
