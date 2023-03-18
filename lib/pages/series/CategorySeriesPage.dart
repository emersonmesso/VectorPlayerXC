import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseCategoriesMoviesAPI.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/pages/Home.dart';
import 'package:apptv/pages/channels/WathRecentPage.dart';
import 'package:apptv/pages/series/AllSeries.dart';
import 'package:apptv/pages/series/RecentsSeries.dart';
import 'package:apptv/pages/series/ViewSeriesCategoryPage.dart';
import 'package:apptv/pages/series/favouritesSeries.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategorySeriesPage extends StatefulWidget {
  const CategorySeriesPage({Key? key}) : super(key: key);

  @override
  State<CategorySeriesPage> createState() => _CategorySeriesPageState();
}

class _CategorySeriesPageState extends State<CategorySeriesPage> {
  late bool isLoading;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late List<ResponseCategoriesMoviesAPI> listCategorySeries;

  @override
  void initState() {
    isLoading = true;
    _initDate(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        title: const Text("Séries"),
      ),
      body: (isLoading)
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              color: Theme.of(context).backgroundColor,
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                childAspectRatio: (4 / 1),
                children: List.generate(
                  listCategorySeries.length,
                  (index) {
                    if (listCategorySeries[index].categoryId == "0") {
                      return ItemMove(
                        corBorda: Colors.white,
                        isCategory: true,
                        callback: () {
                          _navigateToPage(listCategorySeries[index].parentId);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                          ),
                          child: Center(
                            child: Text(
                              listCategorySeries[index].categoryName!,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                          if (listCategorySeries[index].categoryId == 1) {
                            //vai para a página de favoritos
                          } else {
                            var category =
                                listCategorySeries[index].categoryId;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewSeriesCategoryPage(
                                  category: category!,
                                  category_name:
                                      listCategorySeries[index].categoryName!,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                          ),
                          child: Center(
                            child: Text(
                              listCategorySeries[index].categoryName!,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
    );
  }

  void _initDate(context) async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    List<ResponseCategoriesMoviesAPI>? response;
    var res = await api_controller.getCategorySeries(responseStorageAPI.url,
        responseStorageAPI.username, responseStorageAPI.password);
    if (res != null) {
      response = res;
      response?.insert(
        0,
        ResponseCategoriesMoviesAPI(
          parentId: 1,
          categoryName: "Assistidos Recentimente",
          categoryId: "0",
        ),
      );
      response?.insert(
        0,
        ResponseCategoriesMoviesAPI(
          parentId: 2,
          categoryName: "Todas as Séries",
          categoryId: "0",
        ),
      );
      response?.insert(
        0,
        ResponseCategoriesMoviesAPI(
          parentId: 3,
          categoryName: "Favoritos",
          categoryId: "0",
        ),
      );
      setState(() {
        isLoading = false;
        listCategorySeries = response!;
      });
    } else {
      //Errror
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

  void _navigateToPage(int? parentId) {
    switch (parentId) {
      case 1:
        //navigate to recentes assistidos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecentsSeries(),
          ),
        );
        break;
      case 2:
        //navigate to todos os canais
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AllSeriesPage(),
          ),
        );
        break;
      case 3:
        //navigate to favoritos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavouritesSeries(),
          ),
        );
        break;
    }
  }
}
