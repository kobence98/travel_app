import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

class CustomScrollPhysics extends AlwaysScrollableScrollPhysics {
  const CustomScrollPhysics();

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ?ancestor) {
    return CustomScrollPhysics();
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 80,
    stiffness: 200,
    damping: 1,
  );
}