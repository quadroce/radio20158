import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:radio20158/ui/screens/Home.dart';
import 'package:webfeed/webfeed.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  get analytics => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio 20158',
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color.fromRGBO(38, 34, 47, 0.8)),
      home: SplashPage(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
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
      final feedUrl = 'https://radio20158.org/feed/podcast/?paged=1';
      final cachedResponse = await DefaultCacheManager().getSingleFile(feedUrl);

      if (await cachedResponse.exists()) {
        final cachedFeed = RssFeed.parse(await cachedResponse.readAsString());
        final lastModified =
            await cachedResponse.lastModified(); // updated this line

        if (DateTime.now().difference(lastModified).inMinutes < 60) {
          // Cached version is less than 60 minutes old, so return it
          return cachedFeed;
        } else {
          // Cached version is outdated, so refresh it
          final client = http.Client();
          final response = await client.get(Uri.parse(feedUrl));
          final feed = RssFeed.parse(response.body);
          await DefaultCacheManager().putFile(feedUrl, response.bodyBytes);
          return feed;
        }
      } else {
        // No cached version found, so fetch and cache the feed
        final client = http.Client();
        final response = await client.get(Uri.parse(feedUrl));
        final feed = RssFeed.parse(response.body);
        await DefaultCacheManager().putFile(feedUrl, response.bodyBytes);
        return feed;
      }
    } catch (e) {
      print('Error loading RSS feed: $e');
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
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
