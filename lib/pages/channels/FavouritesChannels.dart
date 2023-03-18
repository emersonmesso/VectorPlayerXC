import 'package:flutter/material.dart';
import '../../components/ItemChannel.dart';
import '../../controller/functions.dart';
import '../../models/ResponseChannelAPI.dart';
import '../../models/ResponseStorageAPI.dart';
import 'VideoPlayerPage.dart';

class FavouritesChannelPage extends StatefulWidget {
  const FavouritesChannelPage({Key? key}) : super(key: key);

  @override
  State<FavouritesChannelPage> createState() => _FavouritesChannelPageState();
}

class _FavouritesChannelPageState extends State<FavouritesChannelPage> {
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
        title: const Text("Canais Favoritos"),
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

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerPageM3U8(
                              channel: listaFavourites[index],
                            ),
                          ),
                        );
                      },
                      child: ItemChannel(
                        data: listaFavourites[index]!,
                      ),
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
    var response = await getListFavourites(responseStorageAPI.url);
    if (response != null) {
      setState(() {
        listaFavourites = response;
        isLoading = false;
      });
    } else {
      //não tem nada a ser mostrado
      setState(() {
        isLoading = false;
      });
    }
  }
}
