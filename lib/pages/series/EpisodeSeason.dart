import 'package:apptv/components/itemEpisodeSerie.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/controller/seriesDAO/SeriesDAO.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/models/Serie/ResponseInfoSerieEpisode.dart';
import 'package:apptv/pages/series/PLayerEpisodeSerie.dart';
import 'package:flutter/material.dart';

import '../../components/ItemMove.dart';

class EpisodeSeason extends StatefulWidget {
  const EpisodeSeason(
      {Key? key, this.episodes, required this.title, required this.serie})
      : super(key: key);
  final List<ResponseInfoSerieEpisode>? episodes;
  final String title;
  final ResponseCategorySeries serie;

  @override
  State<EpisodeSeason> createState() => _EpisodeSeasonState();
}

class _EpisodeSeasonState extends State<EpisodeSeason> {
  late List<ResponseInfoSerieEpisode>? episodios;
  late ResponseStorageAPI responseStorageAPI;
  SeriesDAO seriesDAO = SeriesDAO();
  late bool isLoading;

  @override
  void initState() {
    episodios = widget.episodes;
    isLoading = true;
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text("${widget.title} Temporada"),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(
          itemCount: episodios!.length,
          itemBuilder: (context, index) {
            return ItemMove(
              callback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerEpidode(
                      serie: widget.serie,
                      episode: episodios![index],
                    ),
                  ),
                );
              },
              isCategory: true,
              corBorda: Colors.white,
              child: ItemEpisodeSerie(
                serie: widget.serie,
                episode: episodios![index],
              ),
            );
          },
        ),
      ),
    );
  }

  void _actionSaveRecent() async {
    await seriesDAO.saveRecentSerie(widget.serie, responseStorageAPI.url);
  }

  void initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
  }
}
