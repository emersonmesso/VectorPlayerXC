class ResponseStorageAPI {
  int? id;
  int? active;
  String? name;
  String? url;
  String? username;
  String? password;
  int? list_type;

  ResponseStorageAPI({this.id, this.active, this.name, this.url, this.username, this.password, this.list_type});

  ResponseStorageAPI.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    active = json['active'];
    name = json['name'];
    url = json['url'];
    username = json['username'];
    password = json['password'];
    list_type = json['list_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['active'] = this.active;
    data['name'] = this.name;
    data['url'] = this.url;
    data['username'] = this.username;
    data['password'] = this.password;
    data['list_type'] = this.list_type;
    return data;
  }
}
