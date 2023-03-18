import 'package:get/get.dart';

import '../models/ResponseStorageAPI.dart';

class HomeController extends GetxController{
  late double fullwidth;
  late double fullHeigth;
  late bool isLoading = true.obs as bool;
  late bool isDownloading;
  late ResponseStorageAPI responseStorageAPI;
  late String hour = "";
}