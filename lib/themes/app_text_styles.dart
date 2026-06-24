import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Plus Jakarta Sans'; 

  // Display - Large bold headings for hero sections
  static const TextStyle display = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    letterSpacing: -2.0,
    height: 1.1,
    fontFamily: fontFamily,
  );

  // Heading - Primary section titles
  static const TextStyle heading = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.2,
    fontFamily: fontFamily,
  );

  // Subheading - Secondary headers
  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    fontFamily: fontFamily,
  );

  // BodyLarge - Primary body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.6,
    fontFamily: fontFamily,
  );

  // Body - Standard descriptive text
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    fontFamily: fontFamily,
  );

  // Label - Buttons and small UI elements
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    fontFamily: fontFamily,
    overflow: TextOverflow.ellipsis,
  );

  // Caption - Meta data and minor details
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    fontFamily: fontFamily,
  );
}
