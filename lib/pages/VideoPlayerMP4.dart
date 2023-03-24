import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';
import '../controller/HttpController.dart';
import '../controller/functions.dart';
import '../models/ResponseStorageAPI.dart';
import '../models/SettingsData.dart';

const String keyUp = 'Arrow Up';
const String keyDown = 'Arrow Down';
const String keyLeft = 'Arrow Left';
const String keyRight = 'Arrow Right';
const String keyCenter = 'Select';

class VideoPlayerMP4 extends StatefulWidget {
  const VideoPlayerMP4({Key? key, required this.title, required this.id, required this.type}) : super(key: key);
  final String title;
  final String id;
  final bool type;

  @override
  State<VideoPlayerMP4> createState() => _VideoPlayerMP4State();
}

class _VideoPlayerMP4State extends State<VideoPlayerMP4> {
  late VideoPlayerController videoPlayerController =
      VideoPlayerController.network("http://google.com.br");
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late bool isLoading;
  late bool isBuffering;
  late bool isFavourite;
  late bool isPlaying;
  late bool viewBar;
  late String information;
  late SettingsData settings;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    isFavourite = false;
    isPlaying = false;
    isBuffering = false;
    viewBar = true;
    information = "";
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoPlayerController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        autofocus: true,
        includeSemantics: true,
        focusNode: focusNode,
        onKey: ((key) => handleKey(key)),
        child: (videoPlayerController.dataSource == "http://www.google.com")
            ? Container(
                color: Theme.of(context).backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                color: Theme.of(context).backgroundColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      top: 0,
                      right: 0,
                      left: 0,
                      child: AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(
                          videoPlayerController,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Container(
                              color: Colors.transparent,
                              width: (MediaQuery.of(context).size.width * 30) /
                                  100,
                              height: MediaQuery.of(context).size.height,
                            ),
                            onDoubleTap: () {
                              actionLeft();
                            },
                            onTap: () {
                              openBar();
                            },
                          ),
                          GestureDetector(
                            child: Container(
                              color: Colors.transparent,
                              width: (MediaQuery.of(context).size.width * 30) /
                                  100,
                              height: MediaQuery.of(context).size.height,
                            ),
                            onDoubleTap: () {
                              actionCenter();
                            },
                            onTap: () {
                              openBar();
                            },
                          ),
                          GestureDetector(
                            child: Container(
                              color: Colors.transparent,
                              width: (MediaQuery.of(context).size.width * 30) /
                                  100,
                              height: MediaQuery.of(context).size.height,
                            ),
                            onDoubleTap: () {
                              actionRight();
                            },
                            onTap: () {
                              openBar();
                            },
                          ),
                        ],
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
                      right: 0,
                      child: SizedBox(
                        width: 200,
                        height: 100,
                        child: Center(
                          child: Text(
                            information,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: viewBar,
                      child: Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: 50,
                          color: Theme.of(context).backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                (videoPlayerController.dataSource !=
                                        "http://www.google.com")
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formatDurationInHhMmSs(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            child: LinearPercentIndicator(
                                              lineHeight: 5.0,
                                              percent: (videoPlayerController
                                                          .dataSource !=
                                                      "http://www.google.com")
                                                  ? percentIndicator()
                                                  : 0,
                                              backgroundColor: Theme.of(context)
                                                  .backgroundColor,
                                              progressColor: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            durationToString(
                                                videoPlayerController
                                                    .value.duration.inMinutes),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _initData() async {
    //buscando os dados da API
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;

    if(widget.type){
      //Filme
      videoPlayerController = VideoPlayerController.network(
          '${responseStorageAPI.url}movie/${responseStorageAPI.username}/${responseStorageAPI.password}/${widget.id}.mp4')
        ..initialize().then((value) {
          setState(() {
            viewBar = false;
            isPlaying = true;
            videoPlayerController.play();
          });
        });
    } else {
      //série
      videoPlayerController = VideoPlayerController.network(
          '${responseStorageAPI.url}series/${responseStorageAPI.username}/${responseStorageAPI.password}/${widget.id}.mp4')
        ..initialize().then((value) {
          setState(() {
            viewBar = false;
            isPlaying = true;
            videoPlayerController.play();
          });
        });
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
          actionLeft();
          break;
        case keyRight:
          actionRight();
          break;
        default:
          break;
      }
    }
  }

  openBar() {
    setState(() {
      viewBar = true;
    });
    actionAnimatedBar();
  }

  actionAnimatedBar() {
    Timer(const Duration(seconds: 5), () {
      setState(() {
        viewBar = false;
      });
    });
  }

  actionCenter() {
    if (videoPlayerController.value.isPlaying) {
      setState(() {
        viewBar = true;
        information = "pause";
      });
      actionAnimatedBar();
      videoPlayerController.pause();
      removerInfo();
    } else {
      setState(() {
        viewBar = false;
        information = "play";
      });
      actionAnimatedBar();
      videoPlayerController.play();
      removerInfo();
    }
  }

  actionLeft() {
    setState(() {
      information = "- 1 min";
      viewBar = true;
    });
    actionAnimatedBar();
    videoPlayerController.seekTo(Duration(
        minutes: (videoPlayerController.value.position.inMinutes - 1)));
    removerInfo();
  }

  actionRight() {
    setState(() {
      information = "+ 1 min";
      viewBar = true;
    });
    actionAnimatedBar();
    videoPlayerController.seekTo(Duration(
        minutes: (videoPlayerController.value.position.inMinutes + 1)));
    removerInfo();
  }

  removerInfo() {
    Timer(const Duration(seconds: 3), () {
      setState(() {
        information = "";
      });
    });
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String formatDurationInHhMmSs() {
    Duration duration = Duration(milliseconds: videoPlayerController.value.position.inMilliseconds,);
    final HH = (duration.inHours).toString().padLeft(2, '0');
    final mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$HH:$mm:$ss';
  }

  double percentIndicator() {
    int segTotal = videoPlayerController.value.duration.inSeconds;
    int segAtual = videoPlayerController.value.position.inSeconds;
    double percent = (100 * segAtual) / segTotal;
    double result = (percent * 1) / 100;
    return result;
  }
}
