import 'package:camera/camera.dart';
import 'package:control/features/bloc/get_app_bloc/get_app_bloc.dart';
import 'package:control/features/bloc/lock_bloc/lock_bloc.dart';
import 'package:control/features/pages/camera_page.dart';
import 'package:control/features/pages/home_page.dart';
import 'package:control/features/service/show_app_service.dart';
 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Hive.initFlutter();
  await Hive.openBox('cacheBox');
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('lock_app_service');
  Widget screen = HomePage();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final String? data = await platform.invokeMethod<String?>("argument");
      debugPrint("Argument: $data");
      if (data != null) {
        screen = CameraPage(package: data);
      } else {
        screen = HomePage();
      }
      setState(() {});
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => GetAppBloc(showAppService: ShowAppService.instance),
        ),
        BlocProvider(create: (context) => LockBloc()),
        // BlocProvider(create: (context) => LockAppBloc()),
      ],

      child: MaterialApp(
        title: 'Control',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: screen,
      ),
    );
  }
}
