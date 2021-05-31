import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DataX extends GetxController {
  var plantsSaved = [].obs;
  var plants = [].obs;

  void addPlants(String name) {
    plants.add(name);
    GetStorage().write("PlantsSaved", plants);
    update();
  }

  void init() {
    // Save in local the plants
    for (var item in GetStorage().read("PlantsSaved")) plants.add(item);
    for (var item in GetStorage().read("BestPlants")) plantsSaved.add(item);
  }

  void savePlants(String name) {
    plantsSaved.add(name);
    GetStorage().write("BestPlants", plantsSaved);
    update();
  }
}
