
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/ItemMove.dart';
import '../controller/HttpController.dart';
import '../controller/functions.dart';
import '../models/ResponseStorageAPI.dart';
import 'Login.dart';

class ChangeServerPage extends StatefulWidget {
  const ChangeServerPage({Key? key}) : super(key: key);

  @override
  State<ChangeServerPage> createState() => _ChangeServerPageState();
}

class _ChangeServerPageState extends State<ChangeServerPage> {
  late ResponseStorageAPI responseStorageAPI;
  late List<ResponseStorageAPI> listListas;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late AndroidDeviceInfo androidInfo;
  String idAddress = "";
  HTTpController api_controller = HTTpController();

  //configurações da pagina
  late bool isLoading;

  @override
  void initState() {
    isLoading = true;
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
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
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          const Text(
                            "Listas Disponíveis:",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontFamily: "Candy",
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: listListas.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  padding: const EdgeInsets.all(15.5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        listListas[index].name!,
                                        style: const TextStyle(
                                          fontSize: 25,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      (listListas[index].active != 1)
                                          ? ItemMove(
                                              corBorda: Colors.red,
                                              isCategory: true,
                                              callback: () {
                                                _active(listListas[index].id);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  10.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    15.0,
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "Ativar",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Column(
                                              children: [
                                                Text(
                                                  "Ativo",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .backgroundColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(15.0),
              width: (MediaQuery.of(context).size.width * 40) / 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "ID:   ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Candy",
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          idAddress,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  ItemMove(
                    corBorda: Colors.red,
                    isCategory: true,
                    callback: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (Route<dynamic> route) => false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      height: 60.0,
                      child: const Center(
                        child: Text(
                          "Atualizar Listas",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initData() async {
    //buscando as listas salvas
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    if (isMobile()) {
      androidInfo = await deviceInfo.androidInfo;
      idAddress = androidInfo.id;
    } else {
      var deviceinfo = await deviceInfo.webBrowserInfo;
      var deviceCode = deviceinfo.data['productSub'];
      idAddress = deviceCode;
    }
    setState(() {
      listListas = listAPI;
      isLoading = false;
    });
  }

  void _active(id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });

    var response = await api_controller.activeList(id, idAddress);
    if (response) {
      //limpando a lista de EPG
      await prefs.remove("APIData");

      //reiniciando o aplicativo
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
