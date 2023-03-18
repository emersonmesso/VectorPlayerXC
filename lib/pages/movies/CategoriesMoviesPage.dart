import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../components/ItemMove.dart';
import '../../controller/HttpController.dart';
import '../../controller/functions.dart';
import '../../models/ResponseCategoriesMoviesAPI.dart';
import '../../models/ResponseMoviesCategory.dart';
import '../../models/ResponseStorageAPI.dart';
import 'AllMoviesPage.dart';
import 'FavouritesMoviesPage.dart';
import 'MoviesCategoriePage.dart';

class CategoriesMoviesPage extends StatefulWidget {
  const CategoriesMoviesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesMoviesPage> createState() => _CategoriesMoviesPageState();
}

class _CategoriesMoviesPageState extends State<CategoriesMoviesPage> {
  late bool isLoading;
  late List<ResponseCategoriesMoviesAPI> listCategories;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late List<ResponseMoviesCategory> listMovies;

  @override
  void initState() {
    isLoading = true;
    _initData();
    super.initState();
  }

  void _navigateToPage(int? parentId) {
    switch (parentId) {
      case 1:
        //navigate to all movies
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AllMoviesPage(),
          ),
        );
        break;
      case 2:
        //navigate to recentes playing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavouritesMoviesPage(),
          ),
        );
        break;
      case 3:
        //navigate to favoritos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavouritesMoviesPage(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filmes"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: (4 / 1),
              children: List.generate(listCategories.length, (index) {
                if (listCategories[index].categoryId == "0") {
                  return ItemMove(
                    corBorda: Colors.white,
                    isCategory: true,
                    callback: () {
                      _navigateToPage(listCategories[index].parentId);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                      ),
                      child: Center(
                        child: Text(
                          listCategories[index].categoryName!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return ItemMove(
                    corBorda: Colors.white,
                    isCategory: true,
                    callback: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoviesCategoyPage(
                            data: listCategories[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                      ),
                      child: Center(
                        child: Text(
                          listCategories[index].categoryName!,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
            ),
    );
  }

  void _initData() async {
    //buscando os dados do servidor ativo
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    List<ResponseCategoriesMoviesAPI>? lista = <ResponseCategoriesMoviesAPI>[];

    var response = await api_controller.getAllCategoriesMovies(
        responseStorageAPI.url,
        responseStorageAPI.username,
        responseStorageAPI.password);

    if (response != null) {
      List<ResponseCategoriesMoviesAPI>? lista = response;
      lista?.insert(
          0,
          ResponseCategoriesMoviesAPI(
            parentId: 1,
            categoryName: "Todos os Filmes",
            categoryId: "0",
          ));
      lista?.insert(
          0,
          ResponseCategoriesMoviesAPI(
            parentId: 2,
            categoryName: "Assistidos Recentimente",
            categoryId: "0",
          ));
      lista?.insert(
          0,
          ResponseCategoriesMoviesAPI(
            parentId: 3,
            categoryName: "Favoritos",
            categoryId: "0",
          ));
      setState(() {
        listCategories = lista!;
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Não encontramos os filmes!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    }
  }
}
