import 'dart:io';
import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseListAPI.dart';
import 'package:apptv/pages/Home.dart';
import 'package:apptv/pages/SplashScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lottie/lottie.dart';
import '../controller/HttpController.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String idAddress = "";
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late AndroidDeviceInfo androidInfo;
  HTTpController api_controller = HTTpController();
  late List<ResponseListAPI> listasAPI;
  late bool isLoading;

  @override
  void initState() {
    isLoading = true;
    iniData(context);
    super.initState();
  }

  void iniData(context) async {
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
      androidInfo = await deviceInfo.androidInfo;
      idAddress = androidInfo.id;
      print("$idAddress");
      //buscando os dados da API
      List<ResponseListAPI>? l = await api_controller.getListsFromAPI(idAddress, "Android");
      if (l!.length > 0) {
        //limpando a lista
        if (await saveDataAPI(l)) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false);
        }
      } else {
        //não tem listas, mostra a página de login
        setState(() {
          isLoading = false;
        });
      }
    }
    else if (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows) {
      // Some desktop specific code there
      var deviceinfo = await deviceInfo.webBrowserInfo;
      var deviceCode = deviceinfo.data['productSub'];
      idAddress = deviceCode;
      List<ResponseListAPI>? l = await api_controller.getListsFromAPI(deviceCode, "Web");
      if (l!.length > 0) {
        //limpando a lista
        if (await saveDataAPI(l)) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false);
        }
      } else {
        //não tem listas, mostra a página de login
        setState(() {
          isLoading = false;
        });
      }
    }
    else {
      //web
    }
  }

  Future<void> _launchUrl() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
            (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width * 48) / 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Center(
                      child: Lottie.asset(
                        'lib/assets/lottie.json',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    width: (MediaQuery.of(context).size.width * 40) / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Center(
                      child: ListView(
                        children: [
                          const Text(
                            "Adicione novas listas no link abaixo:",
                            style: TextStyle(
                              fontFamily: "Candy",
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          const Text(
                            "vectorplayer.com",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Candy",
                              color: Colors.red,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Row(
                              children: [
                                const Text(
                                  "ID:   ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Candy",
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  idAddress,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: "Candy",
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          ItemMove(
                            corBorda: Colors.white,
                            isCategory: false,
                            callback: _launchUrl,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              width: 200.0,
                              height: 40.0,
                              child: const Center(
                                child: Text(
                                  "Atualizar",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
