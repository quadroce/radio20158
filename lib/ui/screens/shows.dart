import 'package:flutter/material.dart';
import 'package:radio20158/ui/screens/topbar.dart';
import 'package:webfeed/webfeed.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class AllShows extends StatefulWidget {
  final RssFeed feed;

  AllShows({required this.feed});

  @override
  _AllShowsState createState() => _AllShowsState();
}

class _AllShowsState extends State<AllShows> {
  Set<String> _showNames = {};

  List<Show> _shows = [];

  @override
  void initState() {
    super.initState();
    loadMoreData();
  }

  Future<void> loadMoreData() async {
    List<RssItem>? items = widget.feed.items;
    _shows.sort((a, b) => a.name.compareTo(b.name));

    for (RssItem rssItem in items ?? []) {
      if (rssItem.description != null) {
        String showName = rssItem.categories?.first.value ?? "";
        if (!_showNames.contains(showName)) {
          print(showName);
          _showNames.add(showName);
          String? imageUrl = rssItem.itunes?.image?.href != null
              ? Uri.parse(rssItem.itunes!.image!.href!).toString()
              : null;
          setState(() {
            _shows.add(Show(name: showName, imageUrl: imageUrl));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RadioAppBar(scaffoldKey: _scaffoldKey),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: _shows.length,
        itemBuilder: (BuildContext context, int index) {
          Show show = _shows[index];
          return GridTile(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.network(show.imageUrl ?? ''),
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black45,
              title: Text(show.name),
              subtitle: Padding(
                padding: EdgeInsets.all(1.0),
                child: ElevatedButton(
                  onPressed: () async {
/*     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShowEpisodesPage(showName: article.showName)),
    );
 */
                  },
                  child: Text("ascolta le puntate"),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Show {
  final String name;
  final String? imageUrl;

  Show({required this.name, this.imageUrl});
}
