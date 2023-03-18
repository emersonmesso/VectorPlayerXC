import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import '../../ad_helper.dart';
import '../../components/ItemMove.dart';
import '../../controller/HttpController.dart';
import '../../controller/functions.dart';
import '../../models/ResponseStorageAPI.dart';
import '../ChangeServerPage.dart';
import '../SettingsPage.dart';
import '../series/CategorySeriesPage.dart';
import 'channels/categoryChannels.dart';
import 'movies/categoryMovies.dart';

class HomeScreenListM3U8 extends StatefulWidget {
  const HomeScreenListM3U8({Key? key}) : super(key: key);

  @override
  State<HomeScreenListM3U8> createState() => _HomeScreenListM3U8State();
}

class _HomeScreenListM3U8State extends State<HomeScreenListM3U8> {
  late double fullwidth;
  late double fullHeigth;
  late bool isLoading;
  late bool isDownloading;
  late Timer time;
  late String hour = "";
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  //admob
  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  @override
  void initState() {
    isLoading = true;
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      getSystemTime();
    });
    _initData(context);
    super.initState();
  }

  @override
  void dispose() {
    time.cancel();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    fullwidth = MediaQuery.of(context).size.width;
    fullHeigth = MediaQuery.of(context).size.height;
    return Scaffold(
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.settings,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        height: 70,
                        child: ItemMove(
                          corBorda: Colors.white,
                          isCategory: false,
                          callback: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangeServerPage(),
                              ),
                            );
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const categoryChannelsScreen(),
                              ),
                            );
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CategoryMoviesPage(),
                              ),
                            );
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CategorySeriesPage(),
                              ),
                            );
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

  void _initData(BuildContext context) async {
    //admob
    if (isMobile()) {
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

    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    setState(() {
      isLoading = false;
    });
  }
}
