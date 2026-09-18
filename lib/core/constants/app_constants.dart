/// The three responsive layouts the dashboard adapts between.
enum DeviceType { mobile, tablet, desktop }

/// Layout, spacing and breakpoint constants shared across the dashboard.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static bool isMobile(double width) => width <= mobileMax;

  static bool isTablet(double width) => width > mobileMax && width <= tabletMax;

  static bool isDesktop(double width) => width > tabletMax;

  static DeviceType deviceTypeFor(double width) {
    if (isMobile(width)) return DeviceType.mobile;
    if (isTablet(width)) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}

class AppSpacing {
  AppSpacing._();

  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
