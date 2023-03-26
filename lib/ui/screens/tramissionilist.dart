class TrasmissioniList extends StatefulWidget {
  final List<trasmissione> mediumArticles;

  const TrasmissioniList({Key? key, required this.mediumArticles})
      : super(key: key);

  @override
  _TrasmissioniListState createState() => _TrasmissioniListState();
}

class _TrasmissioniListState extends State<TrasmissioniList> {
  Set<String> uniqueNomiDelloShow = {};

  @override
  void initState() {
    super.initState();
    for (final article in widget.mediumArticles) {
      uniqueNomiDelloShow.add(article.nomedelloshow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomiDelloShowList = uniqueNomiDelloShow.toList()..sort();
    return ListView.builder(
      itemCount: nomiDelloShowList.length,
      itemBuilder: (context, index) {
        final currentNomedelloshow = nomiDelloShowList[index];
        return Column(
          children: [
            SizedBox(height: 10),
            Text(
              currentNomedelloshow,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              itemCount: widget.mediumArticles.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final article = widget.mediumArticles[index];
                if (article.nomedelloshow != currentNomedelloshow) {
                  return SizedBox.shrink();
                }
                return MediumArticleItem(article: article);
              },
            ),
          ],
        );
      },
    );
  }
}
