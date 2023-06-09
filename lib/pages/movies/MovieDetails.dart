import 'package:apptv/pages/VideoPlayerMP4.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';
import '../../components/ItemMove.dart';
import '../../controller/HttpController.dart';
import '../../controller/functions.dart';
import '../../models/ResponseAPITMDB.dart';
import '../../models/ResponseMoviesCategory.dart';
import '../../models/ResponseStorageAPI.dart';
import '../../models/SettingsData.dart';

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
                                  "http://image.tmdb.org/t/p/original${dadosAPITMDB.backdropPath}")
                              : const NetworkImage(
                                  "http://vectorplayer.com/_core/_img/back-clean.png"),
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
                                ItemMove(
                                  corBorda: Colors.white,
                                  isCategory: true,
                                  callback: () {
                                    Get.to(
                                      () => VideoPlayerMP4(
                                        id: movie.streamId!.toString(),
                                        title: movie.name!,
                                        type: true,
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.play_circle_fill_outlined,
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
      if (myString!.contains(")")) {
        final splitted = myString?.split('(');
        var aStr = splitted![1].replaceAll(RegExp(r'[^0-9]'), '');
        var ano = "";
        if (aStr != null && aStr != "") {
          ano = aStr;
        }
        print("Ano do Filme: " + aStr);
        var response =
            await api_controller.getInfoMovieFromTMDB(splitted?[0], ano);
        print(response.toString());
        if (response != null) {
          if (response.id != 0) {
            setState(() {
              dadosAPITMDB = response;
              isLoading = false;
            });
          } else {
            //não tem dados
            setState(() {
              isLoading = false;
            });
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
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
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
}
