import 'package:flutter/material.dart';

class FadeEffect extends StatelessWidget {
  final double width, height;
  const FadeEffect({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900,
              const Color.fromARGB(200, 33, 33, 33),
              const Color.fromARGB(165, 33, 33, 33),
              const Color.fromARGB(10, 33, 33, 33),
            ],
            stops: const [0.5, 0.6, 0.8, 1],
            tileMode: TileMode.clamp,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class hovercircle extends StatelessWidget {
  final Widget child;
  final double width;
  const hovercircle({super.key, required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black, offset: const Offset(3, 3), blurRadius: 5, spreadRadius: 1),
          BoxShadow(color: Colors.grey.shade800, offset: const Offset(-3, -3), blurRadius: 5, spreadRadius: 0.7),
        ],
      ),
      width: width,
      child: child,
    );
  }
}

class hoverbox extends StatelessWidget {
  final Widget child;
  final double width;
  const hoverbox({super.key, required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black, offset: const Offset(3, 3), blurRadius: 5, spreadRadius: 1),
          BoxShadow(color: Colors.grey.shade800, offset: const Offset(-3, -3), blurRadius: 5, spreadRadius: 0.7),
        ],
      ),
      width: width,
      child: child,
    );
  }
}
