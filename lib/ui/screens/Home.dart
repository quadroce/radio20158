//import 'dart:js';
import 'package:share/share.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_share/flutter_share.dart';
import 'dart:async';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
//import 'package:audioplayers/audioplayers.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RssFeed? _rssFeed;
  List<trasmissione> _mediumArticles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  Future<RssFeed?> getMediumRSSFeedData(int page) async {
    try {
      final client = http.Client();
      final response = await client
          .get(Uri.parse('https://radio20158.org/feed/podcast/?paged=$page'));
      return RssFeed.parse(response.body);
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('An error occurred while fetching data.'),
                Text('Please try again later.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    return null;
  }

  Future<void> loadMoreData() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      _currentPage++;

      final feed = await getMediumRSSFeedData(_currentPage);

      if (feed != null) {
        List<RssItem> items = feed.items ?? [];

        for (RssItem rssItem in items) {
          if (rssItem.description != null) {
            trasmissione mediumArticle = trasmissione(
              title: rssItem.title!,
              link: rssItem.link!,
              datePublished: rssItem.pubDate.toString(),
              enclosure: rssItem.enclosure!.url!,
              summary: rssItem.itunes!.summary.toString(),
              image: rssItem.itunes?.image.toString(),
            );

            _mediumArticles.add(mediumArticle);
          }
        }
      }

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('it_IT', null);

    getMediumRSSFeedData(1).then((feed) {
      updateFeed(feed);

      if (feed != null) {
        List<RssItem> items = feed.items ?? [];

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

              // image: rssItem.itunes?.image.toString(),
            );

            _mediumArticles.add(mediumArticle);
          }
        }
      }
    });
  }

  updateFeed(feed) {
    setState(() {
      _rssFeed = feed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Radio 20158'),
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Voci e suoni fuori dal cortile',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          preferredSize: Size.fromHeight(30.0),
        ),
      ),
      body: _rssFeed == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _mediumArticles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TrasmissioneItem(
                        article: _mediumArticles[index],
                        audioPlayer: _audioPlayer,
                      );
                    },
                  ),
                ),
              ],
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
  Duration position = Duration.zero;

  trasmissione({
    required this.title,
    required this.link,
    required this.datePublished,
    required this.enclosure,
    required this.summary,
    required this.image,
  });
}

class TrasmissioneItem extends StatelessWidget {
  final trasmissione article;
  final AudioPlayer audioPlayer;

  TrasmissioneItem({required this.article, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(
              width: 50, // set the width of the image
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/placeholder.png',
                image: article.image!,
                fit: BoxFit.cover, // set the image fit to cover the box
              ),
            ),
            title: Text(article.title),
            subtitle: Text(DateFormat('dd MMMM y', 'it_IT')
                .format(DateTime.parse(article.datePublished))),
            trailing: ElevatedButton(
              onPressed: () async {
                openAudioPlayer(article.enclosure.toString(), article, context);
              },
              child: Text("ascolta"),
            ),
          ),
        ],
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
              mediumArticle.image.toString())));
}

class AudioPlayerScreen extends StatefulWidget {
  final String url;
  final String mediumArticletitle;
  final String mediumArticleDescription;
  final String mediumArticleLink;
  final String itunesImage;

  AudioPlayerScreen(this.url, this.mediumArticletitle,
      this.mediumArticleDescription, this.mediumArticleLink, this.itunesImage);

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
        title: Text(widget.mediumArticletitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInImage.assetNetwork(
                  placeholder: 'assets/images/placeholder.png',
                  image: widget.itunesImage.toString(),
                  width: 300,
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
            Row(
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
                    color:
                        _isPlaying ? Color.fromARGB(255, 205, 254, 11) : null,
                  ),
                  onPressed: () async {
                    setState(() {
                      _isPlaying = true;
                      // Change color to red (or any other color) when button is pressed
                      // by passing the new color as a parameter to setState
                      Color newColor = Color.fromARGB(255, 254, 11, 11);
                      // Pass the new color as a parameter to setState
                      // to trigger a rebuild of the widget tree with the new color
                      var _iconColor = newColor;
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
                          max: _duration?.inSeconds?.toDouble() ?? 0.0,
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




            /* TESTO DESCRIPTION 
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(
                      28.0), // add 8 pixels of padding on all sides
                  child: Text(
                    widget.mediumArticleDescription,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // add ellipsis if text overflows
                    // limit text to one line
                  ),
                ),
              ],
            ) */
