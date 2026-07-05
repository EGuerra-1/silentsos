import 'package:flutter/widgets.dart';

abstract final class ResponsiveUtils {
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;
}
