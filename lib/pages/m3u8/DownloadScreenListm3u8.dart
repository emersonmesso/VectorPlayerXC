import 'dart:async';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/pages/ExpirePage.dart';
import 'package:apptv/pages/m3u8/HomeScreenListM3U8.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DownloadScreenListm3u8 extends StatefulWidget {
  const DownloadScreenListm3u8({Key? key}) : super(key: key);

  @override
  State<DownloadScreenListm3u8> createState() => _DownloadScreenListm3u8State();
}

class _DownloadScreenListm3u8State extends State<DownloadScreenListm3u8> {
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late bool downloadingChannels;
  late bool downloadingMovies;
  late bool downloadSeries;
  late int totalChannels = 0;
  late int totalMovies = 0;
  late int totalSeries = 0;
  late String description = "Baixando os canais...";

  @override
  void initState() {
    downloadingChannels = true;
    downloadingMovies = true;
    downloadSeries = true;
    _initData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("lib/assets/logo1.png"),
            const SizedBox(
              height: 35,
            ),
            Text(
              description,
              style: const TextStyle(
                  fontSize: 25.0, color: Colors.white, fontFamily: "Candy"),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    width: (MediaQuery.of(context).size.width * 30) / 100,
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/assets/tv.png",
                          width: 50,
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Image.asset(
                          "lib/assets/aovivo.png",
                          width: 90,
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        (downloadingChannels)
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                "$totalChannels Categorias de Canais",
                                style: const TextStyle(
                                  fontFamily: "Candy",
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    width: (MediaQuery.of(context).size.width * 30) / 100,
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/assets/popcorn.png",
                          width: 50,
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Image.asset(
                          "lib/assets/filme_tab.png",
                          width: 90,
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        (downloadingMovies)
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                "$totalMovies Categorias de Filmes",
                                style: const TextStyle(
                                  fontFamily: "Candy",
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    width: (MediaQuery.of(context).size.width * 30) / 100,
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/assets/movie.png",
                          width: 50,
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Image.asset(
                          "lib/assets/series.png",
                          width: 90,
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        (downloadSeries)
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                "$totalSeries Categorias de Séries",
                                style: const TextStyle(
                                  fontFamily: "Candy",
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initData(BuildContext context) async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    //buscando os canais
    var response =
        await api_controller.getListChannelsFromM3U8(responseStorageAPI.id);
    if (response != null) {
      //salvando os dados
      if (await saveChannelsM3U8(response)) {
        setState(() {
          downloadingChannels = false;
          totalChannels = response.length;
          description = "Baixando os Filmes...";
        });

        var responseMovies =
            await api_controller.getListMoviesFromM3U8(responseStorageAPI.id);
        if (responseMovies != null) {
          //salvando os dados
          if (await saveMoviesM3U8(responseMovies)) {
            setState(() {
              downloadingMovies = false;
              totalMovies = responseMovies.length;
              description = "Baixando as Séries...";
            });

            var responseSeries = await api_controller
                .getListSeriesFromM3U8(responseStorageAPI.id);
            if (responseSeries != null) {
              //salvando os dados
              if (await saveSeriesM3U8(responseSeries)) {
                setState(() {
                  downloadSeries = false;
                  totalSeries = responseSeries.length;
                  description = "Aguarde...";
                });

                //baixando EPG
                var url = getURLFromString(responseStorageAPI.url!);
                Fluttertoast.showToast(
                  msg: "Atualizando Guia de Canais...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM_RIGHT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                print(url);
                var responseEPG = await api_controller.downloadEPG(
                    "$url/",
                    responseStorageAPI.username,
                    responseStorageAPI.password);
                if (responseEPG != null) {
                  Fluttertoast.showToast(
                    msg: "Guia Atualizada!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM_RIGHT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreenListM3U8(),
                      ),
                      (Route<dynamic> route) => false);
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreenListM3U8(),
                      ),
                      (Route<dynamic> route) => false);
                }
              } else {
                //envia para página de erro
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const ExpirePage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            } else {
              //envia para página de erro
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const ExpirePage(),
                ),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            //envia para página de erro
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const ExpirePage(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          //envia para página de erro
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ExpirePage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        //envia para página de erro
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ExpirePage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      //envia para página de erro
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ExpirePage(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
