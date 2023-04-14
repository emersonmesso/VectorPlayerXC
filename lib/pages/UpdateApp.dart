import 'package:apptv/components/ItemMove.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateApp extends StatefulWidget {
  const UpdateApp({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  State<UpdateApp> createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  late Uri _url;

  @override
  void initState() {
    // TODO: implement initState
    _url = Uri.parse(widget.url);
    super.initState();
  }

  Future<void> launchLink(String url, {bool isNewTab = true}) async {
    if (!await launchUrl(
      _url,
      mode: isNewTab ? LaunchMode.externalApplication : LaunchMode.inAppWebView,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("lib/assets/logo1.png"),
              const SizedBox(
                height: 40,
              ),
              const Text(
                "Existe uma atualização do aplicativo!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ItemMove(
                callback: () {
                  launchLink(widget.url, isNewTab: true);
                },
                isCategory: false,
                corBorda: Colors.red,
                child: Container(
                  width: 500,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Atualizar",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.red,
                      ),
                    ),
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
