import 'dart:convert';
import 'package:apptv/ad_helper.dart';
import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/components/itemEpisodeSerie.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/controller/seriesDAO/SeriesDAO.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/models/Serie/ListSeason.dart';
import 'package:apptv/models/Serie/ResponseSerieInfoAll.dart';
import 'package:apptv/models/Serie/SerieWatching.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'SeasonsSerieDetail.dart';

class SeriesDetailPage extends StatefulWidget {
  const SeriesDetailPage({Key? key, required this.serie}) : super(key: key);
  final ResponseCategorySeries serie;

  @override
  State<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends State<SeriesDetailPage> {
  late bool isLoading;
  late bool isFavourite;
  late bool isTV;
  late ResponseCategorySeries serie;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late ResponseInfoSerieAll serieInfo;
  late int indexTemporada;
  SeriesDAO seriesDAO = SeriesDAO();

  //test
  late GlobalKey _dropdownButtonKey;

  @override
  void initState() {
    serie = widget.serie;
    isLoading = true;
    isFavourite = false;
    isTV = false;
    indexTemporada = 0;
    _dropdownButtonKey = GlobalKey();
    _initData(context);
    super.initState();
  }

  //admob
  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  //ADMOB
  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
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
                color: Theme.of(context).backgroundColor,
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
                              serie.cover!,
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
                                (!isFavourite)
                                    ? ItemMove(
                                      corBorda: Colors.white,
                                      isCategory: true,
                                      callback: _saveFavorite,
                                      child: const Icon(
                                        Icons.favorite_border_outlined,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                    )
                                    : ItemMove(
                                      corBorda: Colors.white,
                                      isCategory: true,
                                      callback: _removeFavorite,
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
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView(
                          children: [
                            ItemMove(
                              corBorda: Colors.white,
                              isCategory: true,
                              callback: () {},
                              child: Text(
                                serie.name!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Candy",
                                  fontSize: 26,
                                ),
                              ),
                            ),
                            (serie.director != "")
                                ? Row(
                                    children: [
                                      const Text(
                                        "Diretor: ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "Candy",
                                        ),
                                      ),
                                      Text(
                                        serie.director ?? "Não Disponível",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontFamily: "Candy",
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            (serie.genre != "")
                                ? Row(
                                    children: [
                                      const Text(
                                        "Gênero: ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "Candy",
                                        ),
                                      ),
                                      Text(
                                        serie.genre ?? "Não disponível",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontFamily: "Candy",
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            (serie.releaseDate != "")
                                ? Row(
                                    children: [
                                      const Text(
                                        "Data de Lançamento: ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "Candy",
                                        ),
                                      ),
                                      Text(
                                        convertData(serie.releaseDate ?? null),
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontFamily: "Candy",
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            RatingBar.builder(
                              initialRating:
                                  convertRating(double.parse(serie.rating!)),
                              minRating: 1,
                              maxRating: 5,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 20,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Text(
                              serie.plot!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: "Candy",
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),

                            (serieInfo != null)
                                ? Visibility(
                                    visible: !isTV,
                                    child: ItemMove(
                                      corBorda: Colors.red,
                                      isCategory: true,
                                      callback: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SeasonsSerieDetail(
                                              title: serie.name!,
                                              serie: serieInfo,
                                              serieInfo: serie,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: const Text(
                                          "Temporadas",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 25,
                                            fontFamily: "Candy",
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),

                            //Temporadas
                            (serieInfo != null)
                                ? Visibility(
                                    visible: isTV,
                                    child: ItemMove(
                                      corBorda: Colors.white,
                                      isCategory: true,
                                      callback: () {
                                        print("Ok");
                                        _dropdownButtonKey.currentState
                                            ?.activate();
                                      },
                                      child: DropdownButton<ListSeason>(
                                        key: _dropdownButtonKey,
                                        isExpanded: true,
                                        items: serieInfo.episodes
                                            ?.map((ListSeason item) {
                                          return DropdownMenuItem<ListSeason>(
                                            value: item,
                                            child: ItemMove(
                                              corBorda: Colors.white,
                                              isCategory: true,
                                              callback: () {},
                                              child: SizedBox(
                                                height: 60,
                                                child: Center(
                                                  child: Text(
                                                    "Temporada ${item.season?.seasonNumber}",
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontFamily: "Candy",
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        elevation: 2,
                                        focusColor: Colors.red,
                                        onChanged: (ListSeason? item) {
                                          setSelectedSeason(item);
                                        },
                                        value:
                                            serieInfo.episodes![indexTemporada],
                                      ),
                                    ),
                                  )
                                : Container(),
                            Container(
                              child: (_bannerAd != null)
                                  ? SizedBox(
                                      width: _bannerAd!.size.width.toDouble(),
                                      height: _bannerAd!.size.height.toDouble(),
                                      child: AdWidget(ad: _bannerAd!),
                                    )
                                  : Container(),
                            ),
                            (serieInfo != null)
                                ? Visibility(
                                    visible: isTV,
                                    child: SizedBox(
                                      height: (130 *
                                              serieInfo
                                                  .episodes![indexTemporada]
                                                  .episodes!
                                                  .length)
                                          .toDouble(),
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: serieInfo
                                            .episodes![indexTemporada]
                                            .episodes
                                            ?.length,
                                        itemBuilder: (context, index) {
                                          return ItemEpisodeSerie(
                                            serie: serie,
                                            episode: serieInfo
                                                .episodes![indexTemporada]
                                                .episodes![index],
                                          );
                                        },
                                      ),
                                    ),
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

  void _initData(context) async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    if(isMobile()){
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

    //GET INFO FROM SERIE
    ResponseInfoSerieAll? res;
    var response = await api_controller.getInfoFromSerie(
        responseStorageAPI.url,
        responseStorageAPI.username,
        responseStorageAPI.password,
        serie.seriesId);
    if (response != null) {
      setState(() {
        isLoading = false;
        serieInfo = response!;
      });
    } else {
      Navigator.pop(context);
    }

    //Verificando se é favorito
    var isResponseFavourite =
        await seriesDAO.IsFavourite(serie, responseStorageAPI.url);
    setState(() {
      if (isResponseFavourite) {
        isFavourite = true;
      }
    });

    //verificando se esta salvo na lista de assistidos
    var box = await Hive.openBox("boxSaveWatch");
    //buscando a lista salva
    var listaSalva = await box.get("listWatch");
    if (listaSalva != null) {
      //tem lista salva
      //pegando a lista
      var dados = jsonDecode(listaSalva) as List;
      List<SerieWatching>? lista =
      dados.map((e) => SerieWatching.fromJson(e)).toList();
      print("Total na lista de assistidos: ${lista.length}");
    }else{
      print("Não tem nada salvo!");
    }
  }

  String convertData(data) {
    if (data != null) {
      DateTime time = DateTime.parse(data);
      return DateFormat("dd/MM/yyyy").format(time);
    } else {
      return "Não Disponível";
    }
  }

  double convertRating(double parse) {
    if (parse != 0) {
      var porcent1 = parse * 10;
      //
      double result = (5 * porcent1) / 100;
      return result;
    }
    return 0;
  }

  void setSelectedSeason(ListSeason? item) {
    //buscar o index da temporada
    var index = serieInfo.episodes!.indexWhere((element) =>
        (element.season!.seasonNumber == item?.season!.seasonNumber));
    if (index != -1) {
      setState(() {
        indexTemporada = index;
      });
    }
  }

  void _saveFavorite() async {
    if (await seriesDAO.saveFavorite(serie, responseStorageAPI.url)) {
      setState(() {
        isFavourite = true;
      });
    }
  }

  void _removeFavorite() async {
    if (await seriesDAO.removeFavourite(serie, responseStorageAPI.url)) {
      setState(() {
        isFavourite = false;
      });
    }
  }

  void _actionSaveRecentes() async {
    await seriesDAO.saveRecentSerie(serie, responseStorageAPI.url);
  }
}
