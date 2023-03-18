import 'ResponseMoviesCategory.dart';

class ResponseFavouriteMovies {
  String? url;
  ResponseMoviesCategory? movie;
  ResponseFavouriteMovies(
      this.url,
      this.movie
      );

  ResponseFavouriteMovies.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    movie = json['movie'] != null ? ResponseMoviesCategory.fromJson(json['movie']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    if (this.movie != null) {
      data['movie'] = this.movie!.toJson();
    }
    return data;
  }
}