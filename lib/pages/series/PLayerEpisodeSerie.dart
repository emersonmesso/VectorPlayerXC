import 'dart:async';
import 'dart:convert';
import 'package:apptv/controller/functions.dart';
import 'package:apptv/models/ResponseCategorySeries.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/models/Serie/ResponseInfoSerieEpisode.dart';
import 'package:apptv/models/Serie/SerieWatching.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/services.dart';

class PlayerEpidode extends StatefulWidget {
  const PlayerEpidode({Key? key, required this.episode, required this.serie})
      : super(key: key);
  final ResponseInfoSerieEpisode episode;
  final ResponseCategorySeries serie;

  @override
  State<PlayerEpidode> createState() => _PlayerEpidodeState();
}

class _PlayerEpidodeState extends State<PlayerEpidode> {
  late bool isLoading;
  late bool isPlaying;
  late bool getDataFromVideo;
  late Duration duration;
  late Duration position = const Duration(seconds: 1);
  late ResponseStorageAPI responseStorageAPI;
  late Timer tempo;
  FlickManager? flickManager;

  @override
  void initState() {
    isLoading = true;
    isPlaying = false;
    getDataFromVideo = false;
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (flickManager == null)
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FlickVideoPlayer(
                flickManager: flickManager!,
                preferredDeviceOrientation: const [
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft
                ],
                wakelockEnabledFullscreen: true,
              ),
            ),
    );
  }

  @override
  void dispose() {
    tempo.cancel();
    flickManager!.dispose();
    saveExit();
    super.dispose();
  }

  void _initData() async {
    //buscando os dados da API
    List<ResponseStorageAPI>? listAPI = await getAPIData();
    responseStorageAPI = (await ativo(listAPI!))!;
    print(
        '${responseStorageAPI.url}series/${responseStorageAPI.username}/${responseStorageAPI.password}/${widget.episode.id}.mp4');
    setState(() {
      flickManager = FlickManager(
        onVideoEnd: _onEndVideo,
        autoPlay: true,
        autoInitialize: true,
        videoPlayerController: VideoPlayerController.network(
          '${responseStorageAPI.url}series/${responseStorageAPI.username}/${responseStorageAPI.password}/${widget.episode.id}.mp4',
        ),
      );
    });
    flickManager?.flickVideoManager?.addListener(() {
      if (!getDataFromVideo) {
        //pegando todos os dados do vídeo
        //duração
        setState(() {
          duration =
              flickManager!.flickVideoManager!.videoPlayerValue!.duration;
        });
        _onTimerDuration(
            flickManager!.flickVideoManager!.videoPlayerValue!.position);
      }
    });
    getPoint();
  }

  getPoint() {
    tempo = Timer(const Duration(seconds: 60), () {
      setState(() {
        position = flickManager!.flickVideoManager!.videoPlayerValue!.position;
      });
      print("Pegando a posição: ${position.inSeconds}");
      getPoint();
    });
  }

  _onEndVideo() {
    Navigator.pop(context);
  }

  void _onTimerDuration(Duration d) async {
    if (d.inSeconds >= (duration.inSeconds - 120)) {
      await saveWatching(d, true);
      setState(() {
        getDataFromVideo = true;
      });
    }
  }

  saveWatching(Duration d, bool exit) async {
    var box = await Hive.openBox("boxSaveWatch");
    //box.clear();
    //buscando a lista salva
    var listaSalva = await box.get("listWatch");
    if (listaSalva != null) {
      //tem lista salva
      //pegando a lista
      var dados = jsonDecode(listaSalva) as List;
      List<SerieWatching>? lista =
          dados.map((e) => SerieWatching.fromJson(e)).toList();
      //verifica se já tem essa série salva
      bool tem = false;
      int cont = 0;
      int index = 0;
      for (var element in lista) {
        if ((element.url == responseStorageAPI.url) &&
            (element.serie!.seriesId == widget.serie.seriesId)) {
          tem = true;
          index = cont;
        }
        cont++;
      }
      if (tem) {
        //adicionando um novo episódio da lista salva
        lista[index].watching!.add(
              SerieEpisodeWatch(
                exit: d.inSeconds,
                episodeNum: widget.episode.episodeNum,
                complete: exit,
                season: widget.episode.season,
                title: widget.episode.title,
              ),
            );
      } else {
        //adicionando a série na lista
        List<SerieEpisodeWatch> listaEpisodios = <SerieEpisodeWatch>[];
        listaEpisodios.add(
          SerieEpisodeWatch(
            title: widget.episode.title,
            season: widget.episode.season,
            complete: exit,
            episodeNum: widget.episode.episodeNum,
            exit: d.inSeconds,
          ),
        );
        lista.add(SerieWatching(
          serie: widget.serie,
          url: responseStorageAPI.url,
          watching: listaEpisodios,
        ));

        //salvando na base de dados
        var convert = lista.map((e) => e.toJson()).toList();
        await box.put("listWatch", jsonEncode(convert).toString());
      }
    } else {
      //não tem uma lista salva, vamos criar um lista para salvar
      List<SerieWatching>? listaVazia = <SerieWatching>[];
      //adicionando um novo dado na lista
      List<SerieEpisodeWatch> listaEpisodios = <SerieEpisodeWatch>[];
      listaEpisodios.add(
        SerieEpisodeWatch(
          title: widget.episode.title,
          season: widget.episode.season,
          complete: exit,
          episodeNum: widget.episode.episodeNum,
          exit: d.inSeconds,
        ),
      );
      listaVazia.add(
        SerieWatching(
          serie: widget.serie,
          url: responseStorageAPI.url,
          watching: listaEpisodios,
        ),
      );

      //convertendo em JSON
      var convert = listaVazia.map((e) => e.toJson()).toList();
      await box.put("listWatch", jsonEncode(convert).toString());
    }
    print("Salvo!");
  }

  void saveExit() async {
    if (position.inSeconds > 60 && !getDataFromVideo) {
      await saveWatching(position, false);
    }
  }
}
