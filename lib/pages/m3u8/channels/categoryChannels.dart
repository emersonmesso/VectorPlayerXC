import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/ItemMove.dart';
import '../../../controller/M3U8/m3u8DAO.dart';
import '../../../models/ListM3U8/ResponseListM3U8Channel.dart';
import 'listChannels.dart';

class categoryChannelsScreen extends StatefulWidget {
  const categoryChannelsScreen({Key? key}) : super(key: key);

  @override
  State<categoryChannelsScreen> createState() => _categoryChannelsScreenState();
}

class _categoryChannelsScreenState extends State<categoryChannelsScreen> {
  late List<ResponseListM3U8Channel> listCategories =
      <ResponseListM3U8Channel>[];
  late M3U8DAO m3u8dao = M3U8DAO();

  @override
  void initState() {
    initData(context);
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
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: Container(
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
                return ItemMove(
                  corBorda: Colors.white,
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListChannelsScreen(
                          channels: listCategories[index].list,
                          title: listCategories[index].title!,
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
                        listCategories[index].title!,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void initData(BuildContext context) async {
    //buscando os canais
    var response = await m3u8dao.getChannels();
    if (response != null) {
      setState(() {
        listCategories = response;
      });
      FocusScope.of(context).nextFocus();
    }
  }
}
