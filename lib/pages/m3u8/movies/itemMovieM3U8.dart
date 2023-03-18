import 'package:flutter/material.dart';
import '../../../models/ListM3U8/ResponseListM3U8Channel.dart';
class ItemMovieM3U8 extends StatelessWidget {
  const ItemMovieM3U8({Key? key, required this.movie}) : super(key: key);
  final ListChannels movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          (movie.logo != null)
              ? SizedBox(
            width: 150,
            height: 150,
            child: Image.network(
              movie.logo!,
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
          )
              : SizedBox(
            width: 150,
            height: 150,
            child: Image.asset(
              "lib/assets/logo.png",
              fit: BoxFit.contain,
              width: 40,
              height: 40,
            ),
          ),
          Center(
            child: Text(
              movie.title!,
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
    );
  }
}
