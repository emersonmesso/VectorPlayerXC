import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/models/ResponseAPITMDB.dart';
import 'package:apptv/models/ResponseMoviesCategory.dart';
import 'package:apptv/models/SettingsData.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pod_player/pod_player.dart';
import '../../controller/functions.dart';
import '../../models/ResponseStorageAPI.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails({Key? key, required this.movie}) : super(key: key);
  final ResponseMoviesCategory movie;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  late ResponseMoviesCategory movie;
  late bool isLoading;
  late bool isBuffering;
  late bool isFavourite;
  late bool isPlaying;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late ResponseAPITMDB dadosAPITMDB;
  late ChewieController controller;
  late VideoPlayerController videoPlayerController;
  late SettingsData settings;

  @override
  void initState() {
    isLoading = true;
    isFavourite = false;
    isPlaying = false;
    isBuffering = false;
    movie = widget.movie;
    dadosAPITMDB = ResponseAPITMDB(id: 0);
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (isLoading)
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SafeArea(
              child: Container(
                decoration: (dadosAPITMDB == null)
                    ? BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                      )
                    : BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          image: (dadosAPITMDB.backdropPath != null)
                              ? NetworkImage(
                                  "https://image.tmdb.org/t/p/original${dadosAPITMDB.backdropPath}")
                              : const NetworkImage(
                                  "https://vectorplayer.com/_core/_img/back-clean.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width * 30) / 100,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            width:
                                (MediaQuery.of(context).size.width * 32) / 100,
                            height: (MediaQuery.of(context).size.height - 150),
                            child: Image.network(
                              movie.streamIcon!,
                              fit: BoxFit.contain,
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
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                (isPlaying == false)
                                    ? ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: () {
                                          setState(() {
                                            isPlaying = true;
                                            videoPlayerController.play();
                                          });
                                        },
                                        child: const Icon(
                                          Icons.play_circle_fill_outlined,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      )
                                    : ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: () {
                                          setState(() {
                                            !isPlaying;
                                          });
                                          videoPlayerController.pause();
                                        },
                                        child: const Icon(
                                          Icons.pause_circle_filled_outlined,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      ),
                                (isFavourite == false)
                                    ? ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: _saveFavourite,
                                        child: const Icon(
                                          Icons.favorite_border_outlined,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      )
                                    : ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: _removeFavourite,
                                        child: const Icon(
                                          Icons.favorite_outlined,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      ),
                                (isPlaying)
                                    ? ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: _enterFullScreen,
                                        child: const Icon(
                                          Icons.fullscreen,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView(
                          children: [
                            Visibility(
                              visible: true,
                              child: ItemMove(
                                corBorda: Colors.transparent,
                                callback: () {
                                  controller.enterFullScreen();
                                },
                                isCategory: true,
                                child: Container(
                                  height: (MediaQuery.of(context).size.height *
                                          60) /
                                      100,
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      (isBuffering)
                                          ? Positioned(
                                              child: Container(
                                                color: Colors.transparent,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Positioned(
                                        top: 0,
                                        bottom: 0,
                                        right: 0,
                                        left: 0,
                                        child: Chewie(
                                          controller: controller,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              movie.name!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            (dadosAPITMDB.id != 0)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dadosAPITMDB.overview!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
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

    //verifica se o filme é favorito
    var responseIsFavourite =
        await movieIsFavourite(movie, responseStorageAPI.url);
    if (responseIsFavourite) {
      setState(() {
        isFavourite = true;
      });
    }

    try {
      //buscando os dados Da API TMDB
      var myString = movie.name;
      final splitted = myString?.split('(');
      var aStr = splitted![1].replaceAll(RegExp(r'[^0-9]'), '');
      var ano = "";
      if (aStr != null && aStr != "") {
        ano = aStr;
      }
      print("Ano do Filme: " + aStr);
      var response =
          await api_controller.getInfoMovieFromTMDB(splitted?[0], ano);
      if (response != null) {
        if (response.id != 0) {
          setState(() {
            dadosAPITMDB = response;
            isLoading = false;
          });
          print(
              '${responseStorageAPI.url}movie/${responseStorageAPI.username}/${responseStorageAPI.password}/${movie.streamId}.mp4');
          videoPlayerController = VideoPlayerController.network(
              '${responseStorageAPI.url}movie/${responseStorageAPI.username}/${responseStorageAPI.password}/${movie.streamId}.mp4');

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
          controller = ChewieController(
            autoInitialize: true,
            showControlsOnInitialize: false,
            allowPlaybackSpeedChanging: false,
            allowedScreenSleep: false,
            showOptions: false,
            videoPlayerController: videoPlayerController,
            fullScreenByDefault: settings.openFullScreen!,
            aspectRatio: MediaQuery.of(context).devicePixelRatio,
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft,
            ],
          );
        } else {
          //não tem dados
          setState(() {
            isLoading = false;
          });
          videoPlayerController = VideoPlayerController.network(
              '${responseStorageAPI.url}movie/${responseStorageAPI.username}/${responseStorageAPI.password}/${movie.streamId}.mp4');
          videoPlayerController.addListener(() {
            if (videoPlayerController.value.isPlaying) {
              print("Play");
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
          controller = ChewieController(
            autoInitialize: true,
            showControlsOnInitialize: false,
            allowPlaybackSpeedChanging: false,
            allowedScreenSleep: false,
            showOptions: false,
            aspectRatio: MediaQuery.of(context).devicePixelRatio,
            videoPlayerController: videoPlayerController,
            fullScreenByDefault: settings.openFullScreen!,
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft,
            ],
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Filme não disponível!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Filme não dispoível!",
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

  @override
  void dispose() {
    videoPlayerController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _saveFavourite() async {
    var response = await saveFavoriteMovie(movie, responseStorageAPI.url);
    if (response) {
      setState(() {
        isFavourite = true;
      });
    }
  }

  void _removeFavourite() async {
    var response = await removeFavouriteMovie(movie, responseStorageAPI.url);
    if (response) {
      setState(() {
        isFavourite = false;
      });
    }
  }

  _enterFullScreen() {
    controller.enterFullScreen();
  }
}
