import 'package:apptv/models/ResponseCategorySeries.dart';

class ResponseFavouriteSerie{
  String? url;
  ResponseCategorySeries? serie;
  ResponseFavouriteSerie({
    this.url,
    this.serie
});

  ResponseFavouriteSerie.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    serie = json['serie'] != null ? ResponseCategorySeries.fromJson(json['serie']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    if (this.serie != null) {
      data['serie'] = this.serie!.toJson();
    }
    return data;
  }
}