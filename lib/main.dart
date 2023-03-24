import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:radio20158/ui/screens/Home.dart';
import 'package:webfeed/webfeed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio 20158',
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color.fromRGBO(38, 34, 47, 0.8)),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    loadData().then((value) {
      if (value != null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Home(feed: value)));
      }
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while fetching data: $error'),
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
    });
  }

  Future<RssFeed?> loadData() async {
    try {
      final client = http.Client();
      final response = await client
          .get(Uri.parse('https://radio20158.org/feed/podcast/?paged=1'));
      final feed = RssFeed.parse(response.body);
      return feed;
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'An error occurred while fetching data. Please trycatching the error message.'),
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
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Voci e Suoni fuori dal cortile',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            const Image(
              image: AssetImage('assets/images/splash.png'),
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
