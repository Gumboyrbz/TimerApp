import 'package:flutter/material.dart';
import 'light_dark_icons.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'widgets/screens/ScreenLayout.dart';
import 'widgets/screens/about.dart';
import 'widgets/screens/stopwatch.dart';

void main() {
  //async {
  // await SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.grey,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return new MaterialApp(
          theme: theme,
          // home: SpeedDial(icons: [Icons.sms, Icons.mail, Icons.phone ],),
          home: MainPage(),
          // theme: ThemeData.light(),
          // darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          // home: HomeListView(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  // bool _isSwitched = false;

  // void _switchTheme() {
  //   setState(() {
  //     DynamicTheme.of(context).setBrightness(
  //         Theme.of(context).brightness == Brightness.dark
  //             ? Brightness.light
  //             : Brightness.dark);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ScreenLayout(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  bool _isSwitched = false;
  AppLifecycleState _appLifecycleState;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
      print("My App State: $_appLifecycleState");
    });
  }

  void _switchTheme() {
    setState(() {
      DynamicTheme.of(context).setBrightness(
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            title: Text("Timer & StopWatch"),
            actions: <Widget>[
              Icon(LightDark.theme_light_dark),
              Switch(
                onChanged: (bool value) {
                  _switchTheme();
                  _isSwitched = value;
                },
                value: _isSwitched,
              ),
              Center(child: AboutPage(icon: Icons.info_outline)),
            ],
            elevation: 50.0,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(12.0),
              child: Container(
                child: TabBar(
                  indicatorColor: Theme.of(context).accentColor,
                  labelPadding: EdgeInsets.all(2.0),
                  tabs: [
                    // Tab(
                    Icon(Icons.av_timer),
                    // text: "Timer",
                    // ),
                    // Tab(
                    Icon(Icons.timer),
                    // text: "Stopwatch",
                    // ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              MyHomePage(
                title: "Timer",
              ),
              MyStopWatchPage(
                title: "StopWatch",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
