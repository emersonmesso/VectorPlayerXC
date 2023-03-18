class ResponseMoviesCategory {
  String? name;
  String? streamType;
  int? streamId;
  String? streamIcon;
  String? categoryId;
  String? containerExtension;

  ResponseMoviesCategory(
      {this.name,
        this.streamType,
        this.streamId,
        this.streamIcon,
        this.categoryId,
        this.containerExtension});

  ResponseMoviesCategory.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    streamType = json['stream_type'];
    streamId = json['stream_id'];
    streamIcon = json['stream_icon'];
    categoryId = json['category_id'];
    containerExtension = json['container_extension'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['stream_type'] = this.streamType;
    data['stream_id'] = this.streamId;
    data['stream_icon'] = this.streamIcon;
    data['category_id'] = this.categoryId;
    data['container_extension'] = this.containerExtension;
    return data;
  }
}
