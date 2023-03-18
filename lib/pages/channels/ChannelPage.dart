import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../components/ItemChannel.dart';
import '../../components/ItemMove.dart';
import '../../controller/HttpController.dart';
import '../../controller/functions.dart';
import '../../models/ResponseChannelAPI.dart';
import '../../models/ResponseStorageAPI.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);
  final String categoryId;
  final String categoryName;
  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late String category_id;
  HTTpController api_controller = HTTpController();
  late List<ResponseChannelAPI> listChannels;
  late bool isLoading;
  late bool _searchBoolean = false;
  List<int> _searchIndexList = [];

  late ResponseStorageAPI responseStorageAPI;

  @override
  void initState() {
    category_id = widget.categoryId;
    isLoading = true;
    initialData();
    super.initState();
  }

  // TODO: Lista de pesquisa
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
          for (int i = 0; i < listChannels.length; i++) {
            if (listChannels[i]
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
      crossAxisCount: 4,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      childAspectRatio: (4 / 1),
      children: List.generate(
        _searchIndexList.length,
        (index) {
          int ind = _searchIndexList[index];
          return ItemChannel(data: listChannels[ind]);
        },
      ),
    );
  }

  Widget _defaultListView() {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 1,
        childAspectRatio: (4 / 1),
        children: List.generate(listChannels.length, (index) {
          return ItemChannel(
            data: listChannels[index],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(widget.categoryName),
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

  void initialData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;

    var response = await api_controller.getAllChannelsCategory(
        responseStorageAPI.url,
        responseStorageAPI.username,
        responseStorageAPI.password,
        category_id);
    if (response != null) {
      setState(() {
        listChannels = response!;
        isLoading = false;
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
    }
  }
}
