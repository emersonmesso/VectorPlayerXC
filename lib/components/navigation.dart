import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const String keyUp = 'Arrow Up';
const String keyDown = 'Arrow Down';
const String keyLeft = 'Arrow Left';
const String keyRight = 'Arrow Right';
const String keyCenter = 'Select';

class DpadNavigation extends StatefulWidget {
  final Function onClick;
  final Function(bool isFocused) onFocus;
  final Widget child;

  const DpadNavigation({
    Key? key,
    required this.onClick,
    required this.child,
    required this.onFocus,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DpadNavigationState();
  }
}

class DpadNavigationState extends State<DpadNavigation> {
  List<FocusNode> focusNodes = [];
  late FocusNode node;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    node = FocusNode();
  }

  void _handleFocusChange() {
    focusNodes.clear();
    if (node.hasFocus == false) {
      setState(() {
        isFocused = false;
      });
    }
  }

  @override
  void dispose() {
    node.removeListener(_handleFocusChange);
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: node,
      onKey: (RawKeyEvent event) {
        setState(() {
          isFocused = !isFocused;
        });
        widget.onFocus(isFocused);
        if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
          switch (event.logicalKey.keyLabel) {
            case keyCenter:
              widget.onClick();
              setState(() {
                isFocused = !isFocused;
              });
              break;
            case keyUp:
              break;
            case keyDown:
              break;
            default:
              break;
          }
        }
      },
      child: widget.child,
    );
  }
}
