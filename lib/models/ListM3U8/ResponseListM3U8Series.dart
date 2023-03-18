class ResponseListM3U8Series {
  String? title;
  List<SeassonsSerie>? seassons;

  ResponseListM3U8Series({this.title, this.seassons});

  ResponseListM3U8Series.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    seassons = json['seassons'] != null ? (json['seassons'] as List).map((e) => SeassonsSerie.fromJson(e)).toList() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['seassons'] = this.seassons!.map((e) => e.toJson()).toList();
    return data;
  }
}

class SeassonsSerie {
  String? title;
  int? seasson;
  List<EpisodesSerie>? episodes;

  SeassonsSerie({this.title, this.seasson, this.episodes});

  SeassonsSerie.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    seasson = json['seasson'];
    episodes = (json['episodes'] != null) ? (json['episodes'] as List).map((e) => EpisodesSerie.fromJson(e)).toList() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['seasson'] = this.seasson;
    if (this.episodes != null) {
      data['episodes'] = this.episodes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EpisodesSerie {
  String? title;
  int? episode;
  String? logo;
  String? url;

  EpisodesSerie({this.title, this.episode, this.logo, this.url});

  EpisodesSerie.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    episode = json['episode'];
    logo = json['logo'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['episode'] = this.episode;
    data['logo'] = this.logo;
    data['url'] = this.url;
    return data;
  }
}
