import 'dart:convert';
import 'package:flutter_application_1/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Local constants for this project (Using existing assets)
const String pngCourseDefault = 'assets/imgs/bg1.jpg';
const String pngDefaultAvatar = 'assets/imgs/bg1.jpg'; 

Widget imageFromNetwork(dynamic base64Data, double? width, double? height,
    {String type = "banner", BoxFit fit = BoxFit.cover}) {
  try {
    if (base64Data == null || base64Data.toString().isEmpty) {
      return Image.asset(pngCourseDefault, width: width, height: height, fit: fit);
    }

    bool isSvg = base64Data.toString().contains("svg");
    if (isSvg) {
      String data =
          base64Data.toString().replaceAll("data:image/svg+xml;base64,", "");
      // Remove whitespace if any
      data = data.replaceAll(RegExp(r'\s+'), '');
      
      var decoded = base64.decode(data);
      String svgStr = utf8.decode(decoded);
      svgStr = svgStr.replaceAll('width="100%"', "");
      svgStr = svgStr.replaceAll('height="100%"', "");
      
      if (svgStr.contains("rotate(")) {
        return Image.asset(
          pngCourseDefault,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      }
      return SvgPicture.string(
        svgStr,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      String strData = base64Data.toString();
      if (strData.contains("https://") || strData.contains("http://")) {
        return Image.network(strData,
            width: width,
            height: height,
            fit: fit, errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            type == "avatar" ? pngDefaultAvatar : pngCourseDefault,
            width: width,
            height: height,
            fit: type == "avatar" ? BoxFit.cover : fit,
          );
        });
      } else if (strData.contains("data:image")) {
        // Handle regular base64 images (non-svg)
        final parts = strData.split(',');
        if (parts.length >= 2) {
          final bytes = base64Decode(parts[1].replaceAll(RegExp(r'\s+'), ''));
          return Image.memory(bytes, width: width, height: height, fit: fit, 
            errorBuilder: (context, error, stackTrace) => 
              Image.asset(pngCourseDefault, width: width, height: height, fit: fit));
        }
      }
    }
  } catch (e) {
    logger("Error in imageFromNetwork: $e");
  }
  
  if (type == "banner") {
    return Image.asset(pngCourseDefault,
        width: width, height: height, fit: fit);
  }
  return Container();
}
