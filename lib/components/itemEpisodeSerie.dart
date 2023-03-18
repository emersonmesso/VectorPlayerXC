import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/models/Serie/ResponseInfoSerieEpisode.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ItemEpisodeSerie extends StatefulWidget {
  const ItemEpisodeSerie({Key? key, required this.episode, required this.serie})
      : super(key: key);
  final ResponseInfoSerieEpisode episode;
  final ResponseCategorySeries serie;

  @override
  State<ItemEpisodeSerie> createState() => _ItemEpisodeSerieState();
}

class _ItemEpisodeSerieState extends State<ItemEpisodeSerie> {
  late bool isLoading;
  late bool isWatch;
  late ResponseStorageAPI responseStorageAPI;

  @override
  void initState() {
    isLoading = true;
    isWatch = false;
    _initData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 100,
            child: (widget.episode.info!.movieImage != null)
                ? Image.network(
                    widget.episode.info!.movieImage!,
                    fit: BoxFit.contain,
                    width: 150,
                    height: 100,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        "lib/assets/logo.png",
                        fit: BoxFit.contain,
                        width: 150,
                        height: 100,
                      );
                    },
                  )
                : Image.asset(
                    "lib/assets/logo.png",
                    fit: BoxFit.contain,
                    width: 150,
                    height: 100,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.episode.title}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                  Text(
                    "${(widget.episode.info!.plot == "null") ? "" : widget.episode.info!.plot}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  (isLoading)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        )
                      : (isWatch)
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Center(
                                    child: Lottie.asset(
                                      'lib/assets/watch.json',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                const Text(
                                  "Assistido",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            )
                          : Container()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initData(BuildContext context) async {
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    var response = await getWatch(
        widget.serie.seriesId!,
        widget.episode.season!,
        widget.episode.episodeNum!,
        responseStorageAPI.url!);
    if (response!.episodeNum != null && (response.complete!)) {
      setState(() {
        isWatch = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isWatch = false;
        isLoading = false;
      });
    }
  }
}
