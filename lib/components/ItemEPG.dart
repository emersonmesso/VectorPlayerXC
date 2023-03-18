import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemEPG extends StatelessWidget {
  const ItemEPG(
      {Key? key,
      required this.title,
      required this.startTime,
      required this.stopTime,
      required this.index,
      this.desc})
      : super(key: key);
  final String title;
  final String startTime;
  final String stopTime;
  final int index;
  final String? desc;

  String? getAgora() {
    String response = "";
    if (index == 0) {
      //agora
      response =
          "${response}Agora / ${DateFormat('HH:mm').format(convertTime(startTime))} - ${DateFormat('HH:mm').format(convertTime(stopTime))}";
    } else {
      var dateInitial = convertTime(startTime);
      var now = DateTime.now();
      var today = DateTime(now.year, now.month, now.day);
      var yesterday = DateTime(now.year, now.month, now.day + 1);
      if ((dateInitial.day == now.day) && (dateInitial.month == now.month)) {
        response =
            "${response}Hoje / ${DateFormat('HH:mm').format(convertTime(startTime))} - ${DateFormat('HH:mm').format(convertTime(stopTime))}";
      } else if (dateInitial == yesterday) {
        response =
            "${response}Amanhã / ${DateFormat('HH:mm').format(convertTime(startTime))} - ${DateFormat('HH:mm').format(convertTime(stopTime))}";
      } else {
        response =
            "$response${DateFormat('dd/MM').format(convertTime(startTime))} / ${DateFormat('HH:mm').format(convertTime(startTime))} - ${DateFormat('HH:mm').format(convertTime(stopTime))}";
      }
    }
    return response;
  }

  DateTime convertTime(String myString) {
    var step1 = myString.split(" ");
    var ano = step1[0].substring(0, 4);
    var mes = step1[0].substring(4, 6);
    var dia = step1[0].substring(6, 8);
    var hora = step1[0].substring(8, 10);
    var min = step1[0].substring(10, 12);
    var seg = step1[0].substring(12, 14);
    int h = int.parse(hora);

    var str = "";
    if (h < 10 && h > 0) {
      h = h - 1;
      str = "0$h";
    } else if (h == 0) {
      str = "0$h";
    } else if (h == 10) {
      h = h - 1;
      str = "0$h";
    } else {
      h = h - 1;
      str = h.toString();
    }
    var time = "$ano-$mes-$dia ${str.toString()}:$min:$seg";
    DateTime data = DateTime.parse(time);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        border: Border.all(
          width: 1,
          color: Theme.of(context).backgroundColor,
        ),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: "Candy",
              color: Colors.white,
            ),
          ),
          Text(
            "${getAgora()}",
            style: const TextStyle(
              fontFamily: "Candy",
              color: Colors.red,
              fontSize: 14,
            ),
          ),
          (desc != null)
              ? Text(
                  desc!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: "Candy",
                    fontStyle: FontStyle.normal,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
