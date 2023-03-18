import 'package:flutter/material.dart';

import '../models/ResponseCategorySeries.dart';
import '../pages/series/SeriesDetail.dart';
import 'ItemMove.dart';

class ItemSerie extends StatefulWidget {
  const ItemSerie({Key? key, required this.serie}) : super(key: key);
  final ResponseCategorySeries serie;

  @override
  State<ItemSerie> createState() => _ItemSerieState();
}

class _ItemSerieState extends State<ItemSerie> {
  late ResponseCategorySeries serie;

  @override
  void initState() {
    serie = widget.serie;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeriesDetailPage(
              serie: serie!,
            ),
          ),
        );
      },
      child: ItemMove(
        corBorda: Colors.white,
        isCategory: true,
        callback: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeriesDetailPage(
                serie: serie!,
              ),
            ),
          );
        },
        child: Container(
          width: 150.0,
          height: 300.0,
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Image.network(
                  serie.cover!,
                  fit: BoxFit.contain,
                  width: 40,
                  height: 40,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
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
                child: Text(
                  serie.name!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
