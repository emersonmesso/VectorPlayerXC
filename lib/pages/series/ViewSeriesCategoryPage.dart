import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/components/ItemSerie.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ViewSeriesCategoryPage extends StatefulWidget {
  const ViewSeriesCategoryPage(
      {Key? key, required this.category, this.category_name})
      : super(key: key);
  final String? category;
  final String? category_name;

  @override
  State<ViewSeriesCategoryPage> createState() => _ViewSeriesCategoryPageState();
}

class _ViewSeriesCategoryPageState extends State<ViewSeriesCategoryPage> {
  late bool isLoading;
  late ResponseStorageAPI responseStorageAPI;
  HTTpController api_controller = HTTpController();
  late List<ResponseCategorySeries> listCategorySeries;

  //busca
  late bool _searchBoolean = false;
  List<ResponseCategorySeries> _searchIndexList = <ResponseCategorySeries>[];

  @override
  void initState() {
    isLoading = true;
    _initDate(context);
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

  void _onChangerSearch(String s) async {
    List<ResponseCategorySeries> listVazia = <ResponseCategorySeries>[];

    listCategorySeries.forEach((element) {
      if (element.name!.toLowerCase().contains(s.toLowerCase())) {
        //print(element.name);
        listVazia.add(element);
      }
    });
    setState(() {
      _searchIndexList.clear();
      _searchIndexList = listVazia;
    });
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
          return ItemSerie(
            serie: _searchIndexList[index],
          );
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
        listCategorySeries.length,
        (index) {
          return ItemSerie(
            serie: listCategorySeries[index],
          );
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
          title: !_searchBoolean ? Text(widget.category_name!) : _searchTextField(),
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
                ]),
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

  void _initDate(context) async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    var response = await api_controller.getSeriesFromCategory(
        responseStorageAPI.url,
        responseStorageAPI.username,
        responseStorageAPI.password,
        widget.category);

    if (response != null) {
      setState(() {
        isLoading = false;
        listCategorySeries = response;
      });
    } else {
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
}
