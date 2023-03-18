import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

import '../components/ItemMove.dart';
import '../controller/functions.dart';
import '../models/ResponseChannelAPI.dart';
import '../models/ResponseStorageAPI.dart';
import '../models/SettingsData.dart';

class PlayerVideoOld extends StatefulWidget {
  const PlayerVideoOld({Key? key}) : super(key: key);

  @override
  State<PlayerVideoOld> createState() => _PlayerVideoOldState();
}

class _PlayerVideoOldState extends State<PlayerVideoOld> {
  late bool isLoading;
  late bool isPlaying;
  late bool isOption;
  late String EPGTitle;
  late String EPGTitlenext;
  late ResponseStorageAPI responseStorageAPI;
  late SettingsData settings;
  late List<ResponseChannelAPI> listaFavourites = <ResponseChannelAPI>[];
  late ResponseChannelAPI channelActive;
  late ChewieController controller;
  late VideoPlayerController videoPlayerController;
  late int index;

  @override
  void initState() {
    index = 0;
    EPGTitle = "Sem Programação";
    EPGTitlenext = "Sem Programação";
    isPlaying = false;
    isLoading = false;
    isOption = false;
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<String?> getEPG(ResponseChannelAPI channel) async {
    if (channelActive.epg_channel_id != null) {
      var response = await getAllEpgFromChannel(channel.epg_channel_id!);
      if (response.length > 0) {
        return response[0].title!;
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          (controller != null)
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: (MediaQuery.of(context).size.height * 80) / 100,
                  color: Theme.of(context).backgroundColor,
                  child: AspectRatio(
                    aspectRatio: (16 / 9),
                    child: Chewie(
                      controller: controller,
                    ),
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width * 40) / 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.network(
                              channelActive.streamIcon!,
                              fit: BoxFit.contain,
                              width: 40,
                              height: 40,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Image.asset(
                                  "lib/assets/logo.png",
                                  fit: BoxFit.contain,
                                  width: 40,
                                  height: 40,
                                );
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              channelActive.name!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          EPGTitle,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width * 30) / 100,
                          child: Row(
                            children: [
                              (index > 0)
                                  ? ItemMove(
                                      callback: () {
                                        setState(() {
                                          index -= 1;
                                          channelActive =
                                              listaFavourites[index];
                                        });
                                        _changeChannelPlayer();
                                      },
                                      isCategory: true,
                                      corBorda: Colors.white,
                                      child: const Icon(
                                        Icons.skip_previous,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    )
                                  : Container(),
                              (videoPlayerController != null &&
                                      videoPlayerController.value.isPlaying)
                                  ? ItemMove(
                                      callback: () {
                                        controller.togglePause();
                                      },
                                      isCategory: true,
                                      corBorda: Colors.white,
                                      child: const Icon(
                                        Icons.pause_circle_filled_outlined,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    )
                                  : ItemMove(
                                      callback: () {
                                        controller.togglePause();
                                      },
                                      isCategory: true,
                                      corBorda: Colors.white,
                                      child: const Icon(
                                        Icons.play_circle,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    ),
                              listaFavourites.length > (index + 1)
                                  ? ItemMove(
                                      callback: () {
                                        setState(() {
                                          index += 1;
                                          channelActive =
                                              listaFavourites[index];
                                        });
                                        _changeChannelPlayer();
                                      },
                                      isCategory: true,
                                      corBorda: Colors.white,
                                      child: const Icon(
                                        Icons.skip_next,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    )
                                  : Container(),
                              (videoPlayerController.value.isInitialized &&
                                      controller.isFullScreen)
                                  ? ItemMove(
                                      callback: () {
                                        controller.toggleFullScreen();
                                      },
                                      isCategory: true,
                                      corBorda: Colors.white,
                                      child: const Icon(
                                        Icons.fullscreen_exit,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    )
                                  : ItemMove(
                                      callback: () {
                                        controller.toggleFullScreen();
                                      },
                                      isCategory: true,
                                      corBorda: Colors.white,
                                      child: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        _nextWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings()!)!;
    //buscando os canais favoritos
    var response = await getListFavourites(responseStorageAPI.url);
    if (response!.length > 0) {
      setState(() {
        listaFavourites = response;
        channelActive = listaFavourites[0];
      });
      //abrindo o player de vídeo
      _initPlayer();
    } else {
      Fluttertoast.showToast(
        msg: "Adicione canais aos favoritos!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    }
  }

  _nextWidget() {
    if (listaFavourites.length > (index + 1)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Próximo: ",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Image.network(
                listaFavourites[index + 1].streamIcon!,
                fit: BoxFit.contain,
                width: 30,
                height: 30,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    "lib/assets/logo.png",
                    fit: BoxFit.contain,
                    width: 30,
                    height: 30,
                  );
                },
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                listaFavourites[index + 1].name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            EPGTitlenext,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  _initPlayer() async {
    print(
        'ABRINDO LINK: ${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channelActive.streamId}.${settings.typelist!}');
    setState(() {
      videoPlayerController = VideoPlayerController.network(
          '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channelActive.streamId}.${settings.typelist!}');
    });
    controller = ChewieController(
      videoPlayerController: videoPlayerController,
      isLive: true,
      autoPlay: true,
      showControls: isMobile(),
      aspectRatio: MediaQuery.of(context).devicePixelRatio,
      fullScreenByDefault: settings.openFullScreen!,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
      showControlsOnInitialize: false,
      allowPlaybackSpeedChanging: false,
      allowedScreenSleep: false,
      showOptions: false,
      overlay: _overlayWidget(),
    );
    //canal ativo
    String? title = await getEPG(channelActive);
    if (title != null) {
      setState(() {
        EPGTitle = title!;
      });
    }else{
      setState(() {
        EPGTitle = "Sem Programação";
      });
    }

    if (listaFavourites.length > (index + 1)) {
      String? titleNext = await getEPG(listaFavourites[index + 1]);
      if (titleNext != null) {
        setState(() {
          EPGTitlenext = titleNext!;
        });
      }
    }
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isPlaying) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }

      if (videoPlayerController.value.hasError) {
        Fluttertoast.showToast(
          msg: "Vídeo não encontrado!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      }

      if (videoPlayerController.value.isBuffering) {
        setState(() {
          isLoading = true;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  _changeChannelPlayer() async {
    if (videoPlayerController != null) {
      videoPlayerController.dispose();
      controller.dispose();
    }
    print(
        'ABRINDO LINK: ${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channelActive.streamId}.${settings.typelist!}');
    setState(() {
      videoPlayerController = VideoPlayerController.network(
          '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channelActive.streamId}.${settings.typelist!}');
      controller = ChewieController(
        videoPlayerController: videoPlayerController,
        isLive: true,
        autoPlay: true,
        showControls: isMobile(),
        aspectRatio: MediaQuery.of(context).devicePixelRatio,
        fullScreenByDefault: settings.openFullScreen!,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ],
        showControlsOnInitialize: false,
        allowPlaybackSpeedChanging: false,
        allowedScreenSleep: false,
        showOptions: false,
        overlay: _overlayWidget(),
      );
    });
    //canal ativo
    String? title = await getEPG(channelActive);
    if (title != null) {
      setState(() {
        EPGTitle = title!;
      });
    }

    if (listaFavourites.length > (index + 1)) {
      String? titleNext = await getEPG(listaFavourites[index + 1]);
      if (titleNext != null) {
        setState(() {
          EPGTitlenext = titleNext!;
        });
      }
    }
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isPlaying) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }

      if (videoPlayerController.value.hasError) {
        Fluttertoast.showToast(
          msg: "Vídeo não encontrado!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      }

      if (videoPlayerController.value.isBuffering) {
        setState(() {
          isLoading = true;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  _overlayWidget() {
    return (isLoading)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container();
  }
}
