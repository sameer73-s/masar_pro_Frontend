const kAnimationDuration = Duration(milliseconds: 200);
const kDefaultDuration = Duration(milliseconds: 250);
const kDefaultPadding = 16.0;
const kDefaultRadius = 12.0;
const kSpacing8 = 8.0;
const kSpacing12 = 12.0;
const kSpacing16 = 16.0;
const kSpacing20 = 20.0;
const kSpacing22 = 22.0;
const kSpacing24 = 24.0;
const kSpacing32 = 32.0;

/// Default API root (scheme + host + optional path). Auth calls append
/// [kMobileAttendanceApiPrefix] when this string does not already include it.
const String baseUrl = 'https://masar-pro-backend.onrender.com';

/// Fixed path segment after the host: `{host}/…/MobileAttendanceServiceCore/api/MobileAttendance/`.
const String kMobileAttendanceApiPrefix =
    'MobileAttendanceServiceCore/api/MobileAttendance/';
const sentinel = Object();
