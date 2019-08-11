import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

class CountDownTimer extends StatefulWidget {
  const CountDownTimer({
    Key key,
    int secondsRemaining,
    this.countDownTimerStyle,
    this.whenTimeExpires,
    this.countDownFormatter,
    this.timeOutput,
  })  : secondsRemaining = secondsRemaining,
        super(key: key);

  final int secondsRemaining;
  final Function whenTimeExpires;
  final Function countDownFormatter;
  final TextStyle countDownTimerStyle;
  final Function timeOutput;
  State createState() => new _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Duration duration;

  String get timerDisplayString {
    Duration duration = _controller.duration * _controller.value;
    return widget.countDownFormatter != null
        ? widget.countDownFormatter(duration.inSeconds)
        : formatHHMMSS(duration);
    // In case user doesn't provide formatter use the default one
    // for that create a method which will be called formatHHMMSS or whatever you like
  }

  String formatHHMMSS(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // print("${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds");
    return "${twoDigits(duration.inHours)}$twoDigitMinutes$twoDigitSeconds";
  }
  void beginAnimation(){
   _controller.reverse(from: widget.secondsRemaining.toDouble());
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        widget.whenTimeExpires();
      }
    }); 
  }
  @override
  void initState() {
    super.initState();
    duration = new Duration(seconds: widget.secondsRemaining);
    _controller = new AnimationController(
      vsync: this,
      duration: duration,
    );
    // _controller.reverse(from: widget.secondsRemaining.toDouble());
    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed ||
    //       status == AnimationStatus.dismissed) {
    //     widget.whenTimeExpires();
    //   }
    // });
  }

  @override
  void didUpdateWidget(CountDownTimer oldWidget) {
    if (widget.secondsRemaining != oldWidget.secondsRemaining) {
      setState(() {
        duration = new Duration(seconds: widget.secondsRemaining);
        _controller.dispose();
        _controller = new AnimationController(
          vsync: this,
          duration: duration,
        );
        // _controller.reverse(from: widget.secondsRemaining.toDouble());
        // _controller.addStatusListener((status) {
        //   if (status == AnimationStatus.completed) {
        //     widget.whenTimeExpires();
        //   } else if (status == AnimationStatus.dismissed) {
        //     print("Animation Complete");
        //   }
        // });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, Widget child) {
          return GridView.count(
            crossAxisCount: 2,
            children: widget.timeOutput(
              timerDisplayString,
              // style: widget.countDownTimerStyle,
            ),
          );
        },
      ),
    );
  }
}
