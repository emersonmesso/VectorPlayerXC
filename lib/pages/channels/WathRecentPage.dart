import 'package:flutter/material.dart';

import '../../components/ItemChannel.dart';
import '../../controller/functions.dart';
import '../../models/ResponseChannelAPI.dart';
import '../../models/ResponseStorageAPI.dart';

class WathRecentPage extends StatefulWidget {
  const WathRecentPage({Key? key}) : super(key: key);

  @override
  State<WathRecentPage> createState() => _WathRecentPageState();
}

class _WathRecentPageState extends State<WathRecentPage> {
  late bool isLoading;
  late List<ResponseChannelAPI> listaFavourites = <ResponseChannelAPI>[];
  late ResponseStorageAPI responseStorageAPI;

  @override
  void initState() {
    isLoading = true;
    _initData();
    super.initState();
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
        title: const Text("Canais Recentes"),
      ),
      body: (isLoading)
          ? const Center(
        child: CircularProgressIndicator(),
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
            listaFavourites.length,
                (index) {
              return ItemChannel(
                data: listaFavourites[index]!,
              );
            },
          ),
        ),
      ),
    );
  }

  void _initData() async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    //buscando os canais favoritos
    var response = await getListRecentsWatchingChannels(responseStorageAPI.url);
    if(response != null){
      setState(() {
        listaFavourites = response;
        isLoading = false;
      });
    }else{
      //não tem nada a ser mostrado
      setState(() {
        isLoading = false;
      });
    }

  }
}
