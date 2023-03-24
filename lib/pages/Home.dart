import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';
import '../components/ItemMove.dart';
import '../controller/HomeController.dart';
import '../controller/HttpController.dart';
import '../controller/functions.dart';
import '../models/ResponseActiveAPI.dart';
import '../models/ResponseStorageAPI.dart';
import '../models/SettingsData.dart';
import 'ChangeServerPage.dart';
import 'ExpirePage.dart';
import 'PlayerVideoOld.dart';
import 'SettingsPage.dart';
import 'channels/ChannelsPage.dart';
import 'm3u8/DownloadScreenListm3u8.dart';
import 'm3u8/HomeScreenListM3U8.dart';
import 'movies/CategoriesMoviesPage.dart';
import 'series/CategorySeriesPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double fullwidth;
  late double fullHeigth;
  late bool isLoading;
  late bool isDownloading;
  late ResponseStorageAPI responseStorageAPI;
  late Timer time;
  late String hour = "";
  HTTpController api_controller = HTTpController();
  late SettingsData settings;

  //admob
  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  /*FUNCTIONS*/
  String getSystemTimeHour() {
    var now = DateTime.now();
    return DateFormat("H:m:s  a").format(now);
  }

  void getSystemTime() {
    var now = DateTime.now();
    setState(() {
      hour =
          "${DateFormat("d MMM").format(now)}, ${DateFormat("y").format(now)}";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    isDownloading = true;
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      getSystemTime();
    });
    getInfo();
    super.initState();
  }

  void getInfo() async {
    //admob
    if (isMobile()) {
      // TODO: Load a banner ad
      MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
          testDeviceIds: ['8F4DE589F88E8FFBB2FC2F8019412BA2','1578B051D9D9D896FA420A580DE625F4']));
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

    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;

    //verifica se o servidor é Xtream Codes ou Lista M3U8
    if (responseStorageAPI.list_type == 0) {
      //
      ResponseActiveApi response = await api_controller.verifyAccountIPTV(
          responseStorageAPI.url,
          responseStorageAPI.username,
          responseStorageAPI.password);
      if (response.userInfo?.status != "error") {
        if (response.userInfo!.status!.contains("Active")) {
          setState(() {
            isLoading = false;
          });
          //verifica se é para baixar o EPG
          if (await enableDownloadEPG()) {
            //baixando o EPG

            /*
            var res = await api_controller.downloadEPG(responseStorageAPI.url,
                responseStorageAPI.username, responseStorageAPI.password);
            */
            var res;
            if (isWeb()) {
              res = await api_controller.getEPG(responseStorageAPI.url,
                  responseStorageAPI.username, responseStorageAPI.password);
            } else {
              res = await api_controller.downloadEPG(responseStorageAPI.url,
                  responseStorageAPI.username, responseStorageAPI.password);
            }
            if (res!) {
              setState(() {
                isDownloading = false;
              });
            } else {
              setState(() {
                isDownloading = false;
              });
            }
          } else {
            setState(() {
              isDownloading = false;
            });
          }
        } else {
          Get.off(const ExpirePage());
        }
      } else {
        Get.off(const ExpirePage());
      }
    } else {
      //verifica se já tem salvo os dados
      if (await verifySaveListM3U8()) {
        Get.off(const HomeScreenListM3U8());

      } else {
        Get.off(const DownloadScreenListm3u8());
      }
    }
  }

  /*FUNCTIONS*/
  @override
  Widget build(BuildContext context) {
    fullwidth = MediaQuery.of(context).size.width;
    fullHeigth = MediaQuery.of(context).size.height;
    final controller = Get.put(HomeController());
    return Scaffold(
      body: isLoading
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: const EdgeInsets.only(
                  top: 50.0, left: 40.0, right: 40.0, bottom: 40.0),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Row(
                          children: [
                            Image.asset(
                              "lib/assets/logo1.png",
                              width: 150,
                            ),
                            Container(
                              width: 1,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    getSystemTimeHour(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: "Candy",
                                    ),
                                  ),
                                  Text(
                                    hour,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: "Candy",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: ItemMove(
                          corBorda: Colors.white,
                          isCategory: true,
                          callback: () {
                            Get.to(const SettingsPage());
                          },
                          child: const Icon(
                            Icons.settings,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      (isDownloading)
                          ? Row(
                              children: const [
                                SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  "Baixando grade...",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        width: 250,
                        height: 70,
                        child: ItemMove(
                          corBorda: Colors.white,
                          isCategory: false,
                          callback: () {
                            Get.to(const ChangeServerPage());
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.change_circle_outlined,
                                size: 40.0,
                                color: Colors.red,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (responseStorageAPI != null)
                                      ? Text(
                                          "Servidor: ${responseStorageAPI.name}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontFamily: "Candy",
                                          ),
                                        )
                                      : Container(),
                                  const Text(
                                    "Alterar Servidor",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: "Candy",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ItemMove(
                          corBorda: Colors.white,
                          isCategory: false,
                          callback: () {
                            if (settings.openOldPeople!) {
                              Get.to(const PlayerVideoOld());
                            } else {
                              Get.to(const ChannelsPage());
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Theme.of(context).accentColor,
                            ),
                            width: (fullwidth * 25) / 100,
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
                              ],
                            ),
                          ),
                        ),
                        ItemMove(
                          corBorda: Colors.white,
                          isCategory: false,
                          callback: () {
                            Get.to(const CategoriesMoviesPage());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Theme.of(context).accentColor,
                            ),
                            width: (fullwidth * 25) / 100,
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
                              ],
                            ),
                          ),
                        ),
                        ItemMove(
                          corBorda: Colors.white,
                          isCategory: false,
                          callback: () {
                            Get.to(const CategorySeriesPage());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Theme.of(context).accentColor,
                            ),
                            width: (fullwidth * 25) / 100,
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
                              ],
                            ),
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
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    time.cancel();
    super.dispose();
  }
}
