import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    // Request location permission
    final status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      // Permission granted → get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } else if (status == PermissionStatus.denied) {
      // Permission denied temporarily
      return null;
    } else if (status == PermissionStatus.permanentlyDenied) {
      // Permission denied permanently → ask to open settings
      await openAppSettings();
      return null;
    }

    return null;
  }
}
