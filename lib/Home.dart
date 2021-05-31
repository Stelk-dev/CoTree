import 'package:cotree/getStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:confetti/confetti.dart';

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  int index = 0; // Index of pages
  List plantsDetail = [
    ["Betulla", 10],
    ["Caladium", 5],
    ["Balloon Flower", 8],
    ["Fern-leaf Yarrow", 12],
    ["Fortune's Hosta", 12],
    ["Eulalia Grass", 1],
    ["Garden Impatiens", 19],
    ["Globe Amaranth", 19],
    ["Gooseneck Loosestrife", 20],
  ]; // Details of plants in list

  ConfettiController _controllerCenter =
      ConfettiController(duration: const Duration(seconds: 1));
  final controller = Get.put(DataX());

  // Function scan
  Future _scan() async {
    await Permission.camera.request();
    String qrcode = await scanner.scan();
    if (qrcode == null) {
      print('Niente');
    } else {
      if (qrcode.length < 6 || qrcode.substring(0, 5) != "Plant")
        return showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  content: Container(
                    height: 300,
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Image.asset(
                              "assets/IDK.png",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          color: Colors.redAccent,
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
                                  "Questo QR-Code non è corretto riprova...",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
      if (!controller.plants.contains(qrcode)) {
        _controllerCenter.play();
        controller.addPlants(qrcode);
        return showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  titlePadding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                  title: Container(
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Congratulazioni hai sbloccato una nuova pianta",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  content: Container(
                      width: 160,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          "assets/plants/$qrcode.png",
                          fit: BoxFit.contain,
                        ),
                      )),
                  actions: [
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Scarta",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.redAccent,
                    ),
                    FlatButton(
                      onPressed: () {
                        controller.savePlants(qrcode);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Salva",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.lightBlue,
                    )
                  ],
                ));
      }
    }
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Widget home() {
    return Stack(
      children: [
        CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 200.0,
              backgroundColor: Color.fromRGBO(4, 179, 132, 1),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.fromLTRB(15, 0, 0, 10),
                title: Text(
                  "CoTree",
                  style: TextStyle(fontSize: 25),
                ),
                background: Container(
                  child: Image.asset(
                    "assets/treeMountain.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              for (int i = 0; i <= 7; i++)
                plantStyle("assets/plants/Plant$i.png", "${plantsDetail[i][0]}",
                    "Plant$i", plantsDetail[i][1])
            ]))
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirection: 1,
              emissionFrequency: .5,
              numberOfParticles: 1,
              maxBlastForce: 40,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirection: 2,
              emissionFrequency: .5,
              numberOfParticles: 1,
              maxBlastForce: 40,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget plantsSaved() {
    return GetBuilder<DataX>(
        builder: (builder) => Scaffold(
            backgroundColor: Color.fromRGBO(19, 88, 41, 1),
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(4, 179, 132, 1),
              title: Text(
                "CoTree",
                style: TextStyle(fontSize: 25),
              ),
            ),
            body: controller.plantsSaved.length > 0
                ? ListView.builder(
                    itemCount: controller.plantsSaved.length,
                    itemBuilder: (_, i) => plantStyle(
                        "assets/plants/Plant$i.png",
                        "${plantsDetail[i][0]}",
                        "Plant$i",
                        plantsDetail[i][1]))
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 130,
                            height: 130,
                            child: Image.asset("assets/tree-broken.png")),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Non hai ancora salvato nessuna pianta",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  )));
  }

  Widget plantStyle(
    String urlImage,
    String name,
    String namePlant,
    int co2,
  ) {
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
        child: controller.plants.contains(namePlant)
            ? Card(
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                          child: Container(
                              width: 160,
                              height: 200,
                              child: Image.asset(
                                urlImage,
                                fit: BoxFit.cover,
                              )),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "Nome: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: "$name",
                              )
                            ], style: TextStyle(color: Colors.black))),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "Co^2: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: "${co2.toString()}",
                              )
                            ], style: TextStyle(color: Colors.black)))
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              )
            : Card(
                color: Colors.grey,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 200,
                        child: Image.asset(
                          urlImage.replaceAll("/plants", "/plantsHide"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            "Non hai ancora sbloccato questa pianta",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (GetStorage().read("PlantsSaved") == null) // save local
    {
      GetStorage().write("PlantsSaved", []);
      GetStorage().write("BestPlants", []);
    }

    controller.init();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return GetBuilder<DataX>(
      builder: (_) => Scaffold(
        backgroundColor: Color.fromRGBO(19, 88, 41, 1),
        body: index == 0 ? home() : plantsSaved(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _scan(),
          backgroundColor: Colors.green,
          child: Icon(Icons.qr_code_scanner_rounded),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          unselectedItemColor: Colors.black38,
          selectedItemColor: Colors.white,
          backgroundColor: Color.fromRGBO(4, 179, 132, 1),
          onTap: (value) {
            setState(() => index = value);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark), title: Text("Piante salvate"))
          ],
        ),
      ),
    );
  }
}
