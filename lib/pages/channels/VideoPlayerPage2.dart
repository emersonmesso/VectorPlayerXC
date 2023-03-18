import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:pod_player/pod_player.dart';

import '../../ad_helper.dart';
import '../../components/ItemEPG.dart';
import '../../components/ItemMove.dart';
import '../../controller/HttpController.dart';
import '../../controller/functions.dart';
import '../../models/ResponseChannelAPI.dart';
import '../../models/ResponseChannelEPG.dart';
import '../../models/ResponseEPG.dart';
import '../../models/ResponseStorageAPI.dart';
import '../../models/SettingsData.dart';

class VideoPlayerPage2 extends StatefulWidget {
  const VideoPlayerPage2({Key? key, required this.data}) : super(key: key);
  final ResponseChannelAPI data;
  @override
  State<VideoPlayerPage2> createState() => _VideoPlayerPage2State();
}

class _VideoPlayerPage2State extends State<VideoPlayerPage2> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late ResponseStorageAPI responseStorageAPI;
  late List<ResponseEPG> listEPG;
  late ResponseChannelAPI dados;
  late bool initFullScreen;
  late bool isFavourite;
  late bool isPlaying;
  late bool isFullScreen;
  late bool onError;
  late int tentativas;
  late bool isBuffering;
  late bool isPlayingRecents;
  HTTpController api_controller = HTTpController();
  late SettingsData settings;
  late List<ResponseChannelEPG> listaEPG;
  //admob
  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  @override
  void initState() {
    listaEPG = <ResponseChannelEPG>[];
    dados = widget.data;
    tentativas = 0;
    initFullScreen = false;
    isPlaying = false;
    onError = false;
    isFavourite = false;
    isFullScreen = false;
    isPlayingRecents = false;
    isBuffering = false;
    //iniciando busca por dados
    iniData();
    getEPG();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width * 70) / 100,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(10.0),
              color: Colors.black,
              child: (chewieController != null)
                  ? AspectRatio(
                      aspectRatio: (16 / 9),
                      child: Stack(
                        children: [
                          Chewie(
                            controller: chewieController,
                          ),
                          Positioned(
                              top: 0,
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Visibility(
                                visible: onError,
                                child: Center(
                                  child: (tentativas < 4)
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              "Erro!",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 32,
                                                fontFamily: "Candy",
                                              ),
                                            ),
                                            Text(
                                              "Tente abrir outra qualidade do canal!",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 25,
                                                fontFamily: "Candy",
                                              ),
                                            ),
                                          ],
                                        )
                                      : const CircularProgressIndicator(),
                                ),
                              )),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(1.0),
                color: Theme.of(context).backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dados.name!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: "Candy",
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (chewieController != null)
                              ? Row(
                                  children: [
                                    (isPlaying)
                                        ? GestureDetector(
                                            onTap: _videoPause,
                                            child: ItemMove(
                                              corBorda: Colors.white,
                                              isCategory: true,
                                              callback: _videoPause,
                                              child: const Icon(
                                                Icons
                                                    .pause_circle_filled_outlined,
                                                size: 50,
                                                color: Colors.red,
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: _videoPlayer,
                                            child: ItemMove(
                                              corBorda: Colors.white,
                                              isCategory: true,
                                              callback: _videoPlayer,
                                              child: const Icon(
                                                Icons.play_circle_fill_outlined,
                                                size: 50,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                    (!isFullScreen)
                                        ? GestureDetector(
                                            onTap: _enterFullscreen,
                                            child: ItemMove(
                                              corBorda: Colors.white,
                                              isCategory: true,
                                              callback: _enterFullscreen,
                                              child: const Icon(
                                                Icons.fullscreen_rounded,
                                                size: 50,
                                                color: Colors.red,
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: _toggleFullScreenOff,
                                            child: ItemMove(
                                              corBorda: Colors.white,
                                              isCategory: true,
                                              callback: _toggleFullScreenOff,
                                              child: const Icon(
                                                Icons.fullscreen_exit_outlined,
                                                size: 50,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                  ],
                                )
                              : Container(),
                          (!isFavourite)
                              ? GestureDetector(
                                  onTap: _onFavoriteClick,
                                  child: ItemMove(
                                    corBorda: Colors.white,
                                    isCategory: true,
                                    callback: _onFavoriteClick,
                                    child: const Icon(
                                      Icons.favorite_border_outlined,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : ItemMove(
                                corBorda: Colors.white,
                                isCategory: true,
                                callback: _onFavouriteOff,
                                child: const Icon(
                                  Icons.favorite_outlined,
                                  size: 50,
                                  color: Colors.red,
                                ),
                              ),
                        ],
                      ),
                    ),
                    if (_bannerAd != null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: listaEPG.length,
                        itemBuilder: (context, index) {
                          return ItemEPG(
                            title: listaEPG[index].title!,
                            startTime: listaEPG[index].sStart!,
                            stopTime: listaEPG[index].sStop!,
                            index: index,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void iniData() async {
    //buscando os dados da API
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;

    //verificando se o canal é favorito
    if (await channelIsFavourite(dados, responseStorageAPI.url)) {
      setState(() {
        isFavourite = true;
      });
    }
    print(
        'ABRINDO LINK: ${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${dados.streamId}.m3u8');

    videoPlayerController = VideoPlayerController.network(
        '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${dados.streamId}.m3u8');
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      isLive: true,
      autoPlay: true,
      showControls: isMobile(),
      fullScreenByDefault: !isMobile(),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
    );

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
    });

    /*

    setState(() {
      videoPlayerController = VideoPlayerController.network(
          '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${dados.streamId}.m3u8');

      //listeners
      videoPlayerController.addListener(() {
        if (videoPlayerController.value.isBuffering) {
          print("Loading...");
          setState(() {
            isBuffering = true;
          });
        } else {
          setState(() {
            isBuffering = false;
          });
        }
        if (videoPlayerController.value.hasError) {
          onVideoError(context);
        }
      });
      chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          isLive: true,
          fullScreenByDefault: settings.openFullScreen!,
          showControls: false,
          aspectRatio: videoPlayerController.value.aspectRatio,
          overlay: overlay(),
          deviceOrientationsAfterFullScreen: const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ]);
    });

    //listeners
    chewieController.addListener(() async {
      //vídeo rodando
      if (chewieController.isPlaying) {
        setState(() {
          isPlaying = true;
        });
      }
      //vídeo parado
      if (!chewieController.isPlaying) {
        setState(() {
          tentativas = tentativas + 1;
          isPlaying = false;
        });
      }

      //víde em fullScreen
      if (chewieController.isFullScreen) {
        if (!isPlayingRecents) {
          if (await saveRecentPlayingChannel(dados, responseStorageAPI.url)) {
            print("Salvo nos recenter!");
            setState(() {
              isFullScreen = true;
              isPlayingRecents = true;
            });
          } else {
            print("Último salvo já é o canal");
            setState(() {
              isFullScreen = true;
              isPlayingRecents = true;
            });
          }
        }
      }
      if (!chewieController.isFullScreen) {
        setState(() {
          isFullScreen = false;
        });
      }
    });

     */

    if (isMobile()) {
      //admob
      // TODO: Load a banner ad
      MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
          testDeviceIds: ['8F4DE589F88E8FFBB2FC2F8019412BA2']));
      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            ad.dispose();
          },
        ),
      ).load();
    }
  }

  void getEPG() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    if (dados.epg_channel_id != null) {
      var response = await getAllEpgFromChannel(dados.epg_channel_id!);
      setState(() {
        listaEPG = response;
      });
    }
  }

  void _videoPause() async {
    setState(() {
      chewieController.pause();
      isPlaying = false;
    });
    if (!isPlayingRecents) {
      if (await saveRecentPlayingChannel(dados, responseStorageAPI.url)) {
        print("Salvo nos recenter!");
      } else {
        print("Último salvo já é o canal");
      }
    }
  }

  void _videoPlayer() async {
    setState(() {
      chewieController.play();
      isPlaying = true;
    });
    if (!isPlayingRecents) {
      if (await saveRecentPlayingChannel(dados, responseStorageAPI.url)) {
        print("Salvo nos recenter!");
      } else {
        print("Último salvo já é o canal");
      }
    }
  }

  void _enterFullscreen() async {
    setState(() {
      chewieController.enterFullScreen();
    });
    if (!isPlayingRecents) {
      if (await saveRecentPlayingChannel(dados, responseStorageAPI.url)) {
        print("Salvo nos recenter!");
      } else {
        print("Último salvo já é o canal");
      }
    }
  }

  void _toggleFullScreenOff() {
    chewieController.exitFullScreen();
  }

  void _onFavoriteClick() async {
    //adicionando como favorito
    if (await saveFavorite(dados, responseStorageAPI.url)) {
      setState(() {
        isFavourite = true;
      });
    }
  }

  Widget overlay() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: GestureDetector(
        child: (isBuffering)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(),
      ),
    );
  }

  void _onFavouriteOff() async {
    if (await removeFavourite(dados, responseStorageAPI.url)) {
      setState(() {
        isFavourite = false;
      });
    }
  }

  onVideoError(BuildContext context) {
    chewieController.exitFullScreen();
    setState(() {
      onError = true;
    });
  }
}
