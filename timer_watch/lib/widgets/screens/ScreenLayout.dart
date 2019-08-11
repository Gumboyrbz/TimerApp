import 'package:flutter/material.dart';
import 'package:timer_watch/widgets/speeddial.dart';
import 'dart:async';
import 'Provider.dart';
import 'TimerData.dart';
import 'appstate.dart';
import '../animatedicons.dart';
import '../customText.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

var timeData = new Data();
var appState = new AppState(timeData);

class ScreenLayout extends StatefulWidget {
  @override
  _ScreenLayoutState createState() => _ScreenLayoutState();
}

class _ScreenLayoutState extends State<ScreenLayout>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  var name = "Gumboy";
  static String defaultTime = "00:00:00";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String _timeString = defaultTime;
  String _backupTimer = defaultTime;
  int _backupDurationInSecs = 0;
  bool ignoreState = false;
  bool resetAniIcon = false;
  Timer _timer;
  int durationInSecs = 0;
  Stopwatch stopwatch = new Stopwatch();
  bool saveTime;
  GlobalKey _utilContainerKey = GlobalKey();
  Size _utilContainerSize = Size(0, 0);

  _getContainerSize() {
    final RenderBox containerRenderBox =
        _utilContainerKey.currentContext.findRenderObject();
    final containerSize = containerRenderBox.size;
    setState(() {
      _utilContainerSize = containerSize;
    });
  }

  _onBuildCompleted(_) {
    _getContainerSize();
  }

  double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  @override
  bool get wantKeepAlive => true;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings(
        'outline_check_circle_outline_white_48');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(
      initSetttings,
      onSelectNotification: onSelectNotification,
    );

    _controller = new AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 0.0,
      vsync: this,
    );
    resetTimer();
  }

  Future onSelectNotification(String payload) async {
    stopAlarm();
  }

  Future alarmNotification() async {
    FlutterRingtonePlayer.play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      volume: 1.0,
      looping: false,
    );
  }

  Future startAlarm() async {
    showNotification();
    alarmNotification();
  }

  Future stopAlarm() async {
    FlutterRingtonePlayer.stop();
    flutterLocalNotificationsPlugin.cancel(0);
  }

  Future showNotification() async {
    var android = new AndroidNotificationDetails(
      'Gumboyrbz',
      'All notificatons',
      'Nothing Yet',
      priority: Priority.High,
      importance: Importance.Max,
      playSound: false,
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
      0,
      '$_backupTimer Timer Complete',
      'Tap to Stop Alarm',
      platform,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_onBuildCompleted);
    return new Provider(
      data: appState,
      child: OrientationBuilder(
        builder: (orientcontext, orientation) {
          return LayoutBuilder(
            builder: (BuildContext layoutcontext, BoxConstraints constraints) {
              if (orientation == Orientation.portrait) {
                return _buildVerticalLayout();
              } else if (orientation == Orientation.landscape) {
                if (constraints.maxHeight > 400) {
                  return _buildVerticalLayout(row: true);
                }
                return _buildHorizontalLayout();
              }
            },
          );
        },
      ),
    );
  }

  List<CustomTextContainer> getTextWidgets(String string) {
    final TextStyle textStyle = const TextStyle(
      fontSize: 54.0,
      fontFamily: 'digital-dream',
    );
    List<String> outString = string.split(':');
    List<String> labels = ['hours', 'minutes', 'seconds'];
    List<CustomTextContainer> widgets = [];
    outString.asMap().forEach((index, item) {
      widgets.add(
        CustomTextContainer(
          value: item,
          label: labels[index],
          textStyle: textStyle,
        ),
      );
    });
    return widgets;
  }

  void returnNull() => null;

  Duration timeToDuration({hours = 0, mins = 0, secs = 0}) {
    Duration timeToDuration =
        new Duration(hours: hours, minutes: mins, seconds: secs);
    return timeToDuration;
  }

  void setGlobalTime(Duration duration) {
    String twoDigitHours = twoDigits(duration.inHours.remainder(99));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    appState.value.hours = int.parse(twoDigitHours);
    appState.value.mins = int.parse(twoDigitMinutes);
    appState.value.secs = int.parse(twoDigitSeconds);
  }

  Duration getGlobalTime() {
    Duration global = Duration(
      hours: appState.value.hours,
      minutes: appState.value.mins,
      seconds: appState.value.secs,
    );
    return global;
  }

  void _getTime() {
    Duration timeToScreen = getGlobalTime();

    final String formattedDateTime = formatHHMMSS(timeToScreen);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String formatHHMMSS(Duration duration) {
    String twoDigitHours = twoDigits(duration.inHours.remainder(99));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    Duration _duration = timeToDuration(
      hours: int.parse(twoDigitHours),
      mins: int.parse(twoDigitMinutes),
      secs: int.parse(twoDigitSeconds),
    );
    durationInSecs = _duration.inSeconds;

    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  refresh() {
    saveTime = false;
    _getTime();
  }

  bool get isRunning => _timer != null;

  void countDown() {
    durationInSecs = getGlobalTime().inSeconds - stopwatch.elapsed.inSeconds;

    _timeString = formatHHMMSS(timeToDuration(secs: durationInSecs));
  }

  void countDownEnd() {
    startAlarm();
  }

  void startAndstop() {
    setState(() {
      if (getGlobalTime().inSeconds > 0) {
        ignoreState = !ignoreState;
        resetAniIcon = false;
      }
      (ignoreState) ? startTimer() : stopTimer();
    });
  }

  void stopTimer() {
    isRunning ? _timer.cancel() : returnNull();
    Duration updateTime = timeToDuration(secs: durationInSecs);
    setGlobalTime(updateTime);
    _getTime();
    stopwatch.isRunning ? stopwatch.stop() : returnNull();
    _timer = null;
    stopwatch.reset();
  }

  void startTimer() {
    if (!isRunning || ignoreState) {
      stopwatch.start();
      if (!saveTime) {
        saveTime = true;
        _backupDurationInSecs = durationInSecs;
        _backupTimer = _timeString;
      }

      _timer = new Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) => setState(
          () {
            if (durationInSecs == 1) {
              timer.cancel();
              countDownEnd();
              resetTimer();
            } else {
              countDown();
            }
          },
        ),
      );
    }
  }

  void resetTimer() {
    _timeString = defaultTime;
    durationInSecs = 0;
    _backupTimer = defaultTime;
    _backupDurationInSecs = 0;
    stopTimer();
    setState(() {
      ignoreState = false;
      resetAniIcon = true;
      saveTime = false;
    });
  }

  void redoTimer() {
    stopTimer();
    setState(() {
      ignoreState = false;
      durationInSecs = 0;
      resetAniIcon = true;
    });
    _timeString = _backupTimer;
    durationInSecs = _backupDurationInSecs;
    setGlobalTime(timeToDuration(secs: durationInSecs));
  }

  Function _redoButton() {
    int secs = getGlobalTime().inSeconds;
    if (!ignoreState && secs <= 0) {
      return null;
    } else if ((ignoreState) || (secs < _backupDurationInSecs)) {
      return () {
        return redoTimer();
      };
    } else if ((secs == _backupDurationInSecs)) {
      return null;
    }
  }

  Function _resetButton() {
    int secs = getGlobalTime().inSeconds;

    if (secs == 0) {
      return null;
    } else {
      return () {
        return resetTimer();
      };
    }
  }

  Widget speedDialWidget(
      {double top = 0.0,
      double bottom = 0.0,
      double left = 0.0,
      double right = 0.0,
      double width = 0.0}) {
    return IgnorePointer(
      ignoring: ignoreState,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new SpeedDial(
                icons: ["6", "4", "2", "1"],
                type: "Hours",
                notifyParent: refresh,
                buttonDisabled: ignoreState,
              ),
              SizedBox(
                width: width,
              ),
              new SpeedDial(
                icons: ["30", "10", "5", "1"],
                type: "Mins",
                notifyParent: refresh,
                buttonDisabled: ignoreState,
              ),
              SizedBox(
                width: width,
              ),
              new SpeedDial(
                icons: ["30", "10", "5", "1"],
                type: "Secs",
                notifyParent: refresh,
                buttonDisabled: ignoreState,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget utilButtons(
      {double top = 0.0,
      double bottom = 0.0,
      double left = 0.0,
      double right = 0.0,
      double width = 0.0}) {
    Color foregroundColor = Theme.of(context).buttonColor;
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            minWidth: _utilContainerSize.width,
            height: _utilContainerSize.height,
            color: foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15.0),
            ),
            child: Icon(
              Icons.restore,
              size: _utilContainerSize.height,
            ),
            onPressed: _resetButton(),
          ),
          SizedBox(
            width: width,
          ),
          Container(
            child: new AniIcon(
              key: _utilContainerKey,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(15.0),
              ),
              color: foregroundColor,
              iconData: AnimatedIcons.play_pause,
              notifyParent: startAndstop,
              valEmpty: durationInSecs,
              reset: resetAniIcon,
              controller: _controller,
              size: getWidth(context) * 0.10,
            ),
          ),
          SizedBox(
            width: width,
          ),
          MaterialButton(
            minWidth: _utilContainerSize.width,
            height: _utilContainerSize.height,
            color: foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15.0),
            ),
            child: Icon(
              Icons.autorenew,
              size: _utilContainerSize.height,
            ),
            onPressed: _redoButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout({bool row = false}) {
    var width = getWidth(context);
    var height = getHeight(context);
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Container(
            height: height * 0.85,
            child: AspectRatio(
              aspectRatio: row ? 6 / 4 : 2 / 7,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0.0),
                crossAxisCount: row ? 3 : 1,
                children: getTextWidgets(_timeString),
              ),
            ),
          ),
          Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      speedDialWidget(width: width * 0.05),
                    ],
                  ),
                  utilButtons(width: width * 0.05),
                  Padding(
                    padding: EdgeInsets.only(bottom: height * 0.02),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalAboveWidth() {
    var width = getWidth(context);
    var height = getHeight(context);
    return Center(
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                children: getTextWidgets(_timeString),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        speedDialWidget(width: width * 0.05),
                      ],
                    ),
                    utilButtons(width: width * 0.05),
                    Padding(
                      padding: EdgeInsets.only(bottom: height * 0.02),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBelowWidth() {
    var width = getWidth(context);
    var height = getHeight(context);
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: GridView.count(
                    shrinkWrap: false,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    children: getTextWidgets(_timeString),
                  ),
                ),
                Transform.scale(
                  scale: (height * 0.850) / height,
                  alignment: Alignment.bottomCenter,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: <Widget>[
                            Positioned(
                              bottom: height * 0.22,
                              child: speedDialWidget(width: width * 0.05),
                            ),
                            Positioned(
                              bottom: height * 0.05,
                              child: utilButtons(width: width * 0.05),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
}
