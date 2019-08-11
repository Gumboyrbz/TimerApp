import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({
    Key key,
    this.icon,
  }) : super(key: key);

  final IconData icon;

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController; // To control switching tabs
  ScrollController _scrollViewController; // To control scrolling
  String photoFile = 'lib/res/profile.png';
  String launcherIcon = "lib/res/launcher_icon.png";
  String websiteUrl = 'https://gumboyrbz.github.io';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollViewController.dispose();
  }

  double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  Widget _information() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 10.0),
        RichText(
          text: TextSpan(
            // "Made by: Gumboy",
            style: TextStyle(fontSize: 20.0, color: Colors.black),
            children: [
              TextSpan(
                text: "Made by: ",
              ),
              TextSpan(
                text: "Gumboy",
                style: TextStyle(
                    fontSize: 20.0,
                    // decoration: TextDecoration.underline,
                    color: Colors.blue),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        Text("Developer Website:"),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: Row(
                children: <Widget>[
                  Icon(Icons.arrow_forward),
                  IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(
                      Icons.web,
                      size: 40,
                    ),
                    onPressed: () => _launchURL(url: websiteUrl),
                  ),
                  Icon(Icons.arrow_back),
                ],
              ),
              onTap: () => _launchURL(url: websiteUrl),
              onLongPress: () {
                Clipboard.setData(new ClipboardData(text: websiteUrl));
              },
            ),
            SizedBox(height: 50.0),

            // Text(websiteUrl),
          ],
        ),
      ],
    );
  }

  Widget _developerInfo(dialogcontext) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(16.0),
              child: PhotoHero(
                photo: photoFile,
                width: getWidth(dialogcontext) * 0.55,
                onTap: () {
                  Navigator.of(dialogcontext).pop();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _information(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: MaterialButton(
          child: Text(
            "Copy link",
            style: TextStyle(
              fontSize: 20.0,
              // color: ,
            ),
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: websiteUrl));
            // showInSnackBar("Link copied to clipboard");
            Scaffold.of(dialogcontext).showSnackBar(SnackBar(
              content: Text("Link copied to clipboard"),
            ));
          },
        ),
      ),
    );
  }

  Widget _appData() {
    // _appInfo();
    return FutureBuilder(
      future: _appInfo(),
      initialData: "Loading...",
      builder: (BuildContext context, appInfo) {
        if (appInfo.connectionState == ConnectionState.none &&
            appInfo.hasData == null) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: EdgeInsets.all(50.0),
          itemCount: appInfo.data.length,
          itemBuilder: (BuildContext context, int index) {
            if (appInfo.data[index] == 'placeholder') {
              // return appInfo.data[index];
              return Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(20.0),
                  child: PhotoHero(
                    photo: launcherIcon,
                    width: getWidth(context) * 0.30,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 5.0),
                  new Text(
                    appInfo.data[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future _appInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<dynamic> data = [];

    data.add("placeholder");
    data.add(packageInfo.appName);
    data.add("Ver: " + packageInfo.version);
    data.add(packageInfo.packageName);
    data.add("Build: " + packageInfo.buildNumber);

    return data;
  }

  Future<Function> _launchURL({String url}) async {
    // const url = 'https://flutter.io';
    // print("Here");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0.0),
      icon: Icon(widget.icon),
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogcontext) {
            return SimpleDialog(
              contentPadding: EdgeInsets.all(0.0),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(0.0),
                  constraints: BoxConstraints(
                      maxWidth: getWidth(dialogcontext) / 2,
                      maxHeight: getHeight(dialogcontext) / 1.75),
                  child: Scaffold(
                    appBar: new AppBar(
                      flexibleSpace: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(icon: Icon(Icons.info_outline), text: "App Info"),
                          Tab(icon: Icon(Icons.account_box), text: "Developer"),
                        ],
                      ),
                      primary: false,
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                    ),
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        _appData(),
                        _developerInfo(dialogcontext),
                      ],
                    ),
                    // bottomNavigationBar: BottomAppBar(
                    //   color: Colors.blue,
                    //   child: MaterialButton(
                    //     child: Text(
                    //       "Copy link",
                    //       style: TextStyle(
                    //         fontSize: 20.0,
                    //         // color: ,
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       Clipboard.setData(ClipboardData(text: websiteUrl));
                    //       // showInSnackBar("Link copied to clipboard");
                    //       Scaffold.of(dialogcontext).showSnackBar(SnackBar(
                    //         content: Text("Link copied to clipboard"),
                    //       ));
                    //     },
                    //   ),
                    // ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key key, this.photo, this.onTap, this.width})
      : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return Material(
      // Slightly opaque color appears where the image has transparency.
      color: Theme.of(context).primaryColor.withOpacity(1.00),
      child: InkWell(
        onTap: onTap,
        child: Image.asset(
          photo,
          width: width,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;

//   _SliverAppBarDelegate(this._tabBar);

//   @override
//   double get minExtent => _tabBar.preferredSize.height;

//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return new Container(
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
