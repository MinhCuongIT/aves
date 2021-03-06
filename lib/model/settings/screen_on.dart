import 'package:screen/screen.dart';

enum KeepScreenOn { never, fullscreenOnly, always }

extension ExtraKeepScreenOn on KeepScreenOn {
  String get name {
    switch (this) {
      case KeepScreenOn.never:
        return 'Never';
      case KeepScreenOn.fullscreenOnly:
        return 'Viewer page only';
      case KeepScreenOn.always:
        return 'Always';
      default:
        return toString();
    }
  }

  void apply() {
    Screen.keepOn(this == KeepScreenOn.always);
  }
}
