import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../components/ItemMove.dart';
import '../../controller/HttpController.dart';
import '../../controller/functions.dart';
import '../../models/ResponseChannelsAPI.dart';
import '../../models/ResponseStorageAPI.dart';
import '../../models/SettingsData.dart';
import 'AllChannelsPage.dart';
import 'ChannelPage.dart';
import 'FavouritesChannels.dart';
import 'WathRecentPage.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({Key? key}) : super(key: key);

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  late bool isLoading;
  late List<ResponseChannelsAPI> listCategories;
  HTTpController api_controller = HTTpController();
  late SettingsData settings;
  //example
  late ResponseStorageAPI responseStorageAPI;

  @override
  void initState() {
    isLoading = true;
    getChannels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Canais Ao Vivo"),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: isLoading
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
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
                    if (listCategories[index].categoryId == "0") {
                      return GestureDetector(
                        onTap: () {
                          _navigateToPage(listCategories[index].parentId);
                        },
                        child: ItemMove(
                          corBorda: Colors.white,
                          callback: () {
                            _navigateToPage(listCategories[index].parentId);
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
                                listCategories[index].categoryName!,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          if (listCategories[index].categoryId == 1) {
                            //vai para a página de favoritos
                          } else {
                            var category = listCategories[index].categoryId;
                            var categoryname =
                                listCategories[index].categoryName;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChannelPage(
                                  categoryId: category!,
                                  categoryName: categoryname!,
                                ),
                              ),
                            );
                          }
                        },
                        child: ItemMove(
                          corBorda: Colors.white,
                          callback: () {
                            var category = listCategories[index].categoryId;
                            var categoryname =
                                listCategories[index].categoryName;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChannelPage(
                                  categoryId: category!,
                                  categoryName: categoryname!,
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
                                listCategories[index].categoryName!,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
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

  void getChannels() async {
    print("INICIANDO...");
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;

    var response = await api_controller.getAllCategoryChannels(
      responseStorageAPI.url,
      responseStorageAPI.username,
      responseStorageAPI.password,
    );
    if (response != null) {
      if (settings.showRecentsWhatshing!) {
        response?.insert(
          0,
          ResponseChannelsAPI(
            parentId: 1,
            categoryName: "Assistidos Recentimente",
            categoryId: "0",
          ),
        );
      }

      response?.insert(
        0,
        ResponseChannelsAPI(
          parentId: 2,
          categoryName: "Todos os Canais",
          categoryId: "0",
        ),
      );
      response?.insert(
        0,
        ResponseChannelsAPI(
          parentId: 3,
          categoryName: "Favoritos",
          categoryId: "0",
        ),
      );
      setState(() {
        listCategories = response!;
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Sem Categorias!",
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
            builder: (context) => const WathRecentPage(),
          ),
        );
        break;
      case 2:
        //navigate to todos os canais
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AllChannelsPage(),
          ),
        );
        break;
      case 3:
        //navigate to favoritos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavouritesChannelPage(),
          ),
        );
        break;
    }
  }
}
