import 'package:apptv/components/ItemChannel.dart';
import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/components/ItemMovie.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/models/ResponseChannelAPI.dart';
import 'package:apptv/models/ResponseMoviesCategory.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../controller/functions.dart';

class AllMoviesPage extends StatefulWidget {
  const AllMoviesPage({Key? key}) : super(key: key);

  @override
  State<AllMoviesPage> createState() => _AllMoviesPageState();
}

class _AllMoviesPageState extends State<AllMoviesPage> {
  late bool isLoading;
  late bool _searchBoolean = false;
  late List<ResponseMoviesCategory> listMovies;
  HTTpController api_controller = HTTpController();
  late ResponseStorageAPI responseStorageAPI;
  List<int> _searchIndexList = [];

  @override
  void initState() {
    isLoading = true;
    _searchBoolean = false;
    _initData();
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
        hintText: 'Busca', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle(
          //Style of hintText
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
      onChanged: (String s) {
        //add
        setState(() {
          _searchIndexList = [];
          for (int i = 0; i < listMovies.length; i++) {
            if (listMovies[i]
                .name!
                .toLowerCase()
                .contains(s.toString().toLowerCase())) {
              _searchIndexList.add(i);
            }
          }
        });
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
        _searchIndexList.length,
        (index) {
          int ind = _searchIndexList[index];
          return ItemMovie(movie: listMovies[ind]);
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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: !_searchBoolean ? Text("Todos os Filmes") : _searchTextField(),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: !_searchBoolean
            ? [
                ItemMove(
                  corBorda: Colors.white,
                  isCategory: true,
                  callback: () {
                    setState(() {
                      _searchBoolean = true;
                      _searchIndexList = [];
                    });
                  },
                  child: IconButton(
                    mouseCursor: SystemMouseCursors.click,
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _searchBoolean = true;
                        _searchIndexList = [];
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
                    });
                  },
                  child: IconButton(
                    mouseCursor: SystemMouseCursors.click,
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchBoolean = false;
                      });
                    },
                  ),
                )
              ],
      ),
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

  void _initData() async {
    print("INICIANDO...");
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    var response = await api_controller.getAllMovies(responseStorageAPI.url,
        responseStorageAPI.username, responseStorageAPI.password);
    if (response != null) {
      setState(() {
        listMovies = response;
        isLoading = false;
      });
    } else {}
  }
}
