import 'package:flutter/material.dart';

import '../../components/ItemSeason.dart';
import '../../models/ResponseCategorySeries.dart';
import '../../models/Serie/ResponseSerieInfoAll.dart';
class SeasonsSerieDetail extends StatefulWidget {
  const SeasonsSerieDetail({Key? key, required this.serie, required this.title, required this.serieInfo}) : super(key: key);
  final ResponseInfoSerieAll serie;
  final String title;
  final ResponseCategorySeries serieInfo;

  @override
  State<SeasonsSerieDetail> createState() => _SeasonsSerieDetailState();
}

class _SeasonsSerieDetailState extends State<SeasonsSerieDetail> {
  late ResponseInfoSerieAll serie;

  @override
  void initState() {
    serie = widget.serie;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Temporadas - ${widget.title}"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(
          itemCount: serie.episodes!.length,
            itemBuilder: (context, index){
          return ItemSeason(
            serie: widget.serieInfo,
            season: serie.episodes![index],
          );
        }),
      ),
    );
  }
}
