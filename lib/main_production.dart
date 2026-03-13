import 'package:poswork/app/app.dart';
import 'package:poswork/bootstrap.dart';

Future<void> main() async {
  await bootstraps(() async {
    return const App();
  });
}
