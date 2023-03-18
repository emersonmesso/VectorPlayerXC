import 'package:flutter/material.dart';

import '../../../components/ItemMove.dart';
import '../../../models/ListM3U8/ResponseListM3U8Channel.dart';
import 'MoviesDetailM3U8.dart';
import 'itemMovieM3U8.dart';

class moviesFromCategory extends StatelessWidget {
  const moviesFromCategory({Key? key, required this.listMovies, required this.title})
      : super(key: key);
  final List<ListChannels> listMovies;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(title),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: GridView.count(
          childAspectRatio: (3 / 4),
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          crossAxisCount: 5,
          children: List.generate(listMovies.length, (index) {
            return ItemMove(
              corBorda: Colors.white,
              callback: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoviesDetailM3U8(
                      movie: listMovies[index],
                    ),
                  ),
                );
              },
              isCategory: true,
              child: ItemMovieM3U8(
                movie: listMovies[index],
              ),
            );
          }),
        ),
      ),
    );
  }
}
