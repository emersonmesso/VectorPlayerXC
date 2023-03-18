import 'package:apptv/components/ItemMove.dart';
import 'package:apptv/models/ResponseMoviesCategory.dart';
import 'package:apptv/pages/movies/MovieDetails.dart';
import 'package:flutter/material.dart';

class ItemMovie extends StatefulWidget {
  const ItemMovie({Key? key, required this.movie}) : super(key: key);
  final ResponseMoviesCategory movie;

  @override
  State<ItemMovie> createState() => _ItemMovieState();
}

class _ItemMovieState extends State<ItemMovie> {
  late ResponseMoviesCategory movie;

  @override
  void initState() {
    movie = widget.movie;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetails(movie: movie),
          ),
        );
      },
      child: ItemMove(
        corBorda: Colors.white,
        isCategory: true,
        callback: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetails(movie: movie),
            ),
          );
        },
        child: Container(
          width: 150.0,
          height: 300.0,
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              (movie.streamIcon != null)
                  ? SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.network(
                        movie.streamIcon!,
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            "lib/assets/logo.png",
                            fit: BoxFit.contain,
                            width: 40,
                            height: 40,
                          );
                        },
                      ),
                    )
                  : SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        "lib/assets/logo.png",
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,
                      ),
                    ),
              Center(
                child: Text(
                  movie.name!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
