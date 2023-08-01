import 'dart:async';

import 'package:flutter/material.dart';

import 'input_helper.dart';

typedef CaretMoved = void Function(Offset globalCaretPosition);
typedef TextChanged = void Function(String text);

// Helper widget to track caret position.
class TrackingTextInput extends StatefulWidget {
  const TrackingTextInput({
    required this.enable,
    required this.label,
    required this.focusNode,
    required this.controller,
    this.suffixIcon,
    this.onCaretMoved,
    this.onTextChanged,
    this.isObscured = false,
    Key? key,
  }) : super(key: key);
  final CaretMoved? onCaretMoved;
  final TextChanged? onTextChanged;

  final String label;
  final FocusNode focusNode;
  final bool isObscured;
  final bool enable;
  final TextEditingController controller;

  final Widget? suffixIcon;

  @override
  TrackingTextInputState createState() => TrackingTextInputState();
}

class TrackingTextInputState extends State<TrackingTextInput> {
  final GlobalKey _fieldKey = GlobalKey();
  Timer? _debounceTimer;

  @override
  initState() {
    widget.controller.addListener(() {
      // We debounce the listener as sometimes the caret position is updated after the listener
      // this assures us we get an accurate caret position.
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        if (_fieldKey.currentContext != null) {
          // Find the render editable in the field.
          final RenderObject? fieldBox = _fieldKey.currentContext!.findRenderObject();
          Offset? caretPosition;
          if (fieldBox != null) {
            caretPosition = getCaretPosition(fieldBox as RenderBox);
          }

          if (widget.onCaretMoved != null) {
            if (caretPosition != null) {
              widget.onCaretMoved!(caretPosition);
            }
          }
        }
      });
      if (widget.onTextChanged != null) {
        widget.onTextChanged!(widget.controller.text);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      focusNode: widget.focusNode,
      // style: const TextStyle(fontSize: 16.0),
      enabled: widget.enable,
      keyboardType: widget.isObscured ? TextInputType.text : TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.label,
        contentPadding: EdgeInsets.all(20),
        suffixIcon: widget.suffixIcon,
      ),
      obscuringCharacter: '*',
      controller: widget.controller,
      obscureText: widget.isObscured,
    );
  }
}
