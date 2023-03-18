import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/Serie/ListSeason.dart';
import 'package:apptv/pages/series/EpisodeSeason.dart';
import 'package:flutter/material.dart';

class ItemSeason extends StatelessWidget {
  const ItemSeason({Key? key, required this.season, required this.serie})
      : super(key: key);
  final ListSeason season;
  final ResponseCategorySeries serie;

  @override
  Widget build(BuildContext context) {
    return ItemMove(
      corBorda: Colors.white,
      isCategory: true,
      callback: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpisodeSeason(
              serie: serie,
              episodes: season.episodes,
              title: season.season!.seasonNumber.toString(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 5.0),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
        ),
        child: Text(
          "${season.season!.seasonNumber.toString()} Temporada",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontFamily: "Candy",
          ),
        ),
      ),
    );
  }
}
