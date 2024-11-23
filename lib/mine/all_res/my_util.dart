import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';


class MyUtil {

  //震动
  static Future<void> vibrate() async {

    // bool? hasVib=await Vibration.hasAmplitudeControl();
    // print(hasVib);
    // Vibration.vibrate();
    // Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, ]);
    // Vibration.vibrate(pattern: [0,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,], intensities: [20]);
    // Vibration.vibrate(pattern: [0, 50]);
    HapticFeedback.lightImpact();
    // if (hasVib??false) {
    //   // Vibration.vibrate(amplitude: 128);
    //   // Vibration.vibrate();
    // }
    // Vibration.vibrate(duration: 100);
  }
 static  void printLongString(String str) {
    const int chunkSize = 800; // 每次打印的字符数，可以根据需要调整
    int start = 0;
    while (start < str.length) {
      int end = start + chunkSize;
      if (end > str.length) {
        end = str.length;
      }
      print(str.substring(start, end));
      start = end;
    }
  }




}

class ToastUtils {
  static show(String name) {
    Fluttertoast.showToast(
        msg: name,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
