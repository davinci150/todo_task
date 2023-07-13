import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../main.dart';
import '../presentation/app_colors.dart';
import '../presentation/my_flutter_app_icons.dart';
import '../providers/theme_provider.dart';

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
  late IconData icon;

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

  IconData getIcon() {
    if (widget.disabled == true) {
      icon = Icons.visibility_off;
    } else {
      if (curValue == true) {
        icon = CupertinoIcons.checkmark_alt_circle; //MyFlutterApp.check_box;
      } else {
        icon = CupertinoIcons.circle; //MyFlutterApp.check_box_outline;
      }
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.read<ModelTheme>().colorTheme;
    final IconData checkBox = getIcon();
    return InkWell(
      canRequestFocus: false,
      hoverColor: AppColors.jumbo.withOpacity(0.2),
      borderRadius: BorderRadius.circular(100),
      /*  onLongPress: widget.onChanged == null
          ? null
          : () {
              widget.onChanged!(null);
              setState(() {});
            }, */
      onTap: widget.onChanged == null
          ? null
          : () {
              if (widget.disabled == false) {
                curValue = !curValue!;
              }

              widget.onChanged!(curValue);
              setState(() {});
              if (!Platform.isMacOS) {
                Vibration.vibrate(duration: 1);
              }
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
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(
              checkBox,
              key: ValueKey(checkBox),
              color: curValue == true
                  ? colorTheme.primaryColor
                  : colorTheme.checkboxColor,
              size: isDesktop ? 20 : Theme.of(context).primaryIconTheme.size,
            ),
          )),
    );
  }
}
