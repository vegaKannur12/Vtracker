import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location2/CONTROLLER/printClass.dart';
import 'package:location2/homepage.dart';
import 'package:location2/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() { 
  // GeocodingPlatform.instance;
  WidgetsFlutterBinding.ensureInitialized();  
  initializeService();
  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PrintController()),
      // ChangeNotifierProvider(create: (_) => RegistrationController()),
    ],
    child: const MyApp(),
  ));
}

Future<void> initializeService() async 
{
  final service = FlutterBackgroundService();
  // service.invoke("stopService");
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,
      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,
      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);
  return true;
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  },
  );

  // bring to foreground
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        print("helloo");
        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );
      }
    }
    // you can see this log in logcat
    determinePosition();
    print('FLUTTER BACKGROUND LOC: ${DateTime.now()}');

    // test using external plugin
    // final deviceInfo = DeviceInfoPlugin();
    // String? device;
    // if (Platform.isAndroid) {
    //   final androidInfo = await deviceInfo.androidInfo;
    //   device = androidInfo.model;
    // }

    // if (Platform.isIOS) {
    //   final iosInfo = await deviceInfo.iosInfo;
    //   device = iosInfo.model;
    // }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        // "device": device,
      },
    );
  });
}
 Future determinePosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fp = prefs.getString("fp");
    String? uid = prefs.getString("st_uname");
    bool serviceEnabled;
    LocationPermission permission;
  String currentAddress = 'Address    : ';
  late Position currentposition;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

     
        DateTime now = DateTime.now();
        String datetoday = DateFormat('dd-MM-yyyy').format(DateTime.now());
        currentposition = position;
        print("Street :${place.street}");
        print("Locality :${place.locality}");
        print("PostalCode :${place.postalCode}");
        print("AdministrativeArea :${place.administrativeArea}");
        print("Country :${place.country}");
        print("HashCode :${place.hashCode}");
        print("ISOCountryCode :${place.isoCountryCode}");
        print("Name :${place.name}");
        print("SubAdministrativeArea :${place.subAdministrativeArea}");
        print("SubLocality :${place.subLocality}");
        print("SubThoroughfare :${place.subThoroughfare}");
        print("Thoroughfare :${place.thoroughfare}");

        currentAddress =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.administrativeArea}, ${place.country}";
       location(
            currentAddress.toString(),
            "$now",
            datetoday,
            "${place.street}",
            "${place.locality}",
            "${place.postalCode}",
            "${place.administrativeArea}",
            "${place.country}",
            "${place.hashCode}",
            "${place.isoCountryCode}",
            "${place.name}",
            "${place.subAdministrativeArea}",
            "${place.subLocality}",
            "${position.latitude}",
            "${position.longitude}",
            "0");
    
    } catch (e) {
      print(e);
    }
  }
   location(String place, String datetime, String datetoday,String street,String local,String post,String adminarea,String cntry,String hash,
  String isocode,String name,String subadmin,String sublocal,String lati,String longi,String activity
      ) async {
    // NetConnection.networkConnection(context).then((value) async {
    //   if (value == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fp = prefs.getString("fp");
    String? uid = prefs.getString("st_uname");
    print("fp : $fp ......... uname: $uid");

    try {
      Uri url = Uri.parse("https://trafiqerp.in/rapi/save_loct.php");
      Map body = {
        'location_info': place,
        'user_id': uid,
        'device_info': fp,
        'l_date': datetime,
        'Street':street,
        'Locality':local,
        'PostalCode':post,
        'AdministrativeArea':adminarea,
        'Country':cntry,
        'HashCode':hash,
        'ISOCountryCode':isocode,
        'Name':name,
        'SubAdministrativeArea':subadmin,
        'SubLocality':sublocal,
        'latitude':lati,
        'longitude':longi,
        'activity':activity,
        
      };
      // ignore: avoid_print
      print("loc body----$body");
     
      http.Response response = await http.post(
        url,
        body: body,
      );
      // print("body $body");
      var map = jsonDecode(response.body);
      // ignore: avoid_print
      print("location map----$map");
     
      
    } 
    catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
