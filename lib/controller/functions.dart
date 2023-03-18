import 'dart:convert';
import 'package:apptv/models/ListM3U8/ResponseListM3U8Series.dart';
import 'package:apptv/models/ResponseChannelAPI.dart';
import 'package:apptv/models/ResponseChannelEPG.dart';
import 'package:apptv/models/ResponseFavouritesMovies.dart';
import 'package:apptv/models/ResponseListAPI.dart';
import 'package:apptv/models/ResponseMoviesCategory.dart';
import 'package:apptv/models/ResponseStorageAPI.dart';
import 'package:apptv/models/Serie/ResponseFavouriteSeire.dart';
import 'package:apptv/models/Serie/SerieWatching.dart';
import 'package:apptv/models/SettingsData.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ListM3U8/ResponseListM3U8Channel.dart';

Color hexToColor(String hexCode) {
  return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
}

Future<SettingsData?>? getSeetings() async {
  SettingsData? settings;
  final prefs = await SharedPreferences.getInstance();
  var response = prefs.getString("settings");
  if (response != null) {
    var dados = jsonDecode(response);
    settings = SettingsData.fromJson(dados);
  } else {
    settings = SettingsData(
      showRecentsWhatshing: false,
      showEPG: false,
      openOldPeople: false,
      openFullScreen: false,
      typelist: "m3u8"
    );
  }
  return settings;
}

bool isMobile() {
  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    return true;
  }
  return false;
}

bool isWeb() {
  if (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows) {
    return true;
  }
  return false;
}

String getURLFromString(String text) {
  RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
  Iterable<RegExpMatch> matches = exp.allMatches(text);
  var response = <String>[];
  matches.forEach((match) {
    response.add(text.substring(match.start, match.end));
  });
  return response[0];
}

Future<bool> enableDownloadEPG() async {
  var box = await Hive.openBox("boxSaveEPG");
  //await box.delete("time_epg");
  //procura por timestamp
  var timestamp = await box.get("time_epg");
  if (timestamp != null) {
    //tem algo salvo
    //verifica se já pode baixar o EPG
    DateTime now = DateTime.now();
    if (int.parse(timestamp) <= now.microsecondsSinceEpoch) {
      //já pode baixar
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

//convert time
int convertTime(String myString) {
  var step1 = myString.split(" ");
  int h = 0;

  var ano = step1[0].substring(0, 4);
  var mes = step1[0].substring(4, 6);
  var dia = step1[0].substring(6, 8);
  var hora = step1[0].substring(8, 10);
  var min = step1[0].substring(10, 12);
  var seg = step1[0].substring(12, 14);

  var step2 = step1[1];
  if (step2.contains("+")) {
    var step3 = step2.replaceAll("+", "");
    int total = int.parse(step3);
    double t = total / 100;
    h = int.parse(hora.toString()) - t.round();
  } else {
    var step3 = step2.replaceAll("-", "");
    int total = int.parse(step3);
    double t = (total / 100);
    h = int.parse(hora.toString()) + t.round();
  }
  var str = "";
  if (h < 10) {
    str = "0${h - 1}";
  } else {
    str = h.toString();
  }

  var time = "$ano-$mes-$dia ${str.toString()}:$min:$seg";

  DateTime data = DateTime.parse(time);
  return data.millisecondsSinceEpoch;
}

//get EPG from channel
Future<List<ResponseChannelEPG>> getEpgFromChannel(
    String epg_channel_id) async {
  List<ResponseChannelEPG> listaVazia = <ResponseChannelEPG>[];
  var box = await Hive.openBox("boxSaveEPG");
  var response = await box.get("epgSave");
  if (response != null) {
    //convertendo os dados em lista
    List<ResponseChannelEPG> list = (jsonDecode(response) as List)
        .map((e) => ResponseChannelEPG.fromJson(e))
        .toList();
    //percorrendo a lista salva
    var now = DateTime.now();
    list.forEach((element) {
      //verifica se o ID é igual ao do canal

      if (element.sChannel == epg_channel_id &&
          convertTime(element.sStop!) >= now.millisecondsSinceEpoch) {
        //adiciona na lista de retorno
        //print("Canal: ${element.title} (${convertTime(element.sStart!)} - ${convertTime(element.sStop!)})");
        listaVazia.add(element);
      }
    });
  }
  listaVazia.sort((a, b) => a.sStart.toString().compareTo(b.sStart.toString()));
  return listaVazia;
}

//get allEPG
Future<List<ResponseChannelEPG>> getAllEpgFromChannel(
    String epg_channel_id) async {
  List<ResponseChannelEPG> listaVazia = <ResponseChannelEPG>[];
  var box = await Hive.openBox("boxSaveEPG");
  var response = await box.get("epgSave");
  if (response != null) {
    //convertendo os dados em lista
    List<ResponseChannelEPG> list = (jsonDecode(response) as List)
        .map((e) => ResponseChannelEPG.fromJson(e))
        .toList();
    //percorrendo a lista salva
    DateTime now = DateTime.now();
    list.forEach((element) {
      //verifica se o ID é igual ao do canal
      if (element.sChannel == epg_channel_id &&
          convertTime(element.sStop!) >= now.millisecondsSinceEpoch) {
        //adiciona na lista de retorno
        listaVazia.add(element);
      }
    });
  }
  listaVazia.sort((a, b) => a.sStart.toString().compareTo(b.sStart.toString()));
  return listaVazia;
}

Future<bool> cleanDatabase() async {
  final prefs = await SharedPreferences.getInstance();
  if (await prefs.clear()) {
    return true;
  }
  return false;
}

Future<bool> saveDataAPI(List<ResponseListAPI> list) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("APIData");
  //criando uma lista
  List<ResponseStorageAPI> lista = <ResponseStorageAPI>[];

  //percorre a lista recebida
  list.forEach((e) {
    lista.add(
      ResponseStorageAPI(
        id: e.id,
        username: e.username,
        url: e.url,
        name: e.name,
        password: e.password,
        active: e.active,
        list_type: e.list_type,
      ),
    );
  });
  //salvando a lista
  var convert = lista.map((e) => e.toJson()).toList();
  await prefs.setString("APIData", jsonEncode(convert).toString());
  return true;
}

Future<List<ResponseStorageAPI>?> getAPIData() async {
  final prefs = await SharedPreferences.getInstance();
  //buscando os ultimos dados salvos
  var data = await prefs.getString("APIData");
  if (data != null) {
    //tem dados salvos
    List<ResponseStorageAPI> list = (jsonDecode(data) as List)
        .map((e) => ResponseStorageAPI.fromJson(e))
        .toList();
    return list;
  }
  return null;
}

Future<bool> verifySaveListM3U8() async {
  var box = await Hive.openBox("boxContentList");
  //await box.delete("channelsList");
  //verifica se tem canais
  var data = box.get("channelsList");
  if (data != null) {
    //tem algo salvo
    var dados = jsonDecode(data) as List;
    List<ResponseListM3U8Channel> listaCheia =
        dados.map((e) => ResponseListM3U8Channel.fromJson(e)).toList();
    if (listaCheia.length > 0) {
      return true;
    } else {
      return false;
    }
  } else {
    List<ResponseListM3U8Channel> listaVazia = <ResponseListM3U8Channel>[];
    var convert = listaVazia.map((e) => e.toJson()).toList();
    await box.put("favouritesSeries", jsonEncode(convert).toString());
    return false;
  }
}

Future<bool> saveChannelsM3U8(List<ResponseListM3U8Channel> lista) async {
  var box = await Hive.openBox("boxContentList");
  var convert = lista.map((e) => e.toJson()).toList();
  await box.put("channelsList", jsonEncode(convert).toString());
  return true;
}

Future<bool> saveMoviesM3U8(List<ResponseListM3U8Channel> lista) async {
  var box = await Hive.openBox("boxContentList");
  var convert = lista.map((e) => e.toJson()).toList();
  await box.put("moviesList", jsonEncode(convert).toString());
  return true;
}

Future<bool> saveSeriesM3U8(List<ResponseListM3U8Series> lista) async {
  var box = await Hive.openBox("boxContentList");
  var convert = lista.map((e) => e.toJson()).toList();
  await box.put("seriesList", jsonEncode(convert).toString());
  return true;
}

Future<ResponseStorageAPI?> ativo(List<ResponseStorageAPI> list) async {
  ResponseStorageAPI? responseStorageAPI;
  list.forEach((e) {
    if (e.active == 1) {
      responseStorageAPI = e;
    }
  });
  return responseStorageAPI;
}

Future<bool> saveFavorite(ResponseChannelAPI channel, url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesChannels");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavourite> listaCheia =
        dados.map((e) => ResponseFavourite.fromJson(e)).toList();

    //adicionando o novo canal na lista
    ResponseFavourite novoFavourite = ResponseFavourite(url, channel);
    listaCheia.add(novoFavourite);

    var convert = listaCheia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesChannels", jsonEncode(convert).toString());
    print("FAVORITO SALVO");
    return true;
  } else {
    //não tem dados
    //cria uma lista vazia
    List<ResponseFavourite> listaVazia = <ResponseFavourite>[];
    //adiciona o canal na lista vazia
    ResponseFavourite novoFavourite = new ResponseFavourite(url, channel);
    listaVazia.add(novoFavourite);

    //convertendo a lista em JSON
    var convert = listaVazia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesChannels", jsonEncode(convert).toString());
    print("FAVORITO SALVO");
    return true;
  }
}

Future<bool> removeFavourite(ResponseChannelAPI channel, url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesChannels");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavourite> listaCheia =
        dados.map((e) => ResponseFavourite.fromJson(e)).toList();
    //verificando o id do canal na lista
    int index = 0;
    int count = 0;
    listaCheia.forEach((element) {
      if ((element.channel?.streamId == channel.streamId) &&
          (element.url == url)) {
        index = count;
      }
      count++;
    });

    //removendo da lista
    listaCheia.removeAt(index);
    //salvando a lista nova
    var convert = listaCheia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesChannels", jsonEncode(convert).toString());
    return true;
  } else {
    return false;
  }
}

Future<List<ResponseChannelAPI>?> getListFavourites(url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesChannels");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavourite> listaCheia =
        dados.map((e) => ResponseFavourite.fromJson(e)).toList();
    //verificando se o favorito é do servidor
    List<ResponseChannelAPI>? listaNova = <ResponseChannelAPI>[];
    listaCheia.forEach((element) {
      if (element.url == url) {
        listaNova?.add(element!.channel!);
      }
    });
    //adicionando o novo canal na lista
    return listaNova;
  } else {
    List<ResponseChannelAPI>? listaNova = <ResponseChannelAPI>[];
    return listaNova;
  }
}

Future<bool> channelIsFavourite(ResponseChannelAPI channel, url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesChannels");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavourite> listaCheia =
        dados.map((e) => ResponseFavourite.fromJson(e)).toList();
    bool isHere = false;
    listaCheia.forEach((element) {
      if ((element.channel?.streamId == channel.streamId) &&
          (url == element.url)) {
        isHere = true;
      }
    });
    return isHere;
  } else {
    //não tem dados
    //cria uma lista vazia
    List<ResponseFavourite> listaVazia = <ResponseFavourite>[];

    //convertendo a lista em JSON
    var convert = listaVazia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesChannels", jsonEncode(convert).toString());
    print("FAVORITO SALVO");
    return false;
  }
}

/*MOVIES*/

//adiciona favorito
Future<bool> saveFavoriteMovie(ResponseMoviesCategory movie, url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesMovies");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavouriteMovies> listaCheia =
        dados.map((e) => ResponseFavouriteMovies.fromJson(e)).toList();

    //adicionando o novo canal na lista
    ResponseFavouriteMovies novoFavourite = ResponseFavouriteMovies(url, movie);
    listaCheia.add(novoFavourite);

    var convert = listaCheia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesMovies", jsonEncode(convert).toString());
    print("FAVORITO SALVO");
    return true;
  } else {
    //não tem dados
    //cria uma lista vazia
    List<ResponseFavouriteMovies> listaVazia = <ResponseFavouriteMovies>[];
    //adiciona o canal na lista vazia
    ResponseFavouriteMovies novoFavourite = ResponseFavouriteMovies(url, movie);
    listaVazia.add(novoFavourite);

    //convertendo a lista em JSON
    var convert = listaVazia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesMovies", jsonEncode(convert).toString());
    print("FAVORITO SALVO");
    return true;
  }
}

//verifica se é favorito
Future<bool> movieIsFavourite(ResponseMoviesCategory movie, url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesMovies");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavouriteMovies> listaCheia =
        dados.map((e) => ResponseFavouriteMovies.fromJson(e)).toList();
    bool isHere = false;
    listaCheia.forEach((element) {
      if ((element.movie?.streamId == movie.streamId) && (url == element.url)) {
        isHere = true;
      }
    });
    print("É FAVORITO: " + isHere.toString());
    return isHere;
  } else {
    //não tem dados
    //cria uma lista vazia
    List<ResponseFavouriteMovies> listaVazia = <ResponseFavouriteMovies>[];

    //convertendo a lista em JSON
    var convert = listaVazia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesMovies", jsonEncode(convert).toString());
    print("FAVORITO SALVO");
    return false;
  }
}

//remove filme favorito
Future<bool> removeFavouriteMovie(ResponseMoviesCategory movie, url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesMovies");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavouriteMovies> listaCheia =
        dados.map((e) => ResponseFavouriteMovies.fromJson(e)).toList();
    //verificando o id do canal na lista
    int index = 0;
    int count = 0;
    listaCheia.forEach((element) {
      if ((element.movie?.streamId == movie.streamId) && (element.url == url)) {
        index = count;
      }
      count++;
    });

    //removendo da lista
    listaCheia.removeAt(index);
    //salvando a lista nova
    var convert = listaCheia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesMovies", jsonEncode(convert).toString());
    return true;
  } else {
    return false;
  }
}

//pega todos os filmes favoritos
Future<List<ResponseMoviesCategory>?> getListFavouritesMovies(url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("favouritesMovies");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavouriteMovies> listaCheia =
        dados.map((e) => ResponseFavouriteMovies.fromJson(e)).toList();
    //verificando se o favorito é do servidor
    List<ResponseMoviesCategory>? listaNova = <ResponseMoviesCategory>[];
    listaCheia.forEach((element) {
      if (element.url == url) {
        listaNova?.add(element!.movie!);
      }
    });
    //adicionando o novo canal na lista
    return listaNova;
  } else {
    //cria uma lista vazia
    List<ResponseMoviesCategory> listaVazia = <ResponseMoviesCategory>[];
    //adiciona o canal na lista vazia

    //convertendo a lista em JSON
    var convert = listaVazia.map((e) => e.toJson()).toList();
    await prefs.setString("favouritesMovies", jsonEncode(convert).toString());
    return listaVazia;
  }
}

//salva recent playing channels
Future<bool> saveRecentPlayingChannel(ResponseChannelAPI channel, url) async {
  final prefs = await SharedPreferences.getInstance();
  //buscando a lista salva
  var response = await prefs.getString("recentsChannels");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavourite> listaCheia =
        dados.map((e) => ResponseFavourite.fromJson(e)).toList();

    //verifica se o canal não foi o útimo assistido
    if (listaCheia[listaCheia.length - 1].channel?.streamId !=
        channel.streamId) {
      //adicionando o novo canal na lista
      ResponseFavourite novoFavourite = new ResponseFavourite(url, channel);
      listaCheia.add(novoFavourite);
      //verifica o total de listas salvas
      if (listaCheia.length > 8) {
        //remove o ultimo adicionado
        listaCheia.removeAt(0);
      }
      var convert = listaCheia.map((e) => e.toJson()).toList();
      await prefs.setString("recentsChannels", jsonEncode(convert).toString());
      print("FAVORITO SALVO");
      return true;
    } else {
      return false;
    }
  } else {
    //não tem dados
    //cria uma lista vazia
    List<ResponseFavourite> listaVazia = <ResponseFavourite>[];
    //adiciona o canal na lista vazia
    ResponseFavourite novoFavourite = new ResponseFavourite(url, channel);
    listaVazia.add(novoFavourite);

    //convertendo a lista em JSON
    var convert = listaVazia.map((e) => e.toJson()).toList();
    await prefs.setString("recentsChannels", jsonEncode(convert).toString());
    print("FAVORITO SALVO");
    return true;
  }
}

//pega os recentes assistidos canais
Future<List<ResponseChannelAPI>?> getListRecentsWatchingChannels(url) async {
  final prefs = await SharedPreferences.getInstance();
  //prefs.remove("recentsChannels");
  //buscando a lista salva
  var response = await prefs.getString("recentsChannels");
  if (response != null) {
    //tem dados
    var dados = jsonDecode(response) as List;
    List<ResponseFavourite> listaCheia =
        dados.map((e) => ResponseFavourite.fromJson(e)).toList();
    //verificando se o favorito é do servidor
    List<ResponseChannelAPI>? listaNova = <ResponseChannelAPI>[];
    listaCheia.forEach((element) {
      if (element.url == url) {
        listaNova?.add(element!.channel!);
      }
    });

    //revertendo lista
    List<ResponseChannelAPI>? listaRevertida = <ResponseChannelAPI>[];
    for (var i = (listaCheia.length - 1); i >= 0; i--) {
      listaRevertida?.add(listaCheia[i].channel!);
    }
    return listaRevertida;
  } else {
    return null;
  }
}

Future<List<ResponseFavouriteSerie>?> getListFavouritesSeries(url) async {
  final prefs = await SharedPreferences.getInstance();
  var response = await prefs.getString("favouritesSeries");
  if (response != null) {
    var dados = jsonDecode(response) as List;
    List<ResponseFavouriteSerie> listaCheia =
        dados.map((e) => ResponseFavouriteSerie.fromJson(e)).toList();
    List<ResponseFavouriteSerie>? listaNova = <ResponseFavouriteSerie>[];
    listaCheia.forEach((element) {
      if (element.url == url) {
        listaNova?.add(element!);
      }
    });
    return listaNova;
  } else {
    return null;
  }
}

//verifica se o episódio foi assistido
Future<SerieEpisodeWatch>? getWatch(
    int serieID, int season, int episode, String url) async {
  var box = await Hive.openBox("boxSaveWatch");
  //box.clear();
  //buscando a lista salva
  var listaSalva = await box.get("listWatch");
  if (listaSalva != null) {
    var dados = jsonDecode(listaSalva) as List;
    List<SerieWatching>? lista =
        dados.map((e) => SerieWatching.fromJson(e)).toList();
    //verifica se já tem essa série salva
    bool tem = false;
    int cont = 0;
    int index = 0;
    for (var element in lista) {
      if ((element.url == url) && (element.serie!.seriesId == serieID)) {
        tem = true;
        index = cont;
      }
      cont++;
    }
    //
    SerieEpisodeWatch? retorno = SerieEpisodeWatch();
    if (tem) {
      lista[index].watching!.forEach((element) {
        if (element.season == season && element.episodeNum == episode) {
          //retorna os dados
          retorno = element;
        }
      });
    }
    return retorno!;
  } else {
    return SerieEpisodeWatch();
  }
}
