import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privch/home.dart';
import 'package:privch/data/preference.dart';
import 'package:privch/data/shadowsocks.dart';
import 'package:privch/platform/platform_event.dart';
import 'package:privch/platform/xin_method.dart';

/// 2021-03
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ssManager.load();
  await loadPreference();

  runApp(Privch());
}

/// Root widget
class Privch extends StatefulWidget {
  @override
  _PrivchState createState() => _PrivchState();
}

class _PrivchState extends State<Privch> with WidgetsBindingObserver {
  final String _title = "PrivCh";

  final ThemeData _themeDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xff121212),
    secondaryHeaderColor: Color(0xff202020),
    backgroundColor: Color(0xff121212),
    scaffoldBackgroundColor: Color(0xff121212),
    dialogBackgroundColor: Color(0xff121212),
    accentColor: Colors.lime,
    toggleableActiveColor: Colors.lime,
    selectedRowColor: Colors.lime,
    focusColor: Colors.orange,
    errorColor: Colors.orange,

    textTheme: TextTheme(
      subtitle2: TextStyle(color: Colors.grey),
      caption: TextStyle(color: Colors.blueGrey.shade300),
    ),

    accentTextTheme: TextTheme(
      caption: TextStyle(color: Colors.lightGreen),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
      ),
    ),

    // This makes the visual density adapt to the platform that you run
    // the app on. For desktop platforms, the controls will be smaller and
    // closer together (more dense) than on mobile platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  final ThemeData _themeLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal,
    secondaryHeaderColor: Color(0xffe7e7e7),
    backgroundColor: Color(0xfff7f7f7),
    scaffoldBackgroundColor: Color(0xfff7f7f7),
    dialogBackgroundColor: Color(0xfff7f7f7),
    accentColor: Colors.teal,
    toggleableActiveColor: Colors.teal,
    selectedRowColor: Colors.teal,
    focusColor: Colors.deepOrange,
    errorColor: Colors.deepOrange,

    textTheme: TextTheme(
      subtitle2: TextStyle(color: Colors.grey),
      caption: TextStyle(color: Colors.blueGrey),
    ),

    accentTextTheme: TextTheme(
      caption: TextStyle(color: Colors.teal),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.teal),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.teal),
      ),
    ),

    // This makes the visual density adapt to the platform that you run
    // the app on. For desktop platforms, the controls will be smaller and
    // closer together (more dense) than on mobile platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  /// handle night mode change by user when theme mode is ThemeMode.system
  void _setNavigationBar() {
    if (dataEvent.isNightMode.value) {
      xinMethod.setNavigationBar(_themeDark.cardColor.value, animate: 300);
    } else {
      xinMethod.setNavigationBar(_themeLight.cardColor.value, animate: 300);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: preference.themeSetting,
      builder: (buildContext, value, child) {
        final ThemeMode themeMode = preference.themeMode;
        if (themeMode == ThemeMode.system) {
          // theme mode is system, check night mode via native api
          xinMethod.getNightMode().then((night) {
            dataEvent.isNightMode.value = night;
            dataEvent.isNightMode.addListener(_setNavigationBar);
            if (night) {
              xinMethod.setNavigationBar(_themeDark.cardColor.value, animate: 300);
            } else {
              xinMethod.setNavigationBar(_themeLight.cardColor.value, animate: 300);
            }
          });
        } else {
          // theme mode is light or dark
          dataEvent.isNightMode.removeListener(_setNavigationBar);
          if (themeMode == ThemeMode.dark) {
            xinMethod.setNavigationBar(_themeDark.cardColor.value, animate: 300);
          } else {
            xinMethod.setNavigationBar(_themeLight.cardColor.value, animate: 300);
          }
        }

        return MaterialApp(
          title: _title,
          theme: _themeLight,
          darkTheme: _themeDark,
          themeMode: themeMode,
          home: HomePage(_title),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /* Save data and preference when app is inactive, 
     * such as been paused to the background or going to exit.
     * 
     * FIXME. It was caused that app exited before the saving is finished
     */
    if (state == AppLifecycleState.inactive) {
      // save ss data
      ssManager.save();
      // save preference
      savePreference();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    dataEvent.start();
  }

  @override
  void dispose() {
    dataEvent.isNightMode.removeListener(_setNavigationBar);
    dataEvent.stop();

    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
