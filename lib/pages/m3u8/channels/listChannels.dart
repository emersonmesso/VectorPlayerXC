import 'package:flutter/material.dart';

import '../../../controller/M3U8/m3u8DAO.dart';
import '../../../models/ListM3U8/ResponseListM3U8Channel.dart';
import 'itemChannel.dart';

class ListChannelsScreen extends StatefulWidget {
  const ListChannelsScreen({Key? key, required this.channels, required this.title})
      : super(key: key);
  final List<ListChannels>? channels;
  final String title;

  @override
  State<ListChannelsScreen> createState() => _ListChannelsScreenState();
}

class _ListChannelsScreenState extends State<ListChannelsScreen> {
  late List<ListChannels>? channels;
  late M3U8DAO m3u8dao = M3U8DAO();

  @override
  void initState() {
    channels = widget.channels;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          childAspectRatio: (4 / 1),
          children: List.generate(channels!.length, (index) {
            return ItemChannelM3U8(
              channel: channels![index],
            );
          }),
        ),
      ),
    );
  }
}
