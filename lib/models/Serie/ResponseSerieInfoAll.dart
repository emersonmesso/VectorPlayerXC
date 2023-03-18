import 'package:apptv/models/Serie/ListSeason.dart';
import 'package:apptv/models/Serie/ResponseInfoSerieInfo.dart';

class ResponseInfoSerieAll {
  ResponseInfoSerieInfo? info;
  List<ListSeason>? episodes;

  ResponseInfoSerieAll({
    this.info,
    this.episodes
});
}