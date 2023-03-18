import 'package:flutter/material.dart';

import '../pages/Home.dart';

class ItemMenuEsquerdo extends StatelessWidget {
  const ItemMenuEsquerdo({Key? key, required this.assets, required this.name, required this.isFocused}) : super(key: key);
  final String assets;
  final String name;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black87,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Icon(
              Icons.home,
              size: 50,
              color: Colors.white,
            ),
            Text(name, style: TextStyle(color: Colors.white),),
          ],
        ),
      ),
    );
  }
}
