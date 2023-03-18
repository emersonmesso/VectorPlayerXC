import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import '../models/ListM3U8/ResponseListM3U8Channel.dart';
import '../models/ListM3U8/ResponseListM3U8Series.dart';
import '../models/ResponseAPITMDB.dart';
import '../models/ResponseActiveAPI.dart';
import '../models/ResponseCategoriesMoviesAPI.dart';
import '../models/ResponseCategorySeries.dart';
import '../models/ResponseChannelAPI.dart';
import '../models/ResponseChannelEPG.dart';
import '../models/ResponseChannelsAPI.dart';
import '../models/ResponseListAPI.dart';
import '../models/ResponseMoviesCategory.dart';
import '../models/Serie/ListSeason.dart';
import '../models/Serie/ResponseInfoSerieEpisode.dart';
import '../models/Serie/ResponseInfoSerieInfo.dart';
import '../models/Serie/ResponseInfoSerieSeason.dart';
import '../models/Serie/ResponseSerieInfoAll.dart';

class HTTpController {
  final String URL_API = "http://vectorplayer.com/v1/";

  //GetChannels from list m3u8
  Future<List<ResponseListM3U8Channel>?> getListChannelsFromM3U8(
      int? id) async {
    var map = <String, dynamic>{};
    map['id'] = id.toString();
    try {
      print("Abrindo a busca...");
      var response = await http.post(
          Uri.parse("https://vectorplayer.com/v2/iptv/channels"),
          headers: {},
          body: map);
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<ResponseListM3U8Channel> lista = (responseData['data'] as List)
            .map((e) => ResponseListM3U8Channel.fromJson(e))
            .toList();
        return lista;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //get movies from list m3u8
  Future<List<ResponseListM3U8Channel>?> getListMoviesFromM3U8(int? id) async {
    var map = <String, dynamic>{};
    map['id'] = id.toString();
    try {
      var response = await http.post(
          Uri.parse("https://vectorplayer.com/v2/iptv/movies"),
          headers: {},
          body: map);
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<ResponseListM3U8Channel> lista = (responseData['data'] as List)
            .map((e) => ResponseListM3U8Channel.fromJson(e))
            .toList();
        return lista;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //get series from list m3u8
  Future<List<ResponseListM3U8Series>?> getListSeriesFromM3U8(int? id) async {
    var map = <String, dynamic>{};
    map['id'] = id.toString();
    try {
      var response = await http.post(
          Uri.parse("https://vectorplayer.com/v2/iptv/series"),
          headers: {},
          body: map);
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<ResponseListM3U8Series> lista = (responseData['data'] as List)
            .map((e) => ResponseListM3U8Series.fromJson(e))
            .toList();
        return lista;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> activeList(int id, String address) async {
    var map = <String, dynamic>{};
    map['device_id'] = address;
    map['device_type'] = "Android";
    map['list_id'] = id.toString();
    var response = await http.post(Uri.parse('${URL_API}lista/activelist'),
        headers: {}, body: map);
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['error'] == false) {
        return true;
      }
    }
    return false;
  }

  Future<ResponseActiveApi> verifyAccountIPTV(url, username, password) async {
    try {
      var response = await http.get(Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print("CHEGOU DA API: $responseData");
        return ResponseActiveApi.fromJson(jsonDecode(response.body));
      } else {
        ResponseActiveApi error = ResponseActiveApi(
          userInfo: UserInfo(
              status: "error",
              username: '',
              password: '',
              message: '',
              auth: null,
              isTrial: '',
              expDate: '',
              maxConnections: ''),
          serverInfo: ServerInfo(version: ''),
        );
        return error;
      }
    } catch (e) {
      print(e.toString());
      ResponseActiveApi error = ResponseActiveApi(
        userInfo: UserInfo(
            status: "error",
            username: '',
            password: '',
            message: '',
            auth: null,
            isTrial: '',
            expDate: '',
            maxConnections: ''),
        serverInfo: ServerInfo(version: ''),
      );
      return error;
    }
  }

  //get channels
  Future<List<ResponseChannelsAPI>?> getAllCategoryChannels(
      url, username, password) async {
    try {
      var response = await http.get(Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_live_categories'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body) as List;
        List<ResponseChannelsAPI> lista =
            responseData.map((e) => ResponseChannelsAPI.fromJson(e)).toList();
        print("COUNT LIST: ${lista.length}");
        return lista;
      }
    } catch (e) {
      return null;
    }
  }

  //get list channels on category
  Future<List<ResponseChannelAPI>?> getAllChannelsCategory(
      url, username, password, categoryId) async {
    try {
      var response = await http.get(Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_live_streams&category_id=' +
          categoryId));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body) as List;
        List<ResponseChannelAPI> lista =
            responseData.map((e) => ResponseChannelAPI.fromJson(e)).toList();
        return lista;
      }
    } catch (e) {
      return null;
    }
  }

  //get epg from channel
  Future<bool?> getEPG(url, username, password) async {
    final Xml2Json xml2Json = Xml2Json();
    var box = await Hive.openBox("boxSaveEPG");
    var map = <String, String>{};
    map['Access-Control-Allow-Origin'] = "*";
    var response = await http.get(
        Uri.parse(
          url + 'xmltv.php?username=' + username + '&password=' + password,
        ),
        headers: map);
    print(
        '${'${'ABRINDO LINK: ' + url + 'player_api.php?username=' + username}&password=' + password}&action=get_short_epg&stream_id=');
    if (response.statusCode == 200) {
      xml2Json.parse(response.body.toString());
      var jsonString = xml2Json.toParkerWithAttrs();
      var data = jsonDecode(jsonString);
      var dados = data['tv']['programme'] as List;
      //print(dados.toString());
      //cria a lista
      List<ResponseChannelEPG> lista =
          dados.map((e) => ResponseChannelEPG.fromJson(e)).toList();
      //salvando os dados no aparelho
      DateTime now = DateTime.now();
      DateTime date = DateTime(now.year, now.month, (now.day + 1));
      await box.put("time_epg", date.microsecondsSinceEpoch.toString());
      var convert = lista.map((e) => e.toJson()).toList();
      await box.put('epgSave', jsonEncode(convert).toString());
    } else {
      print("ERROR...");
      return false;
    }
  }

  Future<bool?> downloadEPG(url, username, password) async {
    try {
      final Xml2Json xml2Json = Xml2Json();
      var box = await Hive.openBox("boxSaveEPG");
      var response = await http.get(Uri.parse(
          url + 'xmltv.php?username=' + username + '&password=' + password));
      print(
          '${'ABRINDO LINK: ' + url + 'xmltv.php?username=' + username}&password=' +
              password);
      if (response.statusCode == 200) {
        xml2Json.parse(response.body.toString());
        var jsonString = xml2Json.toParkerWithAttrs();
        var data = jsonDecode(jsonString);
        var dados = data['tv']['programme'] as List;
        //print(dados.toString());
        //cria a lista
        List<ResponseChannelEPG> lista =
            dados.map((e) => ResponseChannelEPG.fromJson(e)).toList();
        //salvando os dados no aparelho
        DateTime now = DateTime.now();
        DateTime date = DateTime(now.year, now.month, (now.day + 1));
        await box.put("time_epg", date.microsecondsSinceEpoch.toString());
        var convert = lista.map((e) => e.toJson()).toList();
        await box.put('epgSave', jsonEncode(convert).toString());
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<ResponseListAPI>?> getListsFromAPI(deviceID, deviceType) async {
    var map = <String, dynamic>{};
    map['device_id'] = deviceID;
    map['device_type'] = deviceType;
    var response = await http.post(Uri.parse('${URL_API}auth/verify'),
        headers: {}, body: map);
    List<ResponseListAPI>? lista = <ResponseListAPI>[];
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['error'] == false) {
        var dados = responseData['data'] as List;
        print("LISTAS: ${dados.length}");
        if (dados.length > 0) {
          lista = dados.map((e) => ResponseListAPI.fromJson(e)).toList();
        }
      }
    }
    return lista;
  }

  //get allcategories movies
  Future<List<ResponseCategoriesMoviesAPI>?> getAllCategoriesMovies(
      url, username, password) async {
    var response = await http.get(
      Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_vod_categories'),
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body) as List;
      List<ResponseCategoriesMoviesAPI> listaVazia = responseData
          .map((e) => ResponseCategoriesMoviesAPI.fromJson(e))
          .toList();
      return listaVazia;
    } else {
      print("ERROR...");
      return null;
    }
  }

  //get movies from category
  Future<List<ResponseMoviesCategory>?> getMoviesFromCategory(
      url, username, password, categoryId) async {
    try {
      var response = await http.get(
        Uri.parse(url +
            'player_api.php?username=' +
            username +
            '&password=' +
            password +
            '&action=get_vod_streams&category_id=' +
            categoryId.toString()),
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body) as List;
        List<ResponseMoviesCategory> listaVazia = responseData
            .map((e) => ResponseMoviesCategory.fromJson(e))
            .toList();
        return listaVazia;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //get data from TMDB
  Future<ResponseAPITMDB?> getInfoMovieFromTMDB(name, ano) async {
    var response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/search/movie?api_key=68950d5caedeef53ea66ee64fdc2e025&language=pt-BR&query=${Uri.encodeComponent(name).toLowerCase()}'),
    );
    print(
        "LINK: https://api.themoviedb.org/3/search/movie?api_key=68950d5caedeef53ea66ee64fdc2e025&language=pt-BR&query=${Uri.encodeComponent(name).toLowerCase()}");
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['total_results'] > 0) {
        //tem dados da API
        List<ResponseAPITMDB> dados = (responseData['results'] as List)
            .map((e) => ResponseAPITMDB.fromJson(e))
            .toList();
        //verificando se o ano é o mesmo
        int index = 0;
        int cont = 0;
        if (ano != "") {
          dados.forEach((element) {
            if (element.releaseDate! != "") {
              var date = DateTime.parse(element.releaseDate!);
              if (date.year.toString() == ano) {
                index = cont;
              }
              cont++;
            }
          });
        }
        return dados[index];
      } else {
        ResponseAPITMDB dados = ResponseAPITMDB(id: 0);
        return dados;
      }
    } else {
      print("ERROR...");
      return null;
    }
  }

  //get All channels
  Future<List<ResponseChannelAPI>?> getAllChannels(
      url, username, password) async {
    try {
      var response = await http.get(Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_live_streams'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body) as List;
        List<ResponseChannelAPI> lista =
            responseData.map((e) => ResponseChannelAPI.fromJson(e)).toList();
        return lista;
      }
    } catch (e) {
      return null;
    }
  }

  //get allmovies
  Future<List<ResponseMoviesCategory>?> getAllMovies(
      url, username, password) async {
    try {
      var response = await http.get(Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_vod_streams'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body) as List;
        List<ResponseMoviesCategory> lista = responseData
            .map((e) => ResponseMoviesCategory.fromJson(e))
            .toList();
        return lista;
      }
    } catch (e) {
      return null;
    }
  }

  /*SÉRIES*/
  Future<List<ResponseCategoriesMoviesAPI>?> getCategorySeries(
      url, username, password) async {
    try {
      var response = await http.get(Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_series_categories'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body) as List;
        List<ResponseCategoriesMoviesAPI> lista = responseData
            .map((e) => ResponseCategoriesMoviesAPI.fromJson(e))
            .toList();
        return lista;
      }
    } catch (e) {
      return null;
    }
  }

  //get series from category
  Future<List<ResponseCategorySeries>?> getSeriesFromCategory(
      url, username, password, category) async {
    var response = await http.get(Uri.parse(url +
        'player_api.php?username=' +
        username +
        '&password=' +
        password +
        '&action=get_series&category_id=' +
        category.toString()));
    print(url +
        'player_api.php?username=' +
        username +
        '&password=' +
        password +
        '&action=get_series&category_id=' +
        category.toString());
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body) as List;
      print("Fotos: " + responseData[0]['backdrop_path'].toString());
      List<ResponseCategorySeries> lista =
          responseData.map((e) => ResponseCategorySeries.fromJson(e)).toList();
      return lista;
    } else {
      print("ERROR...");
      return null;
    }
  }

  //get info from serie
  Future<ResponseInfoSerieAll?>? getInfoFromSerie(
      url, username, password, serieid) async {
    try {
      var response = await http.get(Uri.parse(url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_series_info&series_id=' +
          serieid.toString()));
      print("Acessando link: " +
          url +
          'player_api.php?username=' +
          username +
          '&password=' +
          password +
          '&action=get_series_info&series_id=' +
          serieid.toString());
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        //pegando os episódios disponíveis
        List<ResponseInfoSerieSeason> seasons =
            (responseData['seasons'] as List)
                .map((e) => ResponseInfoSerieSeason.fromJson(e))
                .toList();
        ResponseInfoSerieInfo infoSerie =
            ResponseInfoSerieInfo.fromJson(responseData['info']);
        List<ListSeason>? listaSeason = <ListSeason>[];
        int contWhile = 1;
        while (true) {
          //verifica se existe episódios na lista da temporada
          if (responseData['episodes']["$contWhile"] != null) {
            List<ResponseInfoSerieEpisode> episode =
                (responseData['episodes']["$contWhile"] as List)
                    .map((e) => ResponseInfoSerieEpisode.fromJson(e))
                    .toList();
            //verifica se existe temporada salva na lista
            var contain =
                seasons.where((element) => element.seasonNumber == contWhile);
            ResponseInfoSerieSeason season = ResponseInfoSerieSeason();
            if (contain.isNotEmpty) {
              seasons.forEach((element) {
                if (element.seasonNumber == contWhile) {
                  season = element;
                }
              });
            } else {
              season = ResponseInfoSerieSeason(
                  id: 0,
                  name: "null",
                  airDate: "null",
                  cover: "null",
                  coverBig: "null",
                  episodeCount: episode.length,
                  overview: "null",
                  seasonNumber: contWhile);
            }
            listaSeason.add(ListSeason(season: season, episodes: episode));
            contWhile = contWhile + 1;
          } else {
            break;
          }
        }
        ResponseInfoSerieAll? serie =
            ResponseInfoSerieAll(episodes: listaSeason, info: infoSerie);
        return serie;
      }
    } catch (e) {
      return ResponseInfoSerieAll();
    }
  }

  //get all series
  Future<List<ResponseCategorySeries>?> getAllSeries(
      url, username, password) async {
    var response = await http.get(Uri.parse(url +
        'player_api.php?username=' +
        username +
        '&password=' +
        password +
        '&action=get_series'));
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body) as List;
      List<ResponseCategorySeries> lista =
          responseData.map((e) => ResponseCategorySeries.fromJson(e)).toList();
      return lista;
    } else {
      print("ERROR...");
      return null;
    }
  }
}
