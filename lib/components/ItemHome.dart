import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../pages/ChangeServerPage.dart';
class ItemHome extends StatefulWidget {
  const ItemHome({Key? key, required this.fullwidth, required this.fullHeigth, required this.route, required this.imgprincipal, required this.imgsecundaria}) : super(key: key);
  final double fullwidth;
  final double fullHeigth;
  final MaterialPageRoute route;
  final String imgprincipal;
  final String imgsecundaria;

  @override
  State<ItemHome> createState() => _ItemHomeState();
}

class _ItemHomeState extends State<ItemHome> {
  bool hasChange = false;
  bool isClicked = false;
  Color corPrimaria = HexColor("#201d2e");
  Color corSecundaria = HexColor("#262432");
  late double fullwidth;
  late double fullHeigth;
  @override
  Widget build(BuildContext context) {
    return DpadContainer(
      onClick: () {
        setState(() {
          isClicked = !isClicked;
        });
        Navigator.push(
          context,
          widget.route,
        );
      },
      onFocus: (focus) {
        setState(() {
          hasChange = focus;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: corSecundaria,
            border: Border.all(
              color: hasChange
                  ? Colors.white
                  : isClicked
                  ? Colors.blue.shade400
                  : Colors.black,
              width: 5,
            ),
          ),
          width: (widget.fullwidth * 25) / 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.imgprincipal,
                width: 50,
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Image.asset(
                widget.imgsecundaria,
                width: 90,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
