import 'package:apptv/components/ItemEPG.dart';
import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/models/ResponseChannelEPG.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../controller/functions.dart';
import '../../models/ResponseChannelAPI.dart';
import '../../models/ResponseStorageAPI.dart';
import '../../models/SettingsData.dart';

const String keyUp = 'Arrow Up';
const String keyDown = 'Arrow Down';
const String keyLeft = 'Arrow Left';
const String keyRight = 'Arrow Right';
const String keyCenter = 'Select';

class FavouritesChannelPage extends StatefulWidget {
  const FavouritesChannelPage({Key? key}) : super(key: key);

  @override
  State<FavouritesChannelPage> createState() => _FavouritesChannelPageState();
}

class _FavouritesChannelPageState extends State<FavouritesChannelPage> {
  late bool isLoading;
  late List<ResponseChannelAPI> listaFavourites = <ResponseChannelAPI>[];
  late ResponseStorageAPI responseStorageAPI;
  late VideoPlayerController videoPlayerController =
      VideoPlayerController.network("http://google.com.br");
  late List<ResponseChannelEPG> listaEPG = <ResponseChannelEPG>[];
  late bool isPlaying;
  late SettingsData settings;
  late String nameChannel;
  late bool isBuffering;
  late int indexChannel;
  late bool isFavourites;

  @override
  void initState() {
    isFavourites = false;
    isLoading = true;
    isBuffering = false;
    nameChannel = "";
    indexChannel = 0;
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: const Text("Canais Favoritos"),
      ),
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (!isFavourites)
              ? const Center(
                  child: Text(
                    "Sem Canais Favoritos!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height:
                                (MediaQuery.of(context).size.height * 50) / 100,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  left: 0,
                                  child: AspectRatio(
                                    aspectRatio:
                                        videoPlayerController.value.aspectRatio,
                                    child: VideoPlayer(
                                      videoPlayerController,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: isBuffering,
                                  child: const Positioned(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: pushFullScreenVideo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      nameChannel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                      ),
                                    ),
                                    ItemMove(
                                      callback: () async {
                                        if (await removeFavourite(
                                            listaFavourites[indexChannel],
                                            responseStorageAPI.url)) {
                                          Get.back();
                                        }
                                      },
                                      isCategory: true,
                                      corBorda: Colors.white,
                                      child: IconButton(
                                        onPressed: () async {
                                          if (await removeFavourite(
                                              listaFavourites[indexChannel],
                                              responseStorageAPI.url)) {
                                            Get.back();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.favorite,
                                          size: 35,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                (listaEPG.length > 0)
                                    ? ItemEPG(
                                        title: listaEPG[0].title!,
                                        startTime: listaEPG[0].sStart!,
                                        stopTime: listaEPG[0].sStop!,
                                        index: 0,
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * 40) / 100,
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                          itemCount: listaFavourites.length,
                          itemBuilder: (context, index) {
                            return ItemMove(
                              callback: () {
                                setState(() {
                                  indexChannel = index;
                                });
                                actionEnterChannel(listaFavourites[index]);
                              },
                              corBorda: Colors.white,
                              isCategory: true,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                  ),
                                  height: 50,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        listaFavourites[index].name!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoPlayerController.dispose();
    super.dispose();
  }

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;
    //buscando os canais favoritos
    var response = await getListFavourites(responseStorageAPI.url);
    if (response != null) {
      setState(() {
        listaFavourites = response;
        isLoading = false;
      });
      if (response.length > 0) {
        setState(() {
          isFavourites = true;
        });
        //inicia o primeiro canal da lista
        videoPlayerController = VideoPlayerController.network(
            '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${listaFavourites[indexChannel].streamId}.m3u8')
          ..initialize().then((value) {
            setState(() {
              nameChannel = listaFavourites[indexChannel].name!;
              isPlaying = true;
              isBuffering = false;
              videoPlayerController.play();
            });
            getEPG(listaFavourites[0]);
          }).onError((error, stackTrace) {
            setState(() {
              isPlaying = false;
            });
          });

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
          if (videoPlayerController.value.isBuffering) {
            print("Carregando...");
            setState(() {
              isBuffering = true;
            });
          } else {
            setState(() {
              isBuffering = false;
            });
          }
        });
      } else {
        //não tem canal favorito
      }
    } else {
      //não tem nada a ser mostrado
      setState(() {
        isLoading = false;
      });
    }
  }

  /*FUNCTIONS*/
  actionCenter() {
    if (videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
    } else {
      videoPlayerController.play();
    }
  }

  handleKey(RawKeyEvent key) {
    if (key.runtimeType.toString() == 'RawKeyDownEvent') {
      print(key.logicalKey.keyLabel);
      switch (key.logicalKey.keyLabel) {
        case keyCenter:
          actionCenter();
          break;
        case keyUp:
          break;
        case keyDown:
          break;
        case keyLeft:
          break;
        case keyRight:
          break;
        default:
          break;
      }
    }
  }

  void pushFullScreenVideo() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
    );
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        opaque: false,
        settings: const RouteSettings(),
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: RawKeyboardListener(
              autofocus: true,
              includeSemantics: true,
              focusNode: FocusNode(),
              onKey: ((key) => handleKey(key)),
              child: OrientationBuilder(
                builder: (context, orientation) {
                  bool isPortrait = orientation == Orientation.portrait;
                  return Center(
                    child: Stack(
                      //This will help to expand video in Horizontal mode till last pixel of screen
                      fit: isPortrait ? StackFit.loose : StackFit.expand,
                      children: [
                        AspectRatio(
                          aspectRatio: videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(videoPlayerController),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    )
        .then(
      (value) {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ],
        );
      },
    );
  }

  void actionEnterChannel(ResponseChannelAPI channel) {
    //verifica se o canal é o mesmo
    if (videoPlayerController.dataSource ==
            '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channel.streamId}.m3u8' &&
        isPlaying) {
      //mesmo canal, abre o player em tela cheia
      pushFullScreenVideo();
    } else {
      if (videoPlayerController != null) {
        videoPlayerController.dispose();
      }
      //abre um novo canal no player
      setState(() {
        isBuffering = true;
      });
      videoPlayerController = VideoPlayerController.network(
          '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channel.streamId}.m3u8')
        ..initialize().then((value) {
          setState(() {
            nameChannel = channel.name!;
            isPlaying = true;
            isBuffering = false;
            videoPlayerController.play();
          });
          getEPG(channel);
        }).onError((error, stackTrace) {
          setState(() {
            isPlaying = false;
          });
        });

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
        if (videoPlayerController.value.isBuffering) {
          print("Carregando...");
          setState(() {
            isBuffering = true;
          });
        } else {
          setState(() {
            isBuffering = false;
          });
        }
      });
    }
  }

  void getEPG(ResponseChannelAPI channel) async {
    if (channel.epg_channel_id != null) {
      var response = await getEpgFromChannel(channel.epg_channel_id!);
      if (response.length > 0) {
        setState(() {
          listaEPG = response;
        });
      }
    }
  }
}
