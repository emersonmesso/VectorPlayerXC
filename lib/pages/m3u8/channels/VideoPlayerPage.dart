import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pod_player/pod_player.dart';

import '../../../ad_helper.dart';
import '../../../components/ItemEPG.dart';
import '../../../components/ItemMove.dart';
import '../../../controller/functions.dart';
import '../../../models/ListM3U8/ResponseListM3U8Channel.dart';
import '../../../models/ResponseChannelEPG.dart';
import '../../../models/ResponseStorageAPI.dart';

class VideoPlayerPageM3U8 extends StatefulWidget {
  const VideoPlayerPageM3U8({Key? key, required this.channel})
      : super(key: key);
  final ListChannels channel;

  @override
  State<VideoPlayerPageM3U8> createState() => _VideoPlayerPageM3U8State();
}

class _VideoPlayerPageM3U8State extends State<VideoPlayerPageM3U8> {
  late ChewieController controller;
  late VideoPlayerController videoPlayerController;
  late ResponseStorageAPI responseStorageAPI;
  late List<ResponseChannelEPG> listaEPG = <ResponseChannelEPG>[];
  late bool isLoading;
  late bool isPlaying;
  late bool isFavourite = false;
  late bool isFullScreen = false;
  late int indexEPG = -1;
  //admob
  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  @override
  void initState() {
    isLoading = true;
    isPlaying = false;
    isFavourite = false;
    isFullScreen = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    print('ABRINDO LINK: ${widget.channel.url}');

    videoPlayerController = VideoPlayerController.network(widget.channel.url!);
    controller = ChewieController(
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
    super.initState();

    //get EPG
    getEPG();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: (indexEPG != -1)
                  ? (MediaQuery.of(context).size.width * 50) / 100
                  : (MediaQuery.of(context).size.width * 70) / 100,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(10.0),
              color: Colors.black,
              child: Stack(
                children: [
                  (isLoading)
                      ? Positioned(
                          child: Container(
                            color: Colors.transparent,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : Container(),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: videoPlayerController.value.isInitialized
                        ? AspectRatio(
                            aspectRatio:
                                const MediaQueryData().devicePixelRatio,
                            child: Chewie(
                              controller: controller,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (indexEPG != -1),
              child: (indexEPG != -1)
                  ? Container(
                      width: 200,
                      color: Theme.of(context).accentColor,
                      child: ListView(
                        children: [
                          ItemMove(
                            corBorda: Colors.white,
                            isCategory: true,
                            callback: () {
                              setState(() {
                                indexEPG = -1;
                              });
                            },
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  indexEPG = -1;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ItemEPG(
                            title: listaEPG[indexEPG].title!,
                            startTime: listaEPG[indexEPG].sStart!,
                            stopTime: listaEPG[indexEPG].sStop!,
                            index: indexEPG,
                            desc: listaEPG[indexEPG].desc,
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(1.0),
                color: Theme.of(context).backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.channel.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: "Candy",
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: (videoPlayerController.value.isInitialized)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (isPlaying)
                                    ? ItemMove(
                                      corBorda: Colors.white,
                                      isCategory: true,
                                      callback: _videoPause,
                                      child: const Icon(
                                        Icons.pause_circle_filled_outlined,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                    )
                                    : ItemMove(
                                      corBorda: Colors.white,
                                      isCategory: true,
                                      callback: _videoPlayer,
                                      child: const Icon(
                                        Icons.play_circle_fill_outlined,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                    ),
                                (!isFullScreen)
                                    ? ItemMove(
                                      corBorda: Colors.white,
                                      isCategory: true,
                                      callback: _enterFullscreen,
                                      child: const Icon(
                                        Icons.fullscreen_rounded,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                    )
                                    : ItemMove(
                                      corBorda: Colors.white,
                                      isCategory: true,
                                      callback: _toggleFullScreenOff,
                                      child: const Icon(
                                        Icons.fullscreen_exit_outlined,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                    ),
                              ],
                            )
                          : Container(),
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
                            return ItemMove(
                              isCategory: true,
                              callback: () {
                                if (indexEPG == index) {
                                  setState(() {
                                    indexEPG = -1;
                                  });
                                } else {
                                  setState(() {
                                    indexEPG = index;
                                  });
                                }
                              },
                              corBorda: Colors.white,
                              child: ItemEPG(
                                title: listaEPG[index].title!,
                                startTime: listaEPG[index].sStart!,
                                stopTime: listaEPG[index].sStop!,
                                index: index,
                              ),
                            );
                          }),
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

  void _videoPause() async {
    setState(() {
      controller.pause();
      isPlaying = false;
    });
  }

  void _videoPlayer() async {
    setState(() {
      controller.play();
      isPlaying = true;
    });
  }

  void _enterFullscreen() async {
    setState(() {
      controller.enterFullScreen();
    });
  }

  void _toggleFullScreenOff() {
    controller.exitFullScreen();
  }

  void getEPG() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    //convertendo o nome do canal para epgID
    var name = widget.channel.title!.replaceAll(" ", "").toLowerCase();
    name = name.replaceAll("hd", "");
    name = name.replaceAll("sd", "");
    name = name.replaceAll("fhd", "");
    name = name.replaceAll("4k", "");
    name = name.replaceAll("uhd", "");

    if(name.contains("globo")){
      name = "globo";
    }
    if(name.contains("sbt")){
      name = "sbt";
    }
    if(name.contains("record")){
      name = "record";
    }
    if(name.contains("band")){
      name = "band";
    }
    name = "${name}.br";
    if (name != null) {
      var response = await getAllEpgFromChannel(name);
      print("TOTAL DE EPG: " + response.length.toString());
      setState(() {
        listaEPG = response;
      });
    }
  }
}
