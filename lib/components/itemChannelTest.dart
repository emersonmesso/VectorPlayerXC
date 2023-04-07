import 'package:flutter/material.dart';
import '../models/ResponseChannelAPI.dart';
import '../pages/channels/VideoPlayerPage.dart';
import 'ItemMove.dart';

class ItemChannel extends StatelessWidget {
  const ItemChannel({Key? key, required this.data}) : super(key: key);
  final ResponseChannelAPI data;
  @override
  Widget build(BuildContext context) {
    return ItemMove(
      corBorda: Colors.white,
      isCategory: true,
      callback: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  VideoPlayerPageM3U8(
              channel: data,
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                data.name!,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
