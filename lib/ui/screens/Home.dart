//import 'dart:js';
import 'package:flutter/material.dart';
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
  List<MediumArticle> _mediumArticles = [];
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
            MediumArticle mediumArticle = MediumArticle(
              title: rssItem.title!,
              link: rssItem.link!,
              datePublished: rssItem.pubDate.toString(),
              enclosure: rssItem.enclosure!.url!,
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

    getMediumRSSFeedData(1).then((feed) {
      updateFeed(feed);

      if (feed != null) {
        List<RssItem> items = feed.items ?? [];

        for (RssItem rssItem in items) {
          if (rssItem.description != null) {
            MediumArticle mediumArticle = MediumArticle(
              title: rssItem.title!,
              link: rssItem.link!,
              datePublished: rssItem.pubDate.toString(),
              enclosure: rssItem.enclosure!.url!,
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
        title: Text('Radio 20158'),
      ),
      body: _rssFeed == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _mediumArticles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MediumArticleItem(
                        article: _mediumArticles[index],
                        audioPlayer: _audioPlayer,
                      );
                    },
                  ),
                ),
                _isLoadingMore
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () => loadMoreData(),
                        child: Text('Load More'),
                      ),
              ],
            ),
    );
  }
}

class MediumArticle {
  String title;
  String link;
  String datePublished;
  String enclosure;
  final String? image;

  MediumArticle({
    required this.title,
    required this.link,
    required this.datePublished,
    required this.enclosure,
    required this.image,
  });
}

class MediumArticleItem extends StatelessWidget {
  final MediumArticle article;
  final AudioPlayer audioPlayer;

  MediumArticleItem({required this.article, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
              title: Text(article.title),
              subtitle: Text(article.datePublished),
              trailing: ElevatedButton(
                  onPressed: () async {
                    openAudioPlayer(
                        article.enclosure.toString(), article, context);
                  },
                  child: Text("ascolta"))),

          /*          FadeInImage.assetNetwork(
            placeholder: 'images/placeholder.png',
            image: article.image,
          ),
  */
        ],
      ),
    );
  }
}

void openAudioPlayer(
    String url, MediumArticle mediumArticle, BuildContext context) {
  String url2 = "https://www.radio20158.org" + url;
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AudioPlayerScreen(
              url2, mediumArticle.title, mediumArticle.image.toString())));
}

class AudioPlayerScreen extends StatefulWidget {
  final String url;
  final String mediumArticletitle;
  final String itunesImage;

  AudioPlayerScreen(this.url, this.mediumArticletitle, this.itunesImage);

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
                Image(
                  image: NetworkImage(widget.itunesImage.toString()),
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
                      fontSize: 16,
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
                  icon: Icon(Icons.play_arrow),
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
          ],
        ),
      ),
    );
  }
}
