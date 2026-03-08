import 'package:poswork/app/app.dart';
import 'package:poswork/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
