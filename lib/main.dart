import 'package:cotree/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(DevicePreview(
    builder: (context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      builder: DevicePreview.appBuilder,
      home: HomeApp(),
    ),
  ));
}

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    return GetStorage().read("PlantsSaved") == null ? MyApp() : HomeApp();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int indexImgs = 0;

  Future<void> scan() async {
    await Permission.camera.request();
    String qrcode = await scanner.scan();
    if (qrcode == null)
      print("Niente");
    else if (qrcode == "Inizio")
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomeApp()));
    else
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                backgroundColor: Colors.red,
                content: Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 30,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Text(
                          "Assicurati di scannerizare il qr-code a inizio percorso",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (value) {
              setState(() => indexImgs = value);
            },
            children: [
              Image.asset(
                "assets/tutorialIMGS/1.png",
                fit: BoxFit.cover,
              ),
              Image.asset(
                "assets/tutorialIMGS/2.png",
                fit: BoxFit.cover,
              ),
              Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/tutorialIMGS/3.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                      child: Align(
                    alignment: Alignment(0, .8),
                    child: FlatButton(
                        onPressed: () => scan(),
                        color: Color.fromRGBO(0, 255, 150, .5),
                        child: Text(
                          "Inizia",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )),
                  ))
                ],
              ),
            ],
          ),
          Positioned.fill(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    indexImgs == 0
                        ? Icons.brightness_1
                        : Icons.brightness_1_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    indexImgs == 1
                        ? Icons.brightness_1
                        : Icons.brightness_1_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    indexImgs == 2
                        ? Icons.brightness_1
                        : Icons.brightness_1_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
