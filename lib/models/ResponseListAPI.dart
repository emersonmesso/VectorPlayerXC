class ResponseListAPI {
  int? id;
  String? name;
  int? active;
  String? expire;
  int? idUsuario;
  String? url;
  String? username;
  String? password;
  int? list_type;

  ResponseListAPI(
      {this.id,
        this.name,
        this.active,
        this.expire,
        this.idUsuario,
        this.url,
        this.username,
        this.password,
        this.list_type
      });

  ResponseListAPI.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    active = json['active'];
    expire = json['expire'];
    idUsuario = json['id_usuario'];
    url = json['url'];
    username = json['username'];
    password = json['password'];
    list_type = json['list_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['active'] = this.active;
    data['expire'] = this.expire;
    data['id_usuario'] = this.idUsuario;
    data['url'] = this.url;
    data['username'] = this.username;
    data['password'] = this.password;
    data['list_type'] = this.list_type;
    return data;
  }
}