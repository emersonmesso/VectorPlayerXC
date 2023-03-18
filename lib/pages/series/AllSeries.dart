import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/components/ItemSerie.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../controller/functions.dart';

class AllSeriesPage extends StatefulWidget {
  const AllSeriesPage({Key? key}) : super(key: key);

  @override
  State<AllSeriesPage> createState() => _AllSeriesPageState();
}

class _AllSeriesPageState extends State<AllSeriesPage> {
  late bool isLoading;
  late bool _searchBoolean = false;
  late List<ResponseCategorySeries> listSeries;
  HTTpController api_controller = HTTpController();
  late ResponseStorageAPI responseStorageAPI;
  List<ResponseCategorySeries> _searchIndexList = <ResponseCategorySeries>[];

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
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: UnderlineInputBorder(
          //Borders when a TextField is in focus
            borderSide: BorderSide(color: Colors.white)),
        hintText: 'Buscar', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle(
          //Style of hintText
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
      onChanged: (String s) {
        //add
        _onChangerSearch(s);
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
          print(_searchIndexList[index].name);
          return ItemSerie(serie: _searchIndexList[index],);
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
        listSeries.length,
            (index) {
          return ItemSerie(serie: listSeries[index],);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).backgroundColor,
          title: !_searchBoolean ? const Text("Todas as Séries") : _searchTextField(),
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
            : _searchListView()
    );
  }

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    var response = await api_controller.getAllSeries(responseStorageAPI.url,
        responseStorageAPI.username, responseStorageAPI.password);
    if (response != null) {
      setState(() {
        listSeries = response;
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Não encontramos as séries!",
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

  void _onChangerSearch(String s) async {
    List<ResponseCategorySeries> listVazia = <ResponseCategorySeries>[];

    listSeries.forEach((element) {
      if(element.name!.toLowerCase().contains(s.toLowerCase())){
        //print(element.name);
        listVazia.add(element);
      }
    });
    setState(() {
      _searchIndexList.clear();
      _searchIndexList = listVazia;
    });
  }
}
