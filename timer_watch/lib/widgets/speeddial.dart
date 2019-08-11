import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'screens/Provider.dart';

class SpeedDial extends StatefulWidget {
  SpeedDial(
      {Key key,
      this.icons,
      this.type,
      this.buttonDisabled = false,
      @required this.notifyParent})
      : super(key: key);

  final List<String> icons;
  final String type;
  final Function() notifyParent;
  final bool buttonDisabled;
  @override
  State createState() => new SpeedDialState();
}

class SpeedDialState extends State<SpeedDial> with TickerProviderStateMixin {
  AnimationController _controller;

  // static const List<IconData> icons = const [ Icons.sms, Icons.mail, Icons.phone ];
  RestartableTimer _timer;
  
  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _timer = new RestartableTimer(const Duration(milliseconds: 2000), () {
      _controller.reverse();
    });
    _timer.cancel();
  }

  void _increaseHours(context, int count) {
    var stateHours = Provider.of(context);
    stateHours.value.hours += count;
  }

  void _increaseMins(context, int count) {
    var stateMins = Provider.of(context);
    stateMins.value.mins += count;
  }

  void _increaseSecs(context, int count) {
    var stateSecs = Provider.of(context);
    stateSecs.value.secs += count;
  }

  void determineAndCalulate(context, int value) {
    if (widget.type == "Hours") {
      _increaseHours(context, value);
    }
    if (widget.type == "Mins") {
      _increaseMins(context, value);
    }
    if (widget.type == "Secs") {
      _increaseSecs(context, value);
    }
    widget.notifyParent();
  }

  String appendString(item) {
    item = "+" + item;
    if (widget.type == "Hours") {
      return item + "hr";
    }
    if (widget.type == "Mins") {
      return item + "min";
    }
    if (widget.type == "Secs") {
      return item + "sec";
    }
    return "";
  }

  double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  Widget build(BuildContext context) {
    // Color backgroundColor = Theme.of(context).;
    Color foregroundColor = Theme.of(context).buttonColor;
    Map<String, int> timeMap = new Map.fromIterable(widget.icons,
        key: (item) {
          return appendString(item);
        },
        value: (item) => int.parse(item));
    var timekeys = timeMap.keys.toList();
    var timevalues = timeMap.values.toList();
    // var width = getWidth(context);
    var height = getHeight(context);
    return Stack(
      children: <Widget>[
        new Column(
          mainAxisSize: MainAxisSize.min,
          children: new List.generate(widget.icons.length - 1, (int index) {
            Widget child = new Container(
              height: height*0.08,
              alignment: FractionalOffset.topCenter,
              child: new ScaleTransition(
                scale: new CurvedAnimation(
                  parent: _controller,
                  curve: new Interval(
                      0.0, 1.0 - index / widget.icons.length / 2.0,
                      curve: Curves.easeInCubic),
                ),
                child: Container(
                  height: height*0.075,
                  child: new FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                    ),
                    heroTag: null,
                    // backgroundColor: backgroundColor,
                    // foregroundColor: foregroundColor,
                    // mini: true,
                    child: new Text(
                      timekeys[index],
                      // "+${widget.icons[index]}",
                    ),
                    onPressed: () {
                      determineAndCalulate(context, timevalues[index]);
                      _timer.reset();
                    },
                  ),
                ),
              ),
            );
            return child;
          }).toList()
            ..add(
              Container(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: () {
                    if (_controller.isDismissed) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  },
                  onTapCancel: () => _timer.reset(),
                  child: new MaterialButton(
                    color: foregroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                    ),
                    child: new AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget child) {
                        return new Transform(
                          transform: new Matrix4.rotationZ(
                              _controller.value * 0.0 * math.pi),
                          alignment: FractionalOffset.center,
                          child: Text(timekeys.last),
                        );
                      },
                    ),
                    onPressed: _lastButton(timevalues.last),
                  ),
                ),
              ),
            ),
        ),
      ],
    );
  }

  Function _lastButton(int val) {
    if (widget.buttonDisabled) {
      return null;
    } else {
      return () {
        determineAndCalulate(context, val);
      };
    }
  }
}
