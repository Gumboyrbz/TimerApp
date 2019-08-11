import 'package:flutter/material.dart';
import 'dart:async';

import 'depends.dart';
import 'customText.dart';
class TimerText extends StatefulWidget {
  TimerText({this.dependencies, this.textStyle,this.column = false, this.milli = true});
  final Dependencies dependencies;
  final bool column;
  final bool milli;
  TextStyle textStyle;
  TimerTextState createState() => new TimerTextState(
      dependencies: dependencies, column: column, milli: milli, textStyle: textStyle);
}

class TimerTextState extends State<TimerText>
    with AutomaticKeepAliveClientMixin {
  TimerTextState({this.dependencies, this.column, this.milli, this.textStyle});
  final Dependencies dependencies;
  final bool column;
  final bool milli;
  Timer timer;
  Duration duration;
  TextStyle textStyle;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    timer = new Timer.periodic(
        new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
        callback);
    duration = new Duration(milliseconds: 0);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    duration = null;
    super.dispose();
  }

  Widget rowLayout() {
    return Row(
      children: <Widget>[
        duration.inDays != 0
            ? new RepaintBoundary(
                child: Days(
                  dependencies: dependencies,
                ),
              )
            : null,
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            duration.inHours != 0
                ? new RepaintBoundary(
                    child: Hours(
                      dependencies: dependencies,
                    ),
                  )
                : null,
            new RepaintBoundary(
              child: new Minutes(dependencies: dependencies),
            ),
            new RepaintBoundary(
              child: new Seconds(dependencies: dependencies),
            ),
            milli
                ? new RepaintBoundary(
                    child: new Milliseconds(dependencies: dependencies),
                  )
                : null,
          ].where(notNull).toList(),
        ),
      ].where(notNull).toList(),
    );
  }

  Widget columnLayout() {
    return Column(
      children: <Widget>[
        duration.inDays != 0
            ? new RepaintBoundary(
                child: Days(
                  dependencies: dependencies,
                ),
              )
            : null,
        new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            duration.inHours != 0
                ? new RepaintBoundary(
                    child: Hours(
                      dependencies: dependencies,
                    ),
                  )
                : null,
            new RepaintBoundary(
              child: new Minutes(dependencies: dependencies),
            ),
            new RepaintBoundary(
              child: new Seconds(dependencies: dependencies),
            ),
            milli
                ? new RepaintBoundary(
                    child: new Milliseconds(dependencies: dependencies),
                  )
                : null,
          ].where(notNull).toList(),
        ),
      ].where(notNull).toList(),
    );
  }

  void callback(Timer timer) {
    if (duration.inMilliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      duration = dependencies
          .stopwatch.elapsed; // + Duration(hours: 23, minutes: 59,seconds: 50);
      int days = duration.inDays;
      int hours = duration.inHours.remainder(24);
      int minutes = duration.inMinutes.remainder(60);
      int seconds = duration.inSeconds.remainder(60);
      int milliseconds = duration.inMilliseconds.remainder(1000);

      final ElapsedTime elapsedTime = new ElapsedTime(
        milliseconds: milliseconds,
        seconds: seconds,
        minutes: minutes,
        hours: hours,
        days: days,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  bool notNull(Object o) => o != null;

  @override
  Widget build(BuildContext context) {
    dependencies.style = textStyle;
    return column ? columnLayout() : rowLayout();
  }
}

class Minutes extends StatefulWidget {
  Minutes({this.dependencies});
  final Dependencies dependencies;

  MinutesState createState() => new MinutesState(dependencies: dependencies);
}

class MinutesState extends State<Minutes> {
  MinutesState({this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  @override
  void dispose() {
    dependencies.timerListeners.remove(onTick);
    super.dispose();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes) {
      setState(() {
        minutes = elapsed.minutes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = dependencies.twoDigits(minutes);
    return FittedBox(
      child: CustomTextContainer(
        label: 'minutes',
        value: minutesStr,
        dependencies: dependencies,
      ),
    );
  }
}

class Seconds extends StatefulWidget {
  Seconds({this.dependencies});
  final Dependencies dependencies;

  SecondsState createState() => new SecondsState(dependencies: dependencies);
}

class SecondsState extends State<Seconds> {
  SecondsState({this.dependencies});
  final Dependencies dependencies;

  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  @override
  void dispose() {
    dependencies.timerListeners.remove(onTick);
    super.dispose();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.seconds != seconds) {
      setState(() {
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String secondsStr = dependencies.twoDigits(seconds);
    return FittedBox(
      child: CustomTextContainer(
        label: 'seconds',
        value: secondsStr,
        dependencies: dependencies,
      ),
    );
  }
}

class Milliseconds extends StatefulWidget {
  Milliseconds({this.dependencies});
  final Dependencies dependencies;

  MillisecondsState createState() =>
      new MillisecondsState(dependencies: dependencies);
}

class MillisecondsState extends State<Milliseconds> {
  MillisecondsState({this.dependencies});
  final Dependencies dependencies;

  int milliseconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  @override
  void dispose() {
    dependencies.timerListeners.remove(onTick);

    super.dispose();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.milliseconds != milliseconds) {
      setState(() {
        milliseconds = elapsed.milliseconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String millisecondsStr = dependencies.threeDigits(milliseconds);
    return FittedBox(
      child: new CustomTextContainer(
        label: 'milliseconds',
        value: millisecondsStr,
        dependencies: dependencies,
      ),
    );
  }
}

class Hours extends StatefulWidget {
  Hours({this.dependencies});
  final Dependencies dependencies;

  HoursState createState() => new HoursState(dependencies: dependencies);
}

class HoursState extends State<Hours> {
  HoursState({this.dependencies});
  final Dependencies dependencies;

  int hours = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  @override
  void dispose() {
    dependencies.timerListeners.remove(onTick);

    super.dispose();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hours != hours) {
      setState(() {
        hours = elapsed.hours;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hoursStr = dependencies.twoDigits(hours);
    return FittedBox(
      child: new CustomTextContainer(
        label: 'hours',
        value: hoursStr,
        dependencies: dependencies,
      ),
    );
  }
}

class Days extends StatefulWidget {
  Days({this.dependencies});
  final Dependencies dependencies;

  DaysState createState() => new DaysState(dependencies: dependencies);
}

class DaysState extends State<Days> {
  DaysState({this.dependencies});
  final Dependencies dependencies;

  int days = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  @override
  void dispose() {
    dependencies.timerListeners.remove(onTick);

    super.dispose();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.days != days) {
      setState(() {
        days = elapsed.days;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String daysStr = days.toString();
    return FittedBox(
      child: new CustomTextContainer(
        label: 'days',
        value: daysStr,
        dependencies: dependencies,
      ),
    );
  }
}

// class CustomTextContainer extends StatefulWidget {
//   CustomTextContainer({this.label, this.value, this.dependencies});

//   final String label;
//   final String value;
//   final Dependencies dependencies;

//   @override
//   _CustomTextContainerState createState() =>
//       _CustomTextContainerState(dependencies: dependencies);
// }

// class _CustomTextContainerState extends State<CustomTextContainer> {
//   _CustomTextContainerState({this.dependencies});
//   final Dependencies dependencies;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 5),
//       padding: EdgeInsets.all(20),
//       decoration: new BoxDecoration(
//           borderRadius: new BorderRadius.circular(10), color: Colors.black54),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           FittedBox(
//             child: Center(
//               child: Text(
//                 '${widget.value}',
//                 textAlign: TextAlign.center,
//                 style: dependencies.textStyle,
//               ),
//             ),
//           ),
//           Text(
//             '${widget.label}',
//             style: TextStyle(
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
