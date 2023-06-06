import 'package:flutter/widgets.dart';
import 'package:webrtc_flutter/initial.dart';
import 'package:webrtc_flutter/main.dart';

class Routes {
  final Map<String, WidgetBuilder> routes = {
    '/initial': (BuildContext context) => Initial(),
    '/home': (BuildContext context) => MyHomePage(title: "WEBRTC"),
  };
}
