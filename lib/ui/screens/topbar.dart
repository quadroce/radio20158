/*APPbar e Pagina */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trasmissioneitem.dart';
import 'Home.dart';
import 'openAudioPlayer.dart';

class RadioAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const RadioAppBar({Key? key, this.onMenuPressed, required this.scaffoldKey})
      : super(key: key);
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
            style: TextStyle(fontSize: 8.0),
          ),
        ),
        preferredSize: Size.fromHeight(30.0),
      ),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class BottomBarAppBar extends StatelessWidget {
  const BottomBarAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_rounded),
          label: 'Login',
        ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomDrawer({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class RadioWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RadioAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(scaffoldKey: _scaffoldKey),
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
      bottomNavigationBar: BottomBarAppBar(key: _scaffoldKey),
    );
  }
}
