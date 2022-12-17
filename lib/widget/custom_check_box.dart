import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../my_flutter_app_icons.dart';
import '../presentation/app_images.dart';

class CheckboxCustom extends StatefulWidget {
  const CheckboxCustom({
    Key? key,
    required this.value,
    required this.disabled,
    required this.onChanged,
  }) : super(key: key);

  final bool? disabled;
  final bool? value;
  final void Function(bool?)? onChanged;

  @override
  State<CheckboxCustom> createState() => _CheckboxCustomState();
}

class _CheckboxCustomState extends State<CheckboxCustom> {
  bool? curValue;
  late dynamic icon;

  @override
  void initState() {
    curValue = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CheckboxCustom oldWidget) {
    if (oldWidget.value != widget.value) {
      curValue = widget.value;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  dynamic getIcon() {
    if (widget.disabled == true) {
      icon = Icons.visibility_off;
    } else {
      if (curValue == true) {
        icon = AppImages.check_box;
      } else {
        icon = MyFlutterApp.check_box_outline;
      }
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    final checkBox = getIcon();
    return GestureDetector(
      onLongPress: widget.onChanged == null
          ? null
          : () {
              widget.onChanged!(null);
              setState(() {});
            },
      onTap: widget.onChanged == null
          ? null
          : () {
              if (widget.disabled == false) {
                curValue = !curValue!;
              }

              widget.onChanged!(curValue);
              setState(() {});
            },
      child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) {
            final rotateAnim = Tween(begin: math.pi, end: 0.0).animate(anim);
            return AnimatedBuilder(
              animation: rotateAnim,
              child: child,
              builder: (context, widget) {
                final value = math.min(rotateAnim.value, math.pi / 2);
                return Transform(
                  transform: Matrix4.rotationY(value),
                  child: widget,
                  alignment: Alignment.center,
                );
              },
            );
          },
          child: checkBox is IconData
              ? Icon(
                  checkBox,
                  key: ValueKey(checkBox),
                  color: widget.disabled == false
                      ? const Color(0xFF5F5e63)
                      : const Color(0xFF5F5e63),
                  size: 18,
                )
              : Image.asset(
                  checkBox,
                  key: ValueKey(checkBox),
                  width: 18,
                )),
    );
  }
}
