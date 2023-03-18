import 'dart:convert';
import 'package:apptv/models/ListM3U8/ResponseListM3U8Channel.dart';
import 'package:hive_flutter/hive_flutter.dart';

class M3U8DAO {

  //buscando as categorias de canais
  Future<List<ResponseListM3U8Channel>?> getChannels() async {
    var box = await Hive.openBox("boxContentList");
    var data = await box.get("channelsList");
    if (data != null) {
      var dados = jsonDecode(data) as List;
      List<ResponseListM3U8Channel> lista =
          dados.map((e) => ResponseListM3U8Channel.fromJson(e)).toList();
      return lista;
    } else {
      return null;
    }
  }

  //buscando as categorias de filmes
  Future<List<ResponseListM3U8Channel>?> getMovies() async {
    var box = await Hive.openBox("boxContentList");
    var data = await box.get("moviesList");
    if (data != null) {
      var dados = jsonDecode(data) as List;
      List<ResponseListM3U8Channel> lista =
      dados.map((e) => ResponseListM3U8Channel.fromJson(e)).toList();
      return lista;
    } else {
      return null;
    }
  }
}
