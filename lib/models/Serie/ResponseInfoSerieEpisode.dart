import 'dart:convert';

class ResponseInfoSerieEpisode {
  String? id;
  int? episodeNum;
  String? title;
  String? containerExtension;
  Info? info;
  String? customSid;
  String? added;
  int? season;
  String? directSource;

  ResponseInfoSerieEpisode(
      {this.id,
      this.episodeNum,
      this.title,
      this.containerExtension,
      this.info,
      this.customSid,
      this.added,
      this.season,
      this.directSource});

  ResponseInfoSerieEpisode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    episodeNum = int.parse(json['episode_num'].toString());
    title = json['title'];
    containerExtension = json['container_extension'];
    info = json['info'] is List ? null : Info.fromJson(json['info']);
    //info = json['info'] != null ? Info.fromJson( json['info']) : null;
    //info = null;
    customSid = json['custom_sid'];
    added = json['added'];
    season = json['season'];
    directSource = json['direct_source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['episode_num'] = this.episodeNum;
    data['title'] = this.title;
    data['container_extension'] = this.containerExtension;
    if (this.info != null) {
      data['info'] = this.info!.toJson();
    }
    data['custom_sid'] = this.customSid;
    data['added'] = this.added;
    data['season'] = this.season;
    data['direct_source'] = this.directSource;
    return data;
  }
}

class Info {
  String? tmdbId;
  String? releasedate;
  String? plot;
  String? duration;
  String? movieImage;

  Info(
      {this.tmdbId,
      this.releasedate,
      this.plot,
      this.duration,
      this.movieImage});

  Info.fromJson(Map<String, dynamic> json) {
    tmdbId = (json['tmdb_id'] == null) ? "0" : json['tmdb_id'].toString();
    releasedate = (json['releasedate'] == null) ? "null" : json['releasedate'];
    plot = (json['plot'] == null) ? "null" : json['plot'];
    duration = (json['duration'] == null) ? "null" : json['duration'];
    movieImage = (json['movie_image'] == null) ? "null" : json['movie_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tmdb_id'] = this.tmdbId;
    data['releasedate'] = this.releasedate;
    data['plot'] = this.plot;
    data['duration'] = this.duration;
    data['movie_image'] = this.movieImage;
    return data;
  }
}
