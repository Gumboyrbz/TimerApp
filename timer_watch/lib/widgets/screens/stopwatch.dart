import 'package:flutter/material.dart';

import '../animatedicons.dart';
import '../timertext.dart';
import 'laplist.dart';
import '../depends.dart';

class MyStopWatchPage extends StatefulWidget {
  MyStopWatchPage({Key key, this.title}) : super(key: key);
  final String title;
  _MyStopWatchPageState createState() => _MyStopWatchPageState();
}

class _MyStopWatchPageState extends State<MyStopWatchPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 0.0,
      vsync: this,
    );
    // var binds =WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback(_onBuildCompleted);
    // WidgetsBinding.instance.addPersistentFrameCallback(_onBuildCompleted);

  }

  _onBuildCompleted(_) {
    _getSize(_keyButtonStart);
  }

  @override
  void didUpdateWidget(MyStopWatchPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    // WidgetsBinding.instance.addPostFrameCallback(_onBuildCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool resetAniIcon = false;
  int watchnMilliseconds = 0;
  bool _showlap = false;
  List<int> stopwatchLaps = [];
  int insertIndex = 0;

  final GlobalKey<AnimatedListState> _listkey = GlobalKey();
  final ScrollController _listcontroller = ScrollController();
  final Dependencies dependencies = new Dependencies();
  GlobalKey _keyButtonStart = GlobalKey();
  Size _containerSize = Size(0, 0);
  double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_onBuildCompleted);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildVerticalLayout()
              : _buildHorizontalLayout();
        },
      ),
    );
  }

  Widget _buildVerticalLayout() {
    var width = getWidth(context);
    var height = getHeight(context);
    return Container(
      // alignment: Alignment.bottomCenter,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: _showlap
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  // alignment: Alignment.bottomCenter,
                  child: displayTime(),
                ),
                Align(
                  // alignment: Alignment.bottomCenter,
                  child: _listoflaps(),
                ),
                _showlap ? null:Padding(padding: EdgeInsets.all(10.0),),
                Align(
                    alignment: Alignment.center,
                    child: utilButtons(width: width * 0.04)),
              ].where(notNull).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 400) {
                        return _buildHorizontalAboveWidth();
                      } else {
                        return _buildHorizontalBelowWidth();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void returnNull() => null;

  Widget _buildHorizontalAboveWidth() {
    var width = getWidth(context);
    var height = getHeight(context);

    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: displayTime(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: utilButtons(width: width * 0.04),
                ),
                // Padding(
                //   padding: EdgeInsets.only(bottom: height * 0.02),
                // ),
              ],
            ),
          ),
        ),
        _showlap
            ? Expanded(
                child: Container(
                  child: Container(
                    height: height,
                    child: Align(
                      // alignment: Alignment.bottomCenter,
                      child: _listoflaps(full: true),
                    ),
                  ),
                ),
              )
            : null
      ].where(notNull).toList(),
    );
  }

  Widget _buildHorizontalBelowWidth() {
    var width = getWidth(context);
    var height = getHeight(context);
    return Center(
      child: FittedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              // height: width * 0.,
              width: width,
              // alignment: Alignment.bottomCenter,
              child: displayTime(),
            ),
            _showlap
                ? Container(
                    height: width * 0.6,
                    width: width,
                    child: _listoflaps(),
                  )
                : null,
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.all(0.0),
              width: width * 0.5,
              child: utilButtons(width: width * 0.04),
            ),
          ].where(notNull).toList(),
        ),
      ),
    );
  }

  void _startAndpause() {
    setState(() {
      resetAniIcon = !resetAniIcon;
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
        // watchnMilliseconds = dependencies.stopwatch.elapsedMilliseconds;
      }
    });
  }

  Widget _listoflaps({bool full}) {
    var height = getHeight(context);
    if (_showlap) {
      return Container(
        height: full == true ? height : height * 0.60,
        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: BodyLayout(
          laps: stopwatchLaps,
          listkey: _listkey,
          controller: _listcontroller,
        ),
      );
    } else {
      return null;
    }
  }

  Function _lap() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        _showlap = true;
        stopwatchLaps.insert(
            insertIndex, dependencies.stopwatch.elapsedMilliseconds);

        // insertIndex++;
      } else {}
    });
    // _listcontroller.animateTo(2.0,
    //     curve: Curves.easeInOut, duration: Duration(seconds: 2));
    _listkey.currentState?.insertItem(insertIndex, duration: Duration(milliseconds:200));
    if (_listkey.currentState != null) {
      _listcontroller.jumpTo(1.0);
    }
  }

  Function _reset() {
    if (dependencies.stopwatch.isRunning) {
      return () {
        _lap();
        setState(() {
          // watchnMilliseconds = dependencies.stopwatch.elapsedMilliseconds;
        });
      };
    } else {
      return () {
        setState(() {
          stopwatchLaps.clear();
          _showlap = false;
        });
        dependencies.stopwatch.stop();
        dependencies.stopwatch.reset();
      };
    }
  }

  bool notNull(Object o) => o != null;

  Widget displayTime() {
    var width = getWidth(context);
    TextStyle textStyle = TextStyle(
      fontSize: width / 8,
      fontFamily: 'digital-dream',
      // fontFamily: "Bebas Neue",
    );
    return FittedBox(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              TimerText(
                dependencies: dependencies,
                // column: true,
                milli: true,
                textStyle: textStyle,
              ),
            ].where(notNull).toList(),
          ),
        ].where(notNull).toList(),
      ),
    );
  }

  _getSize(GlobalKey key) {
    final RenderBox renderBoxWidget = key?.currentContext?.findRenderObject();
    renderBoxWidget.size;
    setState(() {
      _containerSize = renderBoxWidget.size;
    });
  }

  Widget utilButtons({
    double top = 0.0,
    double bottom = 0.0,
    double left = 0.0,
    double right = 0.0,
    double width = 0.0,
  }) {
    Color foregroundColor = Theme.of(context).buttonColor;
    // _getSize(_keyButtonStart);
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: _containerSize.width,
            height: _containerSize.height,
            child: MaterialButton(
              minWidth: _containerSize.width,
              height: _containerSize.height,
              color: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(15.0),
              ),
              child: dependencies.stopwatch.isRunning
                  ? Text("Lap", style: TextStyle(fontSize: _containerSize.height*0.50))
                  : Icon(Icons.restore, size: _containerSize.height),
              onPressed: _reset(),
            ),
          ),
          SizedBox(
            width: width,
          ),
          Container(
            // key: _keyButtonStart,
            padding: EdgeInsets.all(0.0),
            margin: EdgeInsets.all(0.0),
            child: new AniIcon(
              key: _keyButtonStart,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(15.0),
              ),
              color: foregroundColor,
              iconData: AnimatedIcons.play_pause,
              notifyParent: _startAndpause,
              controller: _controller,
              size: getWidth(context)*0.10,
              // reset: resetAniIcon,
            ),
          ),
          // SizedBox(
          //   width: width,
          // ),
        ],
      ),
    );
  }
}
