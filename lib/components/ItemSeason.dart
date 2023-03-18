import 'package:flutter/material.dart';

import '../models/ResponseCategorySeries.dart';
import '../models/Serie/ListSeason.dart';
import '../pages/series/EpisodeSeason.dart';
import 'ItemMove.dart';

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
