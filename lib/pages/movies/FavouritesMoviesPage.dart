import 'package:apptv/components/ItemMovie.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseMoviesCategory.dart';
import 'package:apptv/pages/movies/MovieDetails.dart';
import 'package:flutter/material.dart';

import '../../controller/HttpController.dart';
import '../../models/ResponseStorageAPI.dart';
class FavouritesMoviesPage extends StatefulWidget {
  const FavouritesMoviesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesMoviesPage> createState() => _FavouritesMoviesPageState();
}

class _FavouritesMoviesPageState extends State<FavouritesMoviesPage> {
  late bool isLoading;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  List<ResponseMoviesCategory>? listMovies;


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
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        title: const Text("Filmes Favoritos"),
      ),
      body: (isLoading) ?
      Container(
        color: Theme.of(context).backgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ): Container(
        color: Theme.of(context).backgroundColor,
        child: GridView.count(
          childAspectRatio: (3 / 4),
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          crossAxisCount: 5,
          children: List.generate(listMovies!.length, (index) {
            return ItemMovie(
              movie: listMovies![index],
            );
          }),
        ),
      ),
    );
  }

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    var response = await getListFavouritesMovies(responseStorageAPI.url);
    if(response != null){
      setState(() {
        listMovies = response;
        isLoading = false;
      });
    }
  }
}
