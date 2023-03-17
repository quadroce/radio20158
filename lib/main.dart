import 'package:radio20158/ui/screens/Home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio 20158',

      //theme: AppTheme.appThemeDataLight,

      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    loadData().then((value) => {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) => Home()))
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //           Image.asset('assets/images/splash.png'),
            SizedBox(height: 20),
            Text(
              'Loading $_progress%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("voci e suoni dal quartiere"),
          ],
        ),
      ),
    );
  }

  Future<void> loadData() async {
    int total = 100; // Total number of data to load
    int loaded = 0; // Number of data loaded

    // Simulate loading data
    while (loaded < total) {
      await Future.delayed(Duration(milliseconds: 1));
      setState(() {
        _progress = (loaded / total) * 100;
      });
      loaded++;
    }
  }
}
