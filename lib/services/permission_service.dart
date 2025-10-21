import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._init();
  PermissionService._init();

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  Future<bool> requestAccessNotificationPolicyPermission() async {
    final status = await Permission.accessNotificationPolicy.request();
    return status.isGranted;
  }

  Future<bool> checkAllPermissions() async {
    final notification = await Permission.notification.isGranted;
    final scheduleAlarm = await Permission.scheduleExactAlarm.isGranted;
    return notification && scheduleAlarm;
  }

  Future<void> requestAllPermissions() async {
    await requestNotificationPermission();
    await requestScheduleExactAlarmPermission();
    await requestAccessNotificationPolicyPermission();
  }

  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
