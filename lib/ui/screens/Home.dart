import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:webfeed/webfeed.dart';
import 'package:just_audio/just_audio.dart';
import 'topbar.dart';
import 'trasmissioneitem.dart';
import 'openAudioPlayer.dart';

class Home extends StatefulWidget {
  final RssFeed feed; // add a Feed parameter to the Home widget

  const Home({Key? key, required this.feed})
      : super(key: key); // add the Feed parameter to the constructor

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _bottomKey = GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _drawerKey =
      GlobalKey<ScaffoldState>(); // add this line

  List<trasmissione> _mediumArticles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final trasmissione article;
  late final AudioPlayer audioPlayer;

  Future<void> loadMoreData() async {
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
      appBar: RadioAppBar(
        scaffoldKey: _scaffoldKey,
        onMenuPressed: () {
          // Open the drawer
          _drawerKey.currentState?.openDrawer(); // modify this line
        },
      ),
      drawer: Drawer(
        key: _drawerKey, //
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
              title: Text('Tutti gli episodi'),
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
                    icon: Icon(Icons.facebook,
                        color: Color.fromRGBO(106, 106, 207, 0.984)),
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
      //LA hOME

      body: Column(
        children: [
          Container(
            height: 2 / 5 * (MediaQuery.of(context).size.height),
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(_mediumArticles.isNotEmpty
                    ? _mediumArticles.first.image!
                    : ''),
                fit: BoxFit.fitWidth,
                opacity: 150,
                alignment: Alignment.topCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  _mediumArticles.isNotEmpty ? _mediumArticles.first.title : '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_mediumArticles.isNotEmpty) {
                        final article = _mediumArticles.first;
                        openAudioPlayer(
                            article.enclosure.toString(), article, context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 60),
                        padding: EdgeInsets.all(10)),
                    child: Text('Ascolta la puntata',
                        style: TextStyle(fontSize: 20)),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _mediumArticles.length > 10
                        ? 10
                        : _mediumArticles.length,
                    itemBuilder: (BuildContext context, int index) {
                      final article = _mediumArticles[index + 1];
                      final audioPlayer = _audioPlayer;

                      return TrasmissioneItem(
                        article: article,
                        audioPlayer: audioPlayer,
                      );
                    },
                  ),
                ),
                if (_mediumArticles.length > 10)
                  ElevatedButton(
                    onPressed: () {
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
                    child: Text('Tutti gli Episodi'),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(key: _bottomKey),
    );
  }
}
