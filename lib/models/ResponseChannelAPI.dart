class ResponseFavourite {
  String? url;
  ResponseChannelAPI? channel;
  ResponseFavourite(
      this.url,
      this.channel
      );

  ResponseFavourite.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    channel = json['channel'] != null ? ResponseChannelAPI.fromJson(json['channel']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    if (this.channel != null) {
      data['channel'] = this.channel!.toJson();
    }
    return data;
  }
}

class ResponseChannelAPI {
  int? num;
  String? name;
  String? epg_channel_id;
  String? streamType;
  int? streamId;
  String? streamIcon;
  String? categoryId;

  ResponseChannelAPI(
      {
        this.num,
        this.name,
        this.epg_channel_id,
        this.streamType,
        this.streamId,
        this.streamIcon,
        this.categoryId}
      );

  ResponseChannelAPI.fromJson(Map<String, dynamic> json) {
    num = json['num'];
    name = json['name'];
    epg_channel_id = json['epg_channel_id'];
    streamType = json['stream_type'];
    streamId = json['stream_id'];
    streamIcon = json['stream_icon'];
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['num'] = this.num;
    data['name'] = this.name;
    data['epg_channel_id'] = this.epg_channel_id;
    data['stream_type'] = this.streamType;
    data['stream_id'] = this.streamId;
    data['stream_icon'] = this.streamIcon;
    data['category_id'] = this.categoryId;
    return data;
  }
}
