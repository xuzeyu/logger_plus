part of '../logger_plus.dart';

class LogConsoleOnShake extends StatefulWidget {
  final Widget child;
  final bool dark;
  final bool debugOnly;
  final double? width;
  final Function(Widget logConsole)? onShare;

  const LogConsoleOnShake({
    super.key,
    required this.child,
    required this.dark,
    this.onShare,
    this.debugOnly = true,
    this.width,
  });

  @override
  State<LogConsoleOnShake> createState() => _LogConsoleOnShakeState();
}

class _LogConsoleOnShakeState extends State<LogConsoleOnShake> {
  ShakeDetector? _detector;
  bool _open = false;

  @override
  void initState() {
    super.initState();

    if (widget.debugOnly) {
      assert(() {
        _init();
        return true;
      }());
    } else {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  _init() {
    LogConsole.init(bufferSize: 1024);
    _detector ??= ShakeDetector(onPhoneShake: _openLogConsole);
    _detector?.startListening();
  }

  _openLogConsole() async {
    if (_open) return;

    _open = true;

    var logConsole = LogConsole(
      showCloseButton: true,
      dark: widget.dark,
      width: widget.width,
    );
    if (widget.onShare != null) {
      widget.onShare!(logConsole);
    } else {
      PageRoute route;
      if (Platform.isIOS) {
        route = CupertinoPageRoute(builder: (_) => logConsole);
      } else {
        route = MaterialPageRoute(builder: (_) => logConsole);
      }
      await Navigator.push(context, route);
    }
    _open = false;
  }

  @override
  void dispose() {
    _detector?.stopListening();
    super.dispose();
  }
}
