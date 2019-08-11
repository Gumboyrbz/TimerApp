import 'package:flutter/material.dart';

class AniIcon extends StatefulWidget {
  AniIcon({
    Key key,
    this.iconData,
    this.title,
    this.semantics = "Animated Label",
    this.duration,
    this.controller,
    this.notifyParent,
    this.valEmpty,
    this.color,
    this.shape,
    this.reset,
    this.size,
  }) : super(key: key);

  final Duration duration;
  final String title;
  final String semantics;
  final AnimatedIconData iconData;
  final Function() notifyParent;
  final AnimationController controller;
  final int valEmpty;
  final Color color;
  final ShapeBorder shape;
  final bool reset;
  final double size;
  @override
  _AniIconState createState() => _AniIconState();
}

class _AniIconState extends State<AniIcon> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return getAnimatedIcon(
        iconData: widget.iconData,
        title: widget.title,
        sematics: widget.semantics); // ...
  }

  bool get _status {
    final AnimationStatus status = widget.controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  @override
  void didUpdateWidget(AniIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.duration = widget.duration;
    if (widget.valEmpty != null || widget.reset != null) {
      if (widget.valEmpty == 0 || widget.reset) {
        widget.controller.reset();
      }
    }
  }

  bool notNull(Object o) => o != null;
  void returnNull() => null;
  getAnimatedIcon({AnimatedIconData iconData, String title, String sematics}) {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new MaterialButton(
              // alignment: Alignment.center,
              shape: widget.shape,
              color: widget.color,
              // padding: EdgeInsets.all(10.0),
              clipBehavior: Clip.antiAlias,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                if (widget.valEmpty != null || widget.reset != null) {
                  (widget.valEmpty != 0)
                      ? widget.controller.fling(velocity: _status ? -2.0 : 2.0)
                      : returnNull();
                } else {
                  widget.controller.fling(velocity: _status ? -2.0 : 2.0);
                }
                widget.notifyParent != null
                    ? widget.notifyParent()
                    : returnNull();
              },
              child: new AnimatedIcon(
                icon: iconData,
                size: widget.size != null ? widget.size : null,
                progress: widget.controller.view,
                semanticLabel: sematics,
              ),
            ),
            (title != null) ? new Text(title) : null
          ].where(notNull).toList(),
        ),
      ),
    );
  }
}
