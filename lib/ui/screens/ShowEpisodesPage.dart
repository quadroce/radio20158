/* import 'package:flutter/material.dart';
import 'package:radio20158/main.dart';
import 'openAudioPlayer.dart';

class ShowEpisodesPage extends StatelessWidget {
  final String showName;

  ShowEpisodesPage({required this.showName});

  @override
  Widget build(BuildContext context) {
    // recupera tutte le puntate dal database o da una fonte dati
    List<trasmissione> allEpisodes = ;
 List<RssItem>? items = widget.feed.items;
    // filtra le puntate per il nome dello show corrispondente
    List<trasmissione> showEpisodes =
        allEpisodes.where((ep) => ep.showName == showName).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Puntate")),
      body: ListView.builder(
        itemCount: showEpisodes.length,
        itemBuilder: (context, index) {
          final episode = showEpisodes[index];
          return ListTile(
            title: Text(episode.title),
            trailing: ElevatedButton(
              onPressed: () async {
                openAudioPlayer(
                  episode.enclosure.toString(),
                  episode,
                  context,
                );
              },
              child: Text("ascolta"),
            ),
          );
        },
      ),
    );
  }
}
 */