import 'package:flutter_test/flutter_test.dart';

import 'v1_populate.dart';

void main() async {
  test("description", () => {expectAsync0(() => populateDummyData())});
}
