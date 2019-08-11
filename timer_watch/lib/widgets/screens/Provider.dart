import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'TimerData.dart';

class Provider extends StatefulWidget {
  const Provider({this.data, this.child});
  final data;
  final child;
  @override
  _ProviderState createState() => _ProviderState();

  static of(BuildContext context) {
    _InheritedProvider p =
        context.inheritFromWidgetOfExactType(_InheritedProvider);
    return p.data;
  }
}

class _ProviderState extends State<Provider> {
  @override
  Widget build(BuildContext context) {
    return new _InheritedProvider(
      data: widget.data,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.data.addListener(didValueChange);
  }

  didValueChange() => setState(() {});

  @override
  void dispose() {
    widget.data.removeListener(didValueChange);
    super.dispose();
  }
}

class _InheritedProvider extends InheritedWidget {
  final appBloc = AppBloc();
  _InheritedProvider({this.data, this.child})
      : _dataValue = data.value,
        super(child: child);
  final data;
  final child;
  final _dataValue;
  @override
  bool updateShouldNotify(_InheritedProvider oldWidget) {
    return _dataValue != oldWidget._dataValue;
  }
}

class AppBloc {
  //This is the output interface of Bloc
  ValueObservable<Data> get list => _list.stream;//seedValue: '/'
  final _list = BehaviorSubject<Data>();//seedValue: '/'

  // This is the input interface of Bloc
  Sink<Data> get listChange => _listChangeController.sink;
  final _listChangeController = StreamController<Data>();

  AppBloc(){
    _listChangeController.stream.listen(_handleListChange);
  }
  // This is the logic handling input
  void _handleListChange(Data newList){
    _list.add(newList);
  }
  void dispose(){
    _listChangeController.close();
  }
}  

