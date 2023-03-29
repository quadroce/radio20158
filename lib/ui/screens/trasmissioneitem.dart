import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'openAudioPlayer.dart';

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
