import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/ItemMove.dart';
import '../models/SettingsData.dart';
import 'Login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool showEPG;
  late bool openFullScreen;
  late bool showRecentsWhatshing;
  late bool openOldPeople;
  late SettingsData settings;

  List<TypeLis> types = [
    TypeLis(tipo: "m3u8"),
    TypeLis(tipo: "ts"),
  ];
  late TypeLis typeList;

  @override
  void initState() {
    showEPG = false;
    openFullScreen = false;
    openOldPeople = false;
    showRecentsWhatshing = false;
    typeList = types[0];
    settings = SettingsData(
        openFullScreen: openFullScreen,
        openOldPeople: openOldPeople,
        showEPG: showEPG,
        showRecentsWhatshing: showRecentsWhatshing);
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Configurações"),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ItemMove(
                      callback: () async {
                        var box = await Hive.openBox("boxSaveEPG");
                        final prefs = await SharedPreferences.getInstance();
                        await box.deleteFromDisk();
                        await prefs.clear();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (Route<dynamic> route) => false);
                      },
                      isCategory: true,
                      corBorda: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Text(
                          "Limpar Todo os Dados",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const Text(
                "Selecione o tipo de lista:",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Candy",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _widgetRadioType(),
              const Text(
                "Selecione as configurações que deseja ativar:",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Candy",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Exibir programação antes de abrir o canal:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              ItemMove(
                isCategory: true,
                callback: () {
                  setState(() {
                    showEPG = !showEPG;
                  });
                  saveData();
                },
                corBorda: Colors.red,
                child: Switch(
                    value: showEPG,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        showEPG = value;
                      });
                      saveData();
                    }),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Abrir Canais em Tela Cheia por padrão:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              ItemMove(
                isCategory: true,
                callback: () {
                  setState(() {
                    openFullScreen = !openFullScreen;
                  });
                  saveData();
                },
                corBorda: Colors.red,
                child: Switch(
                  value: openFullScreen,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      openFullScreen = value;
                    });
                    saveData();
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Exibir canais assistidos recentimente:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              ItemMove(
                isCategory: true,
                callback: () {
                  setState(() {
                    showRecentsWhatshing = !showRecentsWhatshing;
                  });
                  saveData();
                },
                corBorda: Colors.red,
                child: Switch(
                  value: showRecentsWhatshing,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      showRecentsWhatshing = value;
                    });
                    saveData();
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Exibir canais resumidamente:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              ItemMove(
                isCategory: true,
                callback: () {
                  setState(() {
                    openOldPeople = !openOldPeople;
                  });
                  saveData();
                },
                corBorda: Colors.red,
                child: Switch(
                  value: openOldPeople,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      openOldPeople = value;
                    });
                    saveData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    SettingsData data = SettingsData(
        openFullScreen: openFullScreen,
        openOldPeople: openOldPeople,
        showEPG: showEPG,
        showRecentsWhatshing: showRecentsWhatshing,
        typelist: typeList.tipo);
    var convert = data.toJson();
    await prefs.setString("settings", jsonEncode(convert).toString());
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (Route<dynamic> route) => false);
  }

  void initData() async {
    final prefs = await SharedPreferences.getInstance();
    var response = prefs.getString("settings");
    if (response != null) {
      var dados = jsonDecode(response);
      SettingsData data = SettingsData.fromJson(dados);
      print("${data.showEPG}");
      //verificando o tipo
      types.forEach((element) {
        if (element.tipo == data.typelist) {
          typeList = element;
        }
      });
      setState(() {
        settings = data;
        showRecentsWhatshing = data.showRecentsWhatshing!;
        showEPG = data.showEPG!;
        openOldPeople = data.openOldPeople!;
        openFullScreen = data.openFullScreen!;
        typeList = typeList;
      });
    } else {
      var convert = settings.toJson();
      await prefs.setString("settings", jsonEncode(convert).toString());
    }
  }

  _widgetRadioType() {
    return Column(
      children: [
        ItemMove(
          isCategory: true,
          callback: () {
            setState(() {
              typeList = types[0];
            });
          },
          corBorda: Colors.red,
          child: ListTile(
            selectedColor: Colors.red,
            textColor: Colors.white,
            title: const Text('M3U8'),
            leading: Radio<TypeLis>(
              value: types[0],
              groupValue: typeList,
              onChanged: (TypeLis? value) {
                setState(() {
                  typeList = value!;
                });
                saveData();
              },
            ),
          ),
        ),
        ItemMove(
          isCategory: true,
          callback: () {
            setState(() {
              typeList = types[1];
            });
          },
          corBorda: Colors.red,
          child: ListTile(
            selectedColor: Colors.red,
            textColor: Colors.white,
            title: const Text('TS'),
            leading: Radio<TypeLis>(
              value: types[1],
              groupValue: typeList,
              onChanged: (TypeLis? value) {
                setState(() {
                  typeList = value!;
                });
                saveData();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TypeLis {
  String? tipo;

  TypeLis({required this.tipo});
}
