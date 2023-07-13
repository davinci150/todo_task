import 'dart:math' as math;

import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  const ProgressIndicatorWidget({
    Key? key,
    required this.size,
    required this.color,
  }) : super(key: key);
  final double size;
  final Color color;

  @override
  _BuildSpinnerState createState() => _BuildSpinnerState();
}

class _BuildSpinnerState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 3 * math.pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceIn
          /*   curve: const Interval(
          0.3,
          1.0,
        ), */
          ),
    );
  }

  Widget _buildInitialDot(double angle, Interval interval) => BuildDot.first(
        size: widget.size,
        color: widget.color,
        angle: angle,
        controller: _animationController,
        interval: interval,
      );

  Widget _buildLaterDot(double angle, Interval interval) => BuildDot.second(
        size: widget.size,
        color: widget.color,
        angle: angle,
        controller: _animationController,
        interval: interval,
      );

  @override
  Widget build(BuildContext context) {
    const double angle30 = math.pi / 6;
    const double angle60 = math.pi / 3;
    const double angle120 = 2 * math.pi / 3;
    const double angle180 = math.pi;
    const double angle240 = 4 * math.pi / 3;
    const double angle300 = 5 * math.pi / 3;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: _animationController.value <= 0.28
            ? Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _buildInitialDot(0 + angle30, const Interval(0, 0.08)),
                  _buildInitialDot(
                      angle60 + angle30, const Interval(0.04, 0.12)),
                  _buildInitialDot(
                      angle120 + angle30, const Interval(0.08, 0.16)),
                  _buildInitialDot(
                      angle180 + angle30, const Interval(0.12, 0.20)),
                  _buildInitialDot(
                      angle240 + angle30, const Interval(0.16, 0.24)),
                  _buildInitialDot(
                      angle300 + angle30, const Interval(0.20, 0.28)),
                ],
              )
            : Transform.rotate(
                angle: _rotationAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    _buildLaterDot(
                      0 + angle30,
                      const Interval(
                        0.80,
                        0.88,
                      ),
                    ),
                    _buildLaterDot(
                      angle60 + angle30,
                      const Interval(
                        0.76,
                        0.84,
                      ),
                    ),
                    _buildLaterDot(
                      angle120 + angle30,
                      const Interval(
                        0.72,
                        0.80,
                      ),
                    ),
                    _buildLaterDot(
                      angle180 + angle30,
                      const Interval(
                        0.68,
                        0.76,
                      ),
                    ),
                    _buildLaterDot(
                      angle240 + angle30,
                      const Interval(
                        0.64,
                        0.72,
                      ),
                    ),
                    _buildLaterDot(
                      angle300 + angle30,
                      const Interval(
                        0.60,
                        0.68,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class BuildDot extends StatelessWidget {
  const BuildDot.second({
    Key? key,
    required this.color,
    required this.angle,
    required this.size,
    required this.interval,
    required this.controller,
  })  : first = false,
        super(key: key);
  const BuildDot.first({
    Key? key,
    required this.color,
    required this.angle,
    required this.size,
    required this.interval,
    required this.controller,
  })  : first = true,
        super(key: key);
  final Color color;
  final double angle;
  final double size;
  final Interval interval;
  final AnimationController controller;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Transform.translate(
        offset: Offset(0, -size / 2.4),
        child: UnconstrainedBox(
          child: DrawDot.circular(
            color: color,
            dotSize: size / 6,
            /*   first
                ? Tween<double>(
                    begin: 0.0,
                    end: size / 6,
                  )
                    .animate(
                      CurvedAnimation(
                        parent: controller,
                        curve: interval,
                      ),
                    )
                    .value
                : Tween<double>(
                    begin: size / 6,
                    end: 0.0,
                  )
                    .animate(
                      CurvedAnimation(
                        parent: controller,
                        curve: interval,
                      ),
                    )
                    .value, */
          ),
        ),
      ),
    );
  }
}

class DrawDot extends StatelessWidget {
  const DrawDot.elliptical({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
  })  : circular = false,
        super(key: key);

  const DrawDot.circular({
    Key? key,
    required double dotSize,
    required this.color,
  })  : width = dotSize,
        height = dotSize,
        circular = true,
        super(key: key);
  final double width;
  final double height;
  final bool circular;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        //border: Border.all(color: color,width: width*0.1),
        color: color,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular
            ? null
            : BorderRadius.all(Radius.elliptical(width, height)),
      ),
    );
  }
}
