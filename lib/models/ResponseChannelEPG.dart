class ResponseChannelEPG {
  String? sStart;
  String? sStop;
  String? sChannel;
  String? title;
  String? desc;

  ResponseChannelEPG(
      {this.sStart, this.sStop, this.sChannel, this.title, this.desc});

  ResponseChannelEPG.fromJson(Map<String, dynamic> json) {
    sStart = json['_start'];
    sStop = json['_stop'];
    sChannel = json['_channel'];
    title = json['title'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_start'] = this.sStart;
    data['_stop'] = this.sStop;
    data['_channel'] = this.sChannel;
    data['title'] = this.title;
    data['desc'] = this.desc;
    return data;
  }
}
