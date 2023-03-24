/*APPbar e Pagina */

import 'package:flutter/material.dart';

class RadioAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const RadioAppBar({Key? key, this.onMenuPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: onMenuPressed,
      ),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class RadioWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radio20158'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RADIO20158',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'STORIE, VOCI E SUONI FUORI DAL CORTILE\n\nRadio 20158 è la web radio del quartiere Dergano Bovisa, che trasmette storie, voci e suoni di una comunità dinamica, multiculturale, in un’area in grande trasformazione.\n\nDai nostri microfoni prende voce il fermento delle attività e delle iniziative che si svolgono nel quartiere (ma non solo), promuovendo le iniziative e i diversi spazi attivi sul territorio per stimolare la partecipazione e migliorare la coesione sociale.\n\nLa musica rappresenta una parte importante di questo progetto: ci piace fare playlist cercando di spaziare il più possibile nei generi musicali.\n\nIdeatore e produttore: Andrea Baccalini',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
