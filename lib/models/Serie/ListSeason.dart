import 'package:apptv/models/Serie/ResponseInfoSerieEpisode.dart';
import 'package:apptv/models/Serie/ResponseInfoSerieSeason.dart';

class ListSeason {
  ResponseInfoSerieSeason? season;
  List<ResponseInfoSerieEpisode>? episodes;

  ListSeason({
    this.season,
    this.episodes
});
}