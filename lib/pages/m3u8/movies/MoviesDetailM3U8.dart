import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

import '../../../components/ItemMove.dart';
import '../../../controller/HttpController.dart';
import '../../../controller/functions.dart';
import '../../../models/ListM3U8/ResponseListM3U8Channel.dart';
import '../../../models/ResponseAPITMDB.dart';
import '../../../models/ResponseStorageAPI.dart';

class MoviesDetailM3U8 extends StatefulWidget {
  const MoviesDetailM3U8({Key? key, required this.movie}) : super(key: key);
  final ListChannels movie;

  @override
  State<MoviesDetailM3U8> createState() => _MoviesDetailM3U8State();
}

class _MoviesDetailM3U8State extends State<MoviesDetailM3U8> {
  late ListChannels movie;
  late bool isLoading;
  late bool isFavourite;
  late bool isPlaying;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late ResponseAPITMDB dadosAPITMDB;
  late PodPlayerController controller;

  @override
  void initState() {
    isLoading = true;
    isFavourite = false;
    isPlaying = false;
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
                              movie.logo!,
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
                                (isPlaying == false &&
                                        controller.isVideoPlaying)
                                    ? ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: () {
                                          setState(() {
                                            isPlaying = true;
                                            controller.togglePlayPause();
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
                                          controller.togglePlayPause();
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
                                        callback: () {},
                                        child: const Icon(
                                          Icons.favorite_border_outlined,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      )
                                    : ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: () {},
                                        child: const Icon(
                                          Icons.favorite_outlined,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      ),
                                (isPlaying == true &&
                                        controller.videoPlayerValue!.isPlaying)
                                    ? ItemMove(
                                        corBorda: Colors.white,
                                        isCategory: true,
                                        callback: () {},
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
                            SizedBox(
                              child: (controller.videoPlayerValue != null)
                                  ? PodVideoPlayer(controller: controller)
                                  : Container(),
                            ),
                            Text(
                              movie.title!,
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

    //buscando os dados Da API TMDB
    var myString = movie.title;
    final splitted = myString?.split('(');
    var aStr = splitted![1].replaceAll(RegExp(r'[^0-9]'), '');
    var ano = "";
    if (aStr != null && aStr != "") {
      ano = aStr;
    }
    print("Ano do Filme: " + aStr);
    print("${movie.url}");
    var response = await api_controller.getInfoMovieFromTMDB(splitted?[0], ano);
    if (response != null) {
      if (response.id != 0) {
        setState(() {
          dadosAPITMDB = response;
          isLoading = false;

          controller = PodPlayerController(
            playVideoFrom: PlayVideoFrom.network(
              movie.url!,
            ),
          )..initialise();

          controller.addListener(() {
            if (controller.videoPlayerValue!.isPlaying) {
              setState(() {
                isPlaying = true;
              });
            } else {
              setState(() {
                isPlaying = false;
              });
            }
          });
        });
      } else {
        //não tem dados
        setState(() {
          isLoading = false;
        });
        controller = PodPlayerController(
          playVideoFrom: PlayVideoFrom.network(
            movie.url!,
          ),
        )..initialise();

        controller.addListener(() {
          if (controller.videoPlayerValue!.isPlaying) {
            setState(() {
              isPlaying = true;
            });
          } else {
            setState(() {
              isPlaying = false;
            });
          }
        });
      }
    } else {
      print("Erro");
      const snackBar = SnackBar(
        content: Text('Servidor não respondeu! Tente novamente!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
