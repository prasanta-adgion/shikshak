import 'bootstrap.dart';
import 'core/flavor/app_flavor.dart';

/// Default entrypoint, so a bare `flutter run` still works. It targets the
/// development flavor — release builds should use an explicit entrypoint:
///   flutter build apk -t lib/main_prod.dart --release
void main() => bootstrap(AppFlavor.dev);
