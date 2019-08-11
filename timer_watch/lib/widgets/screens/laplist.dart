import 'package:flutter/material.dart';

// class UpdateAnimatedListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Update AnimatedList')),
//       body: BodyLayout(),
//     );
//   }
// }

class BodyLayout extends StatefulWidget {
  BodyLayout({this.listkey, this.laps, this.controller});
  final List<int> laps;
  final GlobalKey<AnimatedListState> listkey;
  final ScrollController controller;

  @override
  BodyLayoutState createState() {
    return new BodyLayoutState(
        listkey: listkey, laps: laps, controller: controller);
  }
}

class BodyLayoutState extends State<BodyLayout> {
  BodyLayoutState({this.listkey, this.laps, this.controller});
  final List<int> laps;
  final GlobalKey<AnimatedListState> listkey;
  final ScrollController controller;
  // The GlobalKey keeps track of the visible state of the list items
  // while they are being animated.
  // final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  // backing data
  // List<int> _data = laps;

  double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  String formatHHMMSS(int milli) {
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

    Duration duration = Duration(milliseconds: milli);
    String twoDigitHours = twoDigits(duration.inHours.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMillis =
        threeDigits(duration.inMilliseconds.remainder(1000));

    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds.$twoDigitMillis";
  }

  @override
  Widget build(BuildContext context) {
    double height = getHeight(context);
    double width = getWidth(context);
    return AnimatedList(
      // shrinkWrap: true,
      controller: controller,
      padding: EdgeInsets.all(0.0),
      // Give the Animated list the global key
      key: listkey,
      initialItemCount: laps.length,
      // Similar to ListView itemBuilder, but AnimatedList has
      // an additional animation parameter.
      itemBuilder: (context, index, animation) {
        // Breaking the row widget out as a method so that we can
        // share it with thespaceAround _removeSingleItem() method.
        return _buildItem(
            (laps.length - index).toString(), laps[index], animation);
      },
    );
  }

  // This is the animated row with the Card.
  Widget _buildItem(String count, int item, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          leading: Text(count),
          title: Text(
            formatHHMMSS(item),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  // void _insertSingleItem() {
  //   int newItem = 1;
  //   // Arbitrary location for demonstration purposes
  //   int insertIndex = 0;
  //   // Add the item to the data list.
  //   laps.insert(insertIndex, newItem);
  //   // Add the item visually to the AnimatedList.
  //   listkey.currentState.insertItem(insertIndex);
  // }

  // void _removeSingleItem() {
  //   int removeIndex = 0;
  //   // Remove item from data list but keep copy to give to the animation.
  //   int removedItem = laps.removeAt(removeIndex);
  //   // This builder is just for showing the row while it is still
  //   // animating away. The item is already gone from the data list.
  //   AnimatedListRemovedItemBuilder builder = (context, animation) {
  //     return _buildItem(removedItem, animation);
  //   };
  //   // Remove the item visually from the AnimatedList.
  //   listkey.currentState.removeItem(removeIndex, builder);
  // }
}
