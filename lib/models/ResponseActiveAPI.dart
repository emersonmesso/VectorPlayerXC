class ResponseActiveApi {
  UserInfo? userInfo;
  ServerInfo? serverInfo;

  ResponseActiveApi({required this.userInfo, required this.serverInfo});

  ResponseActiveApi.fromJson(Map<String, dynamic> json) {
    userInfo = (json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'])
        : null)!;
    serverInfo = (json['server_info'] != null
        ? new ServerInfo.fromJson(json['server_info'])
        : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userInfo != null) {
      data['user_info'] = this.userInfo!.toJson();
    }
    if (this.serverInfo != null) {
      data['server_info'] = this.serverInfo!.toJson();
    }
    return data;
  }
}

class UserInfo {
  String? username;
  String? password;
  String? message;
  int? auth;
  String? status;
  String? expDate;
  String? isTrial;
  String? maxConnections;

  UserInfo(
      {
        required this.username,
        required this.password,
        required this.message,
        required this.auth,
        required this.status,
        required this.expDate,
        required this.isTrial,
        required this.maxConnections});

  UserInfo.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
    message = json['message'];
    auth = json['auth'];
    status = json['status'];
    expDate = json['exp_date'];
    isTrial = json['is_trial'];
    maxConnections = json['max_connections'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['password'] = this.password;
    data['message'] = this.message;
    data['auth'] = this.auth;
    data['status'] = this.status;
    data['exp_date'] = this.expDate;
    data['is_trial'] = this.isTrial;
    data['max_connections'] = this.maxConnections;
    return data;
  }
}

class ServerInfo {
  String? version;

  ServerInfo({required this.version});

  ServerInfo.fromJson(Map<String, dynamic> json) {
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    return data;
  }
}
