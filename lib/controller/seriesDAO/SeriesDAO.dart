import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/ResponseCategorySeries.dart';
import '../../models/Serie/ResponseFavouriteSeire.dart';
import '../../models/Serie/ResponseSerieWatch.dart';

class SeriesDAO {
  Future<List<ResponseCategorySeries>?> getListFavouritesSeries(url) async {
    final prefs = await SharedPreferences.getInstance();
    var response = prefs.getString("favouritesSeries");
    if (response != null) {
      var dados = jsonDecode(response) as List;
      List<ResponseFavouriteSerie> listaCheia =
          dados.map((e) => ResponseFavouriteSerie.fromJson(e)).toList();
      List<ResponseCategorySeries>? listaNova = <ResponseCategorySeries>[];
      listaCheia.forEach((element) {
        if (element.url == url) {
          listaNova?.add(element.serie!);
        }
      });
      return listaNova;
    } else {
      //não tem dados
      //cria uma lista vazia
      List<ResponseCategorySeries> listaVazia = <ResponseCategorySeries>[];
      //convertendo a lista em JSON
      var convert = listaVazia.map((e) => e.toJson()).toList();
      await prefs.setString("favouritesSeries", jsonEncode(convert).toString());
      return listaVazia;
    }
  }

  //save favorite
  Future<bool> saveFavorite(ResponseCategorySeries serie, url) async {
    final prefs = await SharedPreferences.getInstance();
    //buscando a lista salva
    var response = await prefs.getString("favouritesSeries");
    if (response != null) {
      //tem dados
      var dados = jsonDecode(response) as List;
      List<ResponseFavouriteSerie> listaCheia =
          dados.map((e) => ResponseFavouriteSerie.fromJson(e)).toList();

      //adicionando o novo canal na lista
      ResponseFavouriteSerie novoFavourite =
          ResponseFavouriteSerie(url: url, serie: serie);
      listaCheia.add(novoFavourite);

      var convert = listaCheia.map((e) => e.toJson()).toList();
      await prefs.setString("favouritesSeries", jsonEncode(convert).toString());
      print("FAVORITO SALVO");
      return true;
    } else {
      //não tem dados
      //cria uma lista vazia
      List<ResponseFavouriteSerie> listaVazia = <ResponseFavouriteSerie>[];
      //adiciona o canal na lista vazia
      ResponseFavouriteSerie novoFavourite =
          ResponseFavouriteSerie(url: url, serie: serie);
      listaVazia.add(novoFavourite);

      //convertendo a lista em JSON
      var convert = listaVazia.map((e) => e.toJson()).toList();
      await prefs.setString("favouritesSeries", jsonEncode(convert).toString());
      print("FAVORITO SALVO");
      return true;
    }
  }

  //verify is serie favourite
  Future<bool> IsFavourite(ResponseCategorySeries serie, url) async {
    final prefs = await SharedPreferences.getInstance();
    //buscando a lista salva
    var response = await prefs.getString("favouritesSeries");
    if (response != null) {
      //tem dados
      var dados = jsonDecode(response) as List;
      List<ResponseFavouriteSerie> listaCheia =
          dados.map((e) => ResponseFavouriteSerie.fromJson(e)).toList();
      bool isHere = false;
      listaCheia.forEach((element) {
        if ((element.serie?.seriesId == serie.seriesId) &&
            (url == element.url)) {
          isHere = true;
        }
      });
      print("É FAVORITO: " + isHere.toString());
      return isHere;
    } else {
      //não tem dados
      //cria uma lista vazia
      List<ResponseFavouriteSerie> listaVazia = <ResponseFavouriteSerie>[];

      //convertendo a lista em JSON
      var convert = listaVazia.map((e) => e.toJson()).toList();
      await prefs.setString("favouritesSeries", jsonEncode(convert).toString());
      print("FAVORITO SALVO");
      return false;
    }
  }

  //remove favorite
  Future<bool> removeFavourite(ResponseCategorySeries serie, url) async {
    final prefs = await SharedPreferences.getInstance();
    //buscando a lista salva
    var response = await prefs.getString("favouritesSeries");
    if (response != null) {
      //tem dados
      var dados = jsonDecode(response) as List;
      List<ResponseFavouriteSerie> listaCheia =
          dados.map((e) => ResponseFavouriteSerie.fromJson(e)).toList();
      //verificando o id do canal na lista
      int index = 0;
      int count = 0;
      listaCheia.forEach((element) {
        if ((element.serie?.seriesId == serie.seriesId) &&
            (element.url == url)) {
          index = count;
        }
        count++;
      });

      //removendo da lista
      listaCheia.removeAt(index);
      //salvando a lista nova
      var convert = listaCheia.map((e) => e.toJson()).toList();
      await prefs.setString("favouritesSeries", jsonEncode(convert).toString());
      return true;
    } else {
      return false;
    }
  }

  //get recents series
  Future<List<ResponseCategorySeries>?> getListRecentWath(url) async {
    final prefs = await SharedPreferences.getInstance();
    //buscando a lista salva
    var response = await prefs.getString("recentsSeries");
    if (response != null) {
      //tem dados
      var dados = jsonDecode(response) as List;
      List<ResponseSerieWatch> listaCheia =
          dados.map((e) => ResponseSerieWatch.fromJson(e)).toList();
      //verificando se o favorito é do servidor
      List<ResponseCategorySeries>? listaNova = <ResponseCategorySeries>[];
      listaCheia.forEach((element) {
        if (element.url == url) {
          listaNova?.add(element.serie!);
        }
      });
      listaNova = listaNova.reversed.toList();
      //adicionando o novo canal na lista
      return listaNova;
    } else {
      List<ResponseCategorySeries>? listaNova = <ResponseCategorySeries>[];
      var convert = listaNova.map((e) => e.toJson()).toList();
      await prefs.setString("recentsSeries", jsonEncode(convert).toString());
      return listaNova;
    }
  }

  //set recentes Series wath
  Future<bool> saveRecentSerie(ResponseCategorySeries serie, url) async {
    final prefs = await SharedPreferences.getInstance();
    //buscando a lista salva
    var response = await prefs.getString("recentsSeries");
    if (response != null) {
      //tem dados
      var dados = jsonDecode(response) as List;
      List<ResponseSerieWatch> listaCheia =
          dados.map((e) => ResponseSerieWatch.fromJson(e)).toList();

      //verifica se o canal não foi o útimo assistido
      if (listaCheia[listaCheia.length - 1].serie?.seriesId != serie.seriesId) {
        //adicionando o novo canal na lista
        ResponseSerieWatch novoFavourite =
            ResponseSerieWatch(serie: serie, url: url);
        listaCheia.add(novoFavourite);
        //verifica o total de listas salvas
        if (listaCheia.length > 10) {
          //remove o ultimo adicionado
          listaCheia.removeAt(0);
        }
        var convert = listaCheia.map((e) => e.toJson()).toList();
        await prefs.setString("recentsSeries", jsonEncode(convert).toString());
        print("Recente Salvo!");
        return true;
      } else {
        return false;
      }
    } else {
      //não tem dados
      //cria uma lista vazia
      List<ResponseSerieWatch> listaVazia = <ResponseSerieWatch>[];
      //adiciona o canal na lista vazia
      ResponseSerieWatch novoFavourite =
          ResponseSerieWatch(url: url, serie: serie);
      listaVazia.add(novoFavourite);

      //convertendo a lista em JSON
      var convert = listaVazia.map((e) => e.toJson()).toList();
      await prefs.setString("recentsSeries", jsonEncode(convert).toString());
      print("Recente Salvo!");
      return true;
    }
  }

  //SALVANDO OS DADOS DAS SÉRIES ASSISTIDAS

}
