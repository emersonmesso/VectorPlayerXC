import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/components/ItemMovie.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseCategoriesMoviesAPI.dart';
import 'package:apptv/models/ResponseMoviesCategory.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../controller/HttpController.dart';

class MoviesCategoyPage extends StatefulWidget {
  const MoviesCategoyPage({Key? key, required this.data}) : super(key: key);
  final ResponseCategoriesMoviesAPI data;
  @override
  State<MoviesCategoyPage> createState() => _MoviesCategoyPageState();
}

class _MoviesCategoyPageState extends State<MoviesCategoyPage> {
  late bool isLoading;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late ResponseCategoriesMoviesAPI dados;
  late List<ResponseMoviesCategory> listMovies;
  late List<ResponseMoviesCategory> listMoviesSearch =
      <ResponseMoviesCategory>[];
  late bool _searchBoolean = false;

  @override
  void initState() {
    isLoading = true;
    dados = widget.data;
    _initData(dados.categoryId);
    super.initState();
  }

  Widget _searchTextField() {
    //add
    return TextField(
      autofocus: true, //Display the keyboard when TextField is displayed
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction:
          TextInputAction.search, //Specify the action button on the keyboard
      decoration: const InputDecoration(
        //Style of TextField
        enabledBorder: UnderlineInputBorder(
          //Default TextField border
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          //Borders when a TextField is in focus
          borderSide: BorderSide(color: Colors.white),
        ),
        hintText: 'Buscar', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle(
          //Style of hintText
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
      onSubmitted: (String s) {
        _updateSearch(s);
      },
      textCapitalization: TextCapitalization.none,
      onChanged: (String s) {
        //add
        _updateSearch(s);
      },
    );
  }

  Widget _searchListView() {
    return GridView.count(
      childAspectRatio: (3 / 4),
      crossAxisSpacing: 3,
      mainAxisSpacing: 3,
      crossAxisCount: 5,
      children: List.generate(
        listMoviesSearch.length,
        (index) {
          return ItemMovie(movie: listMoviesSearch[index]);
        },
      ),
    );
  }

  Widget _defaultListView() {
    return GridView.count(
      childAspectRatio: (3 / 4),
      crossAxisSpacing: 3,
      mainAxisSpacing: 3,
      crossAxisCount: 5,
      children: List.generate(
        listMovies.length,
        (index) {
          return ItemMovie(movie: listMovies[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).backgroundColor,
          title:
              !_searchBoolean ? Text(dados.categoryName!) : _searchTextField(),
          automaticallyImplyLeading: false,
          actions: !_searchBoolean
              ? [
                  ItemMove(
                    corBorda: Colors.white,
                    isCategory: true,
                    callback: () {
                      setState(() {
                        _searchBoolean = true;
                        listMoviesSearch.clear();
                      });
                    },
                    child: IconButton(
                      mouseCursor: SystemMouseCursors.click,
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _searchBoolean = true;
                          listMoviesSearch.clear();
                        });
                      },
                    ),
                  )
                ]
              : [
                  ItemMove(
                    corBorda: Colors.white,
                    isCategory: true,
                    callback: () {
                      setState(() {
                        _searchBoolean = false;
                        listMoviesSearch.clear();
                      });
                    },
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      mouseCursor: SystemMouseCursors.click,
                      onPressed: () {
                        setState(() {
                          _searchBoolean = false;
                          listMoviesSearch.clear();
                        });
                      },
                    ),
                  )
                ]),
      backgroundColor: Theme.of(context).backgroundColor,
      body: (isLoading)
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : !_searchBoolean
              ? _defaultListView()
              : _searchListView(),
    );
  }

  void _initData(id) async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    var response = await api_controller.getMoviesFromCategory(
      responseStorageAPI.url,
      responseStorageAPI.username,
      responseStorageAPI.password,
      id,
    );
    if (response != null) {
      setState(() {
        listMovies = response!;
        isLoading = false;
      });
    }else{
      Fluttertoast.showToast(
        msg: "Não encontramos os Canais desta categoria!",
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

  void _updateSearch(String s) {
    //percorrendo a lista
    List<ResponseMoviesCategory> listaNova = listMovies
        .where(
            (element) => element.name!.toLowerCase().contains(s.toLowerCase()))
        .toList();
    print("Total: " + listaNova.length.toString());
    setState(() {
      listMoviesSearch.clear();
      listMoviesSearch = listaNova;
    });
  }
}
