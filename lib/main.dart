import 'package:family_management_app/app/routes/app_router.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/service/multi_bloc_widget.dart';
import 'package:family_management_app/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await _initServices();
  runApp(MultiBlocWidget(child: MyApp()));
}

Future<void> _initServices() async {
  try {
    await NotificationService.initFCM();
  } catch (e) {
    debugPrint("❌ Error initializing Firebase/FCM: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844),
      splitScreenMode: true,
      minTextAdapt: true,
      ensureScreenSize: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter().generateRoutes,
          initialRoute: AppRoutes.splashScreen,
        );
      },
    );
  }
}
