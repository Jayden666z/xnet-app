import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'color_styles.dart';
import 'my_util.dart';

//有按下效果的Container
class PressableContainer extends StatefulWidget {
  bool enableVibrate;
  Widget child;
  bool enableAnimate;
  bool enableDeepColor;
  bool enableShape;
  Function()? onTap;
  bool enableLoading;
  double? height;
  double? width;
  bool selected;

  PressableContainer(
      {super.key,
      required this.child,
      this.enableAnimate = false,
      this.onTap,
      this.enableVibrate = false,
      this.enableDeepColor = false,
      this.enableShape = true,
      this.enableLoading = false,
      this.selected = false,
      this.height,
      this.width});

  @override
  _PressableContainerState createState() => _PressableContainerState();
}

class _PressableContainerState extends State<PressableContainer> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    print('onTapDown');
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    print('onTapUp');
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    print('onTapCancel');
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTap() async {
    print('handleTap');
    setState(() {
      _isPressed = true;
    });
    print('handleTap' + _isPressed.toString());
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _isPressed = false;
    });
    print('handleTap' + _isPressed.toString());
    if (widget.onTap != null) {
      widget.onTap!();
    }
    if (widget.enableVibrate) {
      MyUtil.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _handleTap,
      child: AnimatedScale(
        scale: (_isPressed && widget.enableAnimate) ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: DefaultTextStyle(
          style: widget.enableDeepColor
              ? const TextStyle(color: Colors.white)
              : const TextStyle(color: Colors.black),
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              border:widget.selected?Border.all(
                color: Colors.black, // 边框颜色
                width: 1.0, // 边框宽度
              ):Border.all(
                color: Colors.white, // 边框颜色
                width: 1.0, // 边框宽度
              ),
              color: widget.enableDeepColor ? Colors.black :( widget.selected?ColorStyles.color_90_white:Colors.white),
              borderRadius: BorderRadius.circular(15),
              boxShadow: _isPressed && widget.enableAnimate
                  ? (widget.enableShape?[
                      BoxShadow(
                        color: ColorStyles.color_80_white.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ]:null)
                  :  (widget.enableShape?[
                      BoxShadow(
                        color: ColorStyles.color_80_white.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]:null),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: widget.enableLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: SpinKitFadingCircle(
                        color: Colors.white,
                        size: 20.0,
                      ),
                    )
                  : widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
