import 'package:flutter/material.dart';

class AnsiParser {
  static const pTEXT = 0, pBRACKET = 1, pCODE = 2;

  final bool dark;

  AnsiParser(this.dark);

  Color? foreground;
  Color? background;
  List<TextSpan> spans = [];

  void parse(String s) {
    spans = [];
    var state = pTEXT;
    StringBuffer? buffer;
    var text = StringBuffer();
    var code = 0;
    List<int> codes = [];

    for (var i = 0, n = s.length; i < n; i++) {
      var c = s[i];

      switch (state) {
        case pTEXT:
          if (c == '\u001b') {
            state = pBRACKET;
            buffer = StringBuffer(c);
            code = 0;
            codes = [];
          } else {
            text.write(c);
          }
          break;

        case pBRACKET:
          buffer?.write(c);
          if (c == '[') {
            state = pCODE;
          } else {
            state = pTEXT;
            text.write(buffer);
          }
          break;

        case pCODE:
          buffer?.write(c);
          var codeUnit = c.codeUnitAt(0);
          if (codeUnit >= 48 && codeUnit <= 57) {
            code = code * 10 + codeUnit - 48;
            continue;
          } else if (c == ';') {
            codes.add(code);
            code = 0;
            continue;
          } else {
            if (text.isNotEmpty) {
              spans.add(createSpan(text.toString()));
              text.clear();
            }
            state = pTEXT;
            if (c == 'm') {
              codes.add(code);
              handleCodes(codes);
            } else {
              text.write(buffer);
            }
          }

          break;
      }
    }

    spans.add(createSpan(text.toString()));
  }

  void handleCodes(List<int> codes) {
    if (codes.isEmpty) {
      codes.add(0);
    }

    switch (codes[0]) {
      case 0:
        foreground = getColor(0, true);
        background = getColor(0, false);
        break;
      case 38:
        foreground = getColor(codes[2], true);
        break;
      case 39:
        foreground = getColor(0, true);
        break;
      case 48:
        background = getColor(codes[2], false);
        break;
      case 49:
        background = getColor(0, false);
    }
  }

  Color? getColor(int colorCode, bool foreground) {
    switch (colorCode) {
      case 0:
        return foreground ? Colors.black : Colors.transparent;
      case 12:
        return dark ? Colors.blue[300] : Colors.blue[700];
      case 208:
        return dark ? Colors.orange[300] : Colors.orange[700];
      case 196:
        return dark ? Colors.red[300] : Colors.red[700];
      case 199:
        return dark ? Colors.pink[300] : Colors.pink[700];
      case 244:
        return dark ? Colors.lightBlue[300] : Colors.lightBlue[700];
    }
    return null;
  }

  TextSpan createSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: foreground,
        backgroundColor: background,
      ),
    );
  }
}
