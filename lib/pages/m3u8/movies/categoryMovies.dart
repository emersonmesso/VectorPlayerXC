import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/controller/M3U8/m3u8DAO.dart';
import 'package:apptv/models/ListM3U8/ResponseListM3U8Channel.dart';
import 'package:apptv/pages/m3u8/channels/listChannels.dart';
import 'package:apptv/pages/m3u8/movies/moviesFromCategory.dart';
import 'package:flutter/material.dart';

class CategoryMoviesPage extends StatefulWidget {
  const CategoryMoviesPage({Key? key}) : super(key: key);

  @override
  State<CategoryMoviesPage> createState() => _CategoryMoviesPageState();
}

class _CategoryMoviesPageState extends State<CategoryMoviesPage> {
  late List<ResponseListM3U8Channel> listCategories =
      <ResponseListM3U8Channel>[];
  late M3U8DAO m3u8dao = M3U8DAO();

  @override
  void initState() {
    initData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Filmes"),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          childAspectRatio: (4 / 1),
          children: List.generate(
            listCategories.length,
            (index) {
              return ItemMove(
                corBorda: Colors.white,
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => moviesFromCategory(
                        title: listCategories[index].title!,
                        listMovies: listCategories[index].list!,
                      ),
                    ),
                  );
                },
                isCategory: true,
                child: Container(
                  alignment: Alignment.center,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                  ),
                  child: Center(
                    child: Text(
                      listCategories[index].title!,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void initData(BuildContext context) async {
    //buscando os canais
    var response = await m3u8dao.getMovies();
    if (response != null) {
      setState(() {
        listCategories = response;
      });
    }
  }
}
