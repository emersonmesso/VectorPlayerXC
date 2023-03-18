import 'package:apptv/components/ItemChannel.dart';
import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/controller/HttpController.dart';
import 'package:apptv/models/ResponseChannelAPI.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/models/SettingsData.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../controller/functions.dart';

class AllChannelsPage extends StatefulWidget {
  const AllChannelsPage({Key? key}) : super(key: key);

  @override
  State<AllChannelsPage> createState() => _AllChannelsPageState();
}

class _AllChannelsPageState extends State<AllChannelsPage> {
  late bool isLoading;
  late bool _searchBoolean = false;
  late List<ResponseChannelAPI> listChannels;
  HTTpController api_controller = HTTpController();
  late ResponseStorageAPI responseStorageAPI;
  List<int> _searchIndexList = [];
  late SettingsData settings;

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
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      childAspectRatio: (4 / 1),
      children: List.generate(
        listChannels.length,
        (index) {
          return ItemChannel(data: listChannels[index]);
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: !_searchBoolean
            ? const Text("Todos os Canais")
            : _searchTextField(),
        actions: !_searchBoolean
            ? [
                ItemMove(
                  corBorda: Colors.white,
                  isCategory: true,
                  callback: () {
                    setState(() {
                      _searchBoolean = true;
                      _searchIndexList.clear();
                    });
                  },
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _searchBoolean = true;
                        _searchIndexList.clear();
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

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    settings = (await getSeetings())!;

    var response = await api_controller.getAllChannels(responseStorageAPI.url,
        responseStorageAPI.username, responseStorageAPI.password);
    if (response != null) {
      setState(() {
        listChannels = response;
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(
          msg: "Não encontramos os Canais!",
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
