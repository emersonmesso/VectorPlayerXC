import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pod_player/pod_player.dart';
import '../../ad_helper.dart';
import '../../components/ItemEPG.dart';
import '../../components/ItemMove.dart';
import '../../controller/functions.dart';
import '../../models/ResponseChannelAPI.dart';
import '../../models/ResponseChannelEPG.dart';
import '../../models/ResponseStorageAPI.dart';
import '../../models/SettingsData.dart';

const String keyUp = 'Arrow Up';
const String keyDown = 'Arrow Down';
const String keyLeft = 'Arrow Left';
const String keyRight = 'Arrow Right';
const String keyCenter = 'Select';

class VideoPlayerPageM3U8 extends StatefulWidget {
  const VideoPlayerPageM3U8({Key? key, required this.channel})
      : super(key: key);
  final ResponseChannelAPI channel;

  @override
  State<VideoPlayerPageM3U8> createState() => _VideoPlayerPageM3U8State();
}

class _VideoPlayerPageM3U8State extends State<VideoPlayerPageM3U8> {
  late VideoPlayerController videoPlayerController =
      VideoPlayerController.network("http://www.google.com");
  late ResponseStorageAPI responseStorageAPI;
  late List<ResponseChannelEPG> listaEPG = <ResponseChannelEPG>[];
  late SettingsData settings;
  late bool isLoading;
  late bool isPlaying;
  late bool isBuffering;
  late bool isFavourite = false;
  late bool isFullScreen = false;
  late int indexEPG = -1;
  late ResponseChannelAPI channel;
  //admob
  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  @override
  void initState() {
    channel = widget.channel;
    isLoading = true;
    isPlaying = false;
    isFavourite = false;
    isBuffering = true;
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
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (videoPlayerController.dataSource == "http://www.google.com")
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SafeArea(
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
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Visibility(
                            visible: isBuffering,
                            child: Container(
                              color: Colors.transparent,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: AspectRatio(
                            aspectRatio:
                                const MediaQueryData().devicePixelRatio,
                            child: VideoPlayer(
                              videoPlayerController,
                            ),
                          ),
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
                                ItemEPG(
                                  title: listaEPG[indexEPG].title!,
                                  startTime: listaEPG[indexEPG].sStart!,
                                  stopTime: listaEPG[indexEPG].sStop!,
                                  index: indexEPG,
                                  desc: listaEPG[indexEPG].desc,
                                ),
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
                                      setState(
                                        () {
                                          indexEPG = -1;
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
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
                            channel.name!,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      (isPlaying)
                                          ? ItemMove(
                                              corBorda: Colors.white,
                                              isCategory: true,
                                              callback: _videoPause,
                                              child: const Icon(
                                                Icons
                                                    .pause_circle_filled_outlined,
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
                                      (!isFavourite)
                                          ? GestureDetector(
                                              onTap: _onFavoriteClick,
                                              child: ItemMove(
                                                corBorda: Colors.white,
                                                isCategory: true,
                                                callback: _onFavoriteClick,
                                                child: const Icon(
                                                  Icons
                                                      .favorite_border_outlined,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: _onFavouriteOff,
                                              child: ItemMove(
                                                corBorda: Colors.white,
                                                isCategory: true,
                                                callback: _onFavouriteOff,
                                                child: const Icon(
                                                  Icons.favorite_outlined,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
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
    pushFullScreenVideo();
    await saveRecentPlayingChannel(channel, responseStorageAPI.url);
  }

  void _toggleFullScreenOff() async {
    pushFullScreenVideo();
    await saveRecentPlayingChannel(channel, responseStorageAPI.url);
  }

  void getEPG() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    if (channel.epg_channel_id != null) {
      var response = await getAllEpgFromChannel(channel.epg_channel_id!);
      print("TOTAL DE EPG: " + response.length.toString());
      setState(() {
        listaEPG = response;
      });
    }
  }

  void _onFavouriteOff() async {
    if (await removeFavourite(channel, responseStorageAPI.url)) {
      setState(() {
        isFavourite = false;
      });
    }
  }

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;
    if (await channelIsFavourite(channel, responseStorageAPI.url)) {
      setState(() {
        isFavourite = true;
      });
    }
    print(
        'ABRINDO LINK: ${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channel.streamId}.m3u8');
    videoPlayerController = VideoPlayerController.network(
        '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channel.streamId}.m3u8')
      ..initialize().then((value) {
        setState(() {
          isPlaying = true;
          isBuffering = false;
          videoPlayerController.play();
        });
        videoPlayerController.addListener(() {
          if (videoPlayerController.value.isBuffering) {
            setState(() {
              isBuffering = true;
            });
          } else {
            setState(() {
              isBuffering = false;
            });
          }
          if (videoPlayerController.value.hasError) {
            Fluttertoast.showToast(
              msg: "Recarregando...",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM_RIGHT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            videoPlayerController = VideoPlayerController.network(
                '${responseStorageAPI.url}live/${responseStorageAPI.username}/${responseStorageAPI.password}/${channel.streamId}.m3u8')
              ..initialize().then((value) {
                setState(() {
                  isPlaying = true;
                  isBuffering = false;
                  videoPlayerController.play();
                });
              });
          }
        });
        if (settings.openFullScreen!) {
          pushFullScreenVideo();
        }
      });

    if (!isMobile()) {
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

  void _onFavoriteClick() async {
    if (await saveFavorite(channel, responseStorageAPI.url)) {
      setState(() {
        isFavourite = true;
      });
    }
  }

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
                  return Stack(
                    //This will help to expand video in Horizontal mode till last pixel of screen
                    fit: isPortrait ? StackFit.loose : StackFit.expand,
                    children: [
                      AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(videoPlayerController),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Visibility(
                          visible: isBuffering,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ],
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
}
