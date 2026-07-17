Future<void> _showIncomingCallWindow(String name, String battery, String location) async {
  CallKitParams params = CallKitParams(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    nameCaller: name,
    appName: "تطبيق النداء الجماعي",
    handle: "نسبة شحن البطارية: $battery%",
    type: 0,
    extra: <String, dynamic>{'location_url': location},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#d32f2f',
      textColor: '#ffffff',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}
