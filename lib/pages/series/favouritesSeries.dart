import 'package:flutter/material.dart';

import '../../components/ItemSerie.dart';
import '../../controller/HttpController.dart';
import '../../controller/functions.dart';
import '../../controller/seriesDAO/SeriesDAO.dart';
import '../../models/ResponseCategorySeries.dart';
import '../../models/ResponseStorageAPI.dart';

class FavouritesSeries extends StatefulWidget {
  const FavouritesSeries({Key? key}) : super(key: key);

  @override
  State<FavouritesSeries> createState() => _FavouritesSeriesState();
}

class _FavouritesSeriesState extends State<FavouritesSeries> {
  late bool isLoading;
  late List<ResponseCategorySeries> listaFavourites;
  SeriesDAO seriesDAO = SeriesDAO();
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();

  @override
  void initState() {
    isLoading = true;
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: const Text("Séries Favoritas"),
        elevation: 0,
      ),
      body: (isLoading)
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              color: Theme.of(context).backgroundColor,
              child: GridView.count(
                childAspectRatio: (3 / 4),
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                crossAxisCount: 5,
                children: List.generate(
                  listaFavourites.length,
                  (index) {
                    return ItemSerie(
                      serie: listaFavourites[index],
                    );
                  },
                ),
              ),
            ),
    );
  }

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    var response = await seriesDAO.getListFavouritesSeries(responseStorageAPI.url);
    print("LISTA SALVA: " + response.toString());
    setState(() {
      listaFavourites = response!;
      isLoading = false;
    });
  }
}
