import 'package:apptv/pages/m3u8/channels/VideoPlayerPage.dart';
import 'package:flutter/material.dart';
import '../../../components/ItemMove.dart';
import '../../../controller/functions.dart';
import '../../../models/ListM3U8/ResponseListM3U8Channel.dart';
import '../../../models/ResponseChannelEPG.dart';
import '../../../models/ResponseStorageAPI.dart';
import '../../../models/SettingsData.dart';

class ItemChannelM3U8 extends StatefulWidget {
  const ItemChannelM3U8({Key? key, required this.channel}) : super(key: key);
  final ListChannels channel;

  @override
  State<ItemChannelM3U8> createState() => _ItemChannelM3U8State();
}

class _ItemChannelM3U8State extends State<ItemChannelM3U8> {
  late List<ResponseChannelEPG> listaEPG = <ResponseChannelEPG>[];
  late ResponseStorageAPI responseStorageAPI;
  late SettingsData settings;

  @override
  void initState() {
    getEPG();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ItemMove(
      corBorda: Colors.white,
      isCategory: true,
      callback: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPageM3U8(channel: widget.channel),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  widget.channel.logo!,
                  fit: BoxFit.contain,
                  width: 40,
                  height: 40,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      "lib/assets/logo.png",
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    );
                  },
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.channel.title!,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _getTitleEPG()!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _getTitleEPG() {
    if (listaEPG.isNotEmpty) {
      String? response = listaEPG[0].title;
      return response;
    }
    return "";
  }

  void getEPG() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    SettingsData? set = await getSeetings();
    if (set?.showEPG! == true) {
      //convertendo o nome do canal para epgID
      var name = widget.channel.title!.replaceAll(" ", "").toLowerCase();
      name = name.replaceAll("hd", "");
      name = name.replaceAll("sd", "");
      name = name.replaceAll("fhd", "");
      name = name.replaceAll("4k", "");
      name = name.replaceAll("uhd", "");

      if (name.contains("globo")) {
        name = "globo";
      }
      if (name.contains("sbt")) {
        name = "sbt";
      }
      if (name.contains("record")) {
        name = "record";
      }
      if (name.contains("band")) {
        name = "band";
      }
      name = "${name}.br";
      print(name);
      if (name != null) {
        var response = await getAllEpgFromChannel(name);
        print("TOTAL DE EPG: " + response.length.toString());
        setState(() {
          listaEPG = response;
        });
      }
    }
  }
}
