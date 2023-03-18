class ResponseChannelsAPI {
  String? categoryId;
  String? categoryName;
  int? parentId;

  ResponseChannelsAPI({this.categoryId, this.categoryName, this.parentId});

  ResponseChannelsAPI.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    parentId = json['parent_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['parent_id'] = this.parentId;
    return data;
  }
}
