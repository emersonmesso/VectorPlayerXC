class ResponseEPG {
  String? id;
  String? epgId;
  String? title;
  String? lang;
  String? start;
  String? end;
  String? description;
  String? channelId;
  String? startTimestamp;
  String? stopTimestamp;
  String? stop;

  ResponseEPG(
      {this.id,
        this.epgId,
        this.title,
        this.lang,
        this.start,
        this.end,
        this.description,
        this.channelId,
        this.startTimestamp,
        this.stopTimestamp,
        this.stop});

  ResponseEPG.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    epgId = json['epg_id'];
    title = json['title'];
    lang = json['lang'];
    start = json['start'];
    end = json['end'];
    description = json['description'];
    channelId = json['channel_id'];
    startTimestamp = json['start_timestamp'];
    stopTimestamp = json['stop_timestamp'];
    stop = json['stop'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['epg_id'] = this.epgId;
    data['title'] = this.title;
    data['lang'] = this.lang;
    data['start'] = this.start;
    data['end'] = this.end;
    data['description'] = this.description;
    data['channel_id'] = this.channelId;
    data['start_timestamp'] = this.startTimestamp;
    data['stop_timestamp'] = this.stopTimestamp;
    data['stop'] = this.stop;
    return data;
  }
}
