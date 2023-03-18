import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/material.dart';
import 'package:apptv/components/ItemMenuEsquerdo.dart';

class MenuEsquerdo extends StatefulWidget {
  const MenuEsquerdo({Key? key}) : super(key: key);

  @override
  State<MenuEsquerdo> createState() => _MenuEsquerdoState();
}

class _MenuEsquerdoState extends State<MenuEsquerdo> {
  @override
  Widget build(BuildContext context) {
    double fullwidth = MediaQuery.of(context).size.width;
    double fullHeigth = MediaQuery.of(context).size.height;
    bool HomeIsFocused = false;


    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      width: (fullwidth * 10) / 100,
      height: fullHeigth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DpadContainer(
            onFocus: (bool isFocused) {

            },
            onClick: (){
              print("Clicou!");
            },
            child: ItemMenuEsquerdo(assets: '', name: 'Home', isFocused: HomeIsFocused),
          ),
        ],
      ),
    );
  }
}
