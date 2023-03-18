import 'package:flutter/material.dart';

import 'navigation.dart';

class ItemMove extends StatefulWidget {
  const ItemMove(
      {Key? key,
      required this.callback,
      required this.child,
      required this.isCategory,
      required this.corBorda,
      })
      : super(key: key);
  final Function callback;
  final Widget child;
  final bool isCategory;
  final Color corBorda;

  @override
  State<ItemMove> createState() => _ItemMoveState();
}

class _ItemMoveState extends State<ItemMove> {
  bool hasChange = false;
  late FocusNode node;
  late Color corBorda;

  @override
  void initState() {
    node = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onFocusChange: (focus){
        setState(() {
          hasChange = focus;
        });
      },
      onTap: () {
        widget.callback();
      },
      child: Container(
        padding: EdgeInsets.all((widget.isCategory) ? 0 : 10.0),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular((widget.isCategory) ? 5.0 : 25.0),
          border: Border.all(
            color: hasChange ? widget.corBorda : Colors.transparent,
            width: (widget.isCategory) ? 2 : 5,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
