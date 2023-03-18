import 'package:apptv/components/ItemSerie.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/controller/seriesDAO/SeriesDAO.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/pages/Home.dart';
import 'package:flutter/material.dart';

class RecentsSeries extends StatefulWidget {
  const RecentsSeries({Key? key}) : super(key: key);

  @override
  State<RecentsSeries> createState() => _RecentsSeriesState();
}

class _RecentsSeriesState extends State<RecentsSeries> {
  late bool isLoading;
  late List<ResponseCategorySeries> listRecents;
  late ResponseStorageAPI responseStorageAPI;
  late SeriesDAO seriesDAO = SeriesDAO();
  HTTpController api_controller = HTTpController();

  @override
  void initState() {
    isLoading = true;
    _initDate(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        title: const Text("Séries Recentes"),
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
                  listRecents.length,
                  (index) {
                    return ItemSerie(
                      serie: listRecents[index],
                    );
                  },
                ),
              ),
            ),
    );
  }

  void _initDate(context) async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    var response = await seriesDAO.getListRecentWath(responseStorageAPI.url);

    if (response != null) {
      setState(() {
        isLoading = false;
        listRecents = response;
      });
    } else {
      const snackBar = SnackBar(
        content: Text('Servidor não respondeu! Tente novamente!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }
}
