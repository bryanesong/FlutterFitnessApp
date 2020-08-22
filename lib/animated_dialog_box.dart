import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class animated_dialog_box {
  static Future showCustomAlertBox({
    @required BuildContext context,
    @required Widget yourWidget,
    @required Widget firstButton,
  }) {
    assert(context != null, "context is null!!");
    assert(yourWidget != null, "yourWidget is null!!");
    assert(firstButton != null, "Button is null!!");
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                yourWidget,
              ],
            ),
            actions: <Widget>[firstButton],
            elevation: 10,
          );
        });
  }
}