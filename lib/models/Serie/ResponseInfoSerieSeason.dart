class ResponseInfoSerieSeason {
  String? airDate;
  int? episodeCount;
  int? id;
  String? name;
  String? overview;
  int? seasonNumber;
  String? cover;
  String? coverBig;

  ResponseInfoSerieSeason(
      {this.airDate,
        this.episodeCount,
        this.id,
        this.name,
        this.overview,
        this.seasonNumber,
        this.cover,
        this.coverBig});

  ResponseInfoSerieSeason.fromJson(Map<String, dynamic> json) {
    airDate = json['air_date'];
    episodeCount = json['episode_count'];
    id = json['id'];
    name = json['name'];
    overview = json['overview'];
    seasonNumber = json['season_number'];
    cover = json['cover'];
    coverBig = json['cover_big'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['air_date'] = this.airDate;
    data['episode_count'] = this.episodeCount;
    data['id'] = this.id;
    data['name'] = this.name;
    data['overview'] = this.overview;
    data['season_number'] = this.seasonNumber;
    data['cover'] = this.cover;
    data['cover_big'] = this.coverBig;
    return data;
  }
}