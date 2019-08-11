import 'package:flutter/material.dart';
import 'depends.dart';

class CustomTextContainer extends StatefulWidget {
  CustomTextContainer(
      {this.label, this.value, this.dependencies, this.textStyle});

  final String label;
  final String value;
  final Dependencies dependencies;
  final TextStyle textStyle;

  @override
  _CustomTextContainerState createState() => _CustomTextContainerState(
      dependencies: dependencies, textStyle: textStyle);
}

class _CustomTextContainerState extends State<CustomTextContainer> {
  _CustomTextContainerState({this.dependencies, this.textStyle});
  final Dependencies dependencies;
  TextStyle textStyle;
  @override
  Widget build(BuildContext context) {
    if (dependencies != null) {
      textStyle = dependencies.textStyle;
    }
    return FittedBox(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.all(20),
        decoration: new BoxDecoration(
        color: Colors.black12,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 5.0),
          ),
        ],
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FittedBox(
              child: Center(
                child: Text(
                  '${widget.value}',
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
            ),
            Text(
              '${widget.label}',
              style: TextStyle(
                color: Colors.white,
                fontSize: textStyle.fontSize/4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
