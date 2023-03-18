import 'package:apptv/models/ResponseCategorySeries.dart';

class SerieWatching {
  String? url;
  ResponseCategorySeries? serie;
  List<SerieEpisodeWatch>? watching;

  SerieWatching({this.serie, this.url, this.watching});

  SerieWatching.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    watching = (json['watching'] as List)
        .map((e) => SerieEpisodeWatch.fromJson(e))
        .toList();
    serie = ResponseCategorySeries.fromJson(json['serie']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['watching'] = this.watching!.map((e) => e.toJson()).toList();
    data['serie'] = this.serie!.toJson();
    data['url'] = this.url;
    return data;
  }
}

class SerieEpisodeWatch {
  int? episodeNum;
  String? title;
  int? season;
  bool? complete;
  int? exit;

  SerieEpisodeWatch(
      {this.title, this.episodeNum, this.season, this.complete, this.exit});

  SerieEpisodeWatch.fromJson(Map<String, dynamic> json) {
    season = json['season'];
    episodeNum = int.parse(json['episode_num'].toString());
    title = json['title'];
    complete = json['complete'];
    exit = json['exit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['episode_num'] = this.episodeNum;
    data['title'] = this.title;
    data['season'] = this.season;
    data['complete'] = this.complete;
    data['exit'] = this.exit;
    return data;
  }
}
