import 'package:flutter/material.dart';
import 'package:klektion/utils/color_constants.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget data;
  ShimmerLoading({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 81, 82, 81),
      highlightColor: const Color.fromARGB(255, 184, 173, 27),
      enabled: true,
      child: data,
    );
  }
}
