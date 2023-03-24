import 'package:flutter/material.dart';
import '../controller/HttpController.dart';
import '../controller/functions.dart';
import '../models/ResponseChannelAPI.dart';
import '../models/ResponseChannelEPG.dart';
import '../models/ResponseStorageAPI.dart';
import '../models/SettingsData.dart';
import '../pages/channels/VideoPlayerPage.dart';
import '../pages/channels/VideoPlayerPage1.dart';
import 'ItemMove.dart';

class ItemChannel extends StatefulWidget {
  const ItemChannel({Key? key, required this.data}) : super(key: key);
  final ResponseChannelAPI data;
  @override
  State<ItemChannel> createState() => _ItemChannelState();
}

class _ItemChannelState extends State<ItemChannel> {
  late SettingsData settings = SettingsData(
    openFullScreen: false,
    openOldPeople: false,
    showEPG: false,
    showRecentsWhatshing: false,
  );
  late ResponseChannelAPI data;
  late bool loadingEPG;
  late String epgTitle = "";
  HTTpController api_controller = HTTpController();
  late List<ResponseChannelEPG> listaEPG;
  late ResponseStorageAPI responseStorageAPI;

  @override
  void initState() {
    data = widget.data;
    loadingEPG = true;
    listaEPG = <ResponseChannelEPG>[];
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
            builder: (context) => (isMobile())
                ? VideoPlayerPageM3U8(
                    channel: data,
                  )
                : VideoPlayerPage1(
                    title: '${data.name}',
                    url:
                        '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${data.streamId}.m3u8',
                  ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                data.name!,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            (settings.showEPG!)
                ? Center(
                  child: Text(
                      epgTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }

  void getEPG() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;

    if (data.epg_channel_id != null) {
      var response = await getEpgFromChannel(data.epg_channel_id!);
      if (response.length > 0) {
        setState(() {
          epgTitle = response[0].title!;
          listaEPG = response;
          loadingEPG = false;
        });
      } else {
        setState(() {
          loadingEPG = false;
        });
      }
    }
  }
}
