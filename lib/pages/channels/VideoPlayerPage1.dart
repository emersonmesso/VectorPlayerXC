import 'package:apptv/ad_helper.dart';
import 'package:apptv/components/ItemEPG.dart';
import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseChannelEPG.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/models/SettingsData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'package:appinio_video_player/appinio_video_player.dart';

class VideoPlayerPage1 extends StatefulWidget {
  const VideoPlayerPage1({Key? key, required this.url, required this.title})
      : super(key: key);
  final String url;
  final String title;

  @override
  State<VideoPlayerPage1> createState() => _VideoPlayerPage1M3U8State();
}

class _VideoPlayerPage1M3U8State extends State<VideoPlayerPage1> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  late ResponseStorageAPI responseStorageAPI;
  late List<ResponseChannelEPG> listaEPG = <ResponseChannelEPG>[];
  late SettingsData settings;
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
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    videoPlayerController.dispose();
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
                            child: CustomVideoPlayer(
                                customVideoPlayerController:
                                    _customVideoPlayerController),
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
                      widget.title!,
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
                              print("Ok");
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

  void _videoPause() async {
    setState(() {
      videoPlayerController.pause();
      isPlaying = false;
    });
  }

  void _videoPlayer() async {
    setState(() {
      videoPlayerController.play();
      isPlaying = true;
    });
  }

  void _enterFullscreen() async {
    _customVideoPlayerController.setFullscreen(true);
  }

  void _toggleFullScreenOff() {
    _customVideoPlayerController.setFullscreen(false);
  }

  void getEPG() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    //convertendo o nome do canal para epgID
    var name = widget.title!.replaceAll(" ", "").toLowerCase();
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
    if (name != null) {
      var response = await getAllEpgFromChannel(name);
      print("TOTAL DE EPG: " + response.length.toString());
      setState(() {
        listaEPG = response;
      });
    }
  }

  void _initData() async {
    settings = (await getSeetings())!;
    print('ABRINDO LINK: ${widget.url}');
    print("${settings.openFullScreen}");

    videoPlayerController = VideoPlayerController.network(widget.url!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        videoPlayerController.play();
        setState(() {});
      });
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
      customVideoPlayerSettings: const  CustomVideoPlayerSettings(
        showFullscreenButton: true,
      )
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

    getEPG();
  }
}
