import 'dart:math';
import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/pages/ChangeServerPage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ExpirePage extends StatelessWidget {
  const ExpirePage({Key? key}) : super(key: key);

  static const List<String> map = [
    "lib/assets/error1.json",
    "lib/assets/error2.json",
    "lib/assets/error3.json",
    "lib/assets/error4.json",
    "lib/assets/error5.json",
    "lib/assets/error6.json",
    "lib/assets/error7.json",
    "lib/assets/error8.json"
  ];

  String randomLottie(){
    String retorno = "";
    var rng = Random();
    var index = rng.nextInt(map.length);
    retorno = map[index];
    return retorno;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15.0),
        color: Theme.of(context).backgroundColor,
        child: Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width * 48) / 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Center(
                child: Lottie.asset(
                  randomLottie(),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
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
                    "Sua lista está com problemas!",
                    style: TextStyle(
                      fontFamily: "Candy",
                      color: Colors.white,
                      fontSize: 40,
                    ),
                     textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    "Verifique suas listas clicando abaixo:",
                    style: TextStyle(
                      fontFamily: "Candy",
                      color: Colors.red,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
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
                            builder: (context) => const ChangeServerPage(),
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
                          "Minhas Listas",
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
}
