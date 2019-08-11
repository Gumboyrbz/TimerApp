import 'package:flutter/material.dart';
class ElapsedTime {
  final int milliseconds;
  final int seconds;
  final int minutes;
  final int hours;
  final int days;

  ElapsedTime({
    this.milliseconds,
    this.seconds,
    this.minutes,
    this.hours,
    this.days,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  // final TextStyle textStyle = const TextStyle(
  //   fontSize: 54.0,
  //   fontFamily: 'digital-dream',
  //   // fontFamily: "Bebas Neue",
  // );
  TextStyle textStyle;
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 60;
  final List<int> laps = [];
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String threeDigits(int n) {
    if (n >= 100) {
      return "$n";
    } else if (n >= 10 && n < 100) {
      return "0$n";
    }
    return "00$n";
  }
  TextStyle get style{
    return textStyle;
  }
  
  set style(TextStyle style){
    this.textStyle = style;
  }
}