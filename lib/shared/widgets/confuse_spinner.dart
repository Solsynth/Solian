import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ConfuseSpinnerDirection { normal, reverse }

enum ConfuseSpinnerPlayState { running, paused }

class ConfuseSpinner extends StatefulWidget {
  const ConfuseSpinner({
    super.key,
    this.size = 40,
    this.speed = 5,
    this.color,
    this.text = 'o.0 0.o',
    this.fontSize = 20,
    this.fontFamily,
    this.fontWeight = FontWeight.w400,
    this.letterSpacing = 1.6,
    this.animationDirection = ConfuseSpinnerDirection.normal,
    this.animationPlayState = ConfuseSpinnerPlayState.running,
    this.child,
  });

  final double size;
  final double speed;
  final Color? color;
  final String text;
  final double fontSize;
  final String? fontFamily;
  final FontWeight fontWeight;
  final double letterSpacing;
  final ConfuseSpinnerDirection animationDirection;
  final ConfuseSpinnerPlayState animationPlayState;
  final Widget? child;

  @override
  State<ConfuseSpinner> createState() => _ConfuseSpinnerState();
}

class _ConfuseSpinnerState extends State<ConfuseSpinner> {
  late List<String> _patterns;
  int _currentIndex = 0;
  int _displayVersion = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _patterns = _parsePatterns(widget.text);
    _startOrStopTimer();
  }

  @override
  void didUpdateWidget(covariant ConfuseSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      _patterns = _parsePatterns(widget.text);
      _currentIndex = 0;
      _displayVersion++;
    }

    if (oldWidget.speed != widget.speed ||
        oldWidget.animationPlayState != widget.animationPlayState ||
        oldWidget.animationDirection != widget.animationDirection ||
        oldWidget.text != widget.text) {
      _startOrStopTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startOrStopTimer() {
    _timer?.cancel();

    if (_patterns.length <= 1 ||
        widget.animationPlayState == ConfuseSpinnerPlayState.paused) {
      return;
    }

    final intervalMs = math.max(50, (1000 / widget.speed).round());
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!mounted || _patterns.isEmpty) {
        return;
      }

      setState(() {
        if (widget.animationDirection == ConfuseSpinnerDirection.reverse) {
          _currentIndex =
              (_currentIndex - 1 + _patterns.length) % _patterns.length;
        } else {
          _currentIndex = (_currentIndex + 1) % _patterns.length;
        }
        _displayVersion++;
      });
    });
  }

  List<String> _parsePatterns(String value) {
    final parsed = value
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    return parsed.isEmpty ? <String>['o.0'] : parsed;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Confuse Spinner',
      image: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child:
              widget.child ??
              Text(
                _patterns[_currentIndex],
                key: ValueKey<int>(_displayVersion),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: widget.color,
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  fontWeight: widget.fontWeight,
                  letterSpacing: widget.letterSpacing,
                ),
              ),
        ),
      ),
    );
  }
}
