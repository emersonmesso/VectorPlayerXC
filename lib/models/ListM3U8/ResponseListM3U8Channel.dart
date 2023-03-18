class ResponseListM3U8Channel {
  String? title;
  List<ListChannels>? list;

  ResponseListM3U8Channel({this.title, this.list});

  ResponseListM3U8Channel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    list = json['list'] != null
        ? (json['list'] as List).map((e) => ListChannels.fromJson(e)).toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['list'] = this.list!.map((e) => e.toJson()).toList();
    return data;
  }
}

class ListChannels {
  String? title;
  String? category;
  String? logo;
  String? url;

  ListChannels({this.title, this.category, this.logo, this.url});

  ListChannels.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    category = json['category'];
    logo = json['logo'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['category'] = this.category;
    data['logo'] = this.logo;
    data['url'] = this.url;
    return data;
  }
}
