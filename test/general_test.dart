
import 'package:flutter_test/flutter_test.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';

void main(){
  test("Copying data No.1", () {
    String one = "teststring";
    String two = Copy.copy(one);
    one = "teststring2";
    expect(two, equals("teststring"));

  });

  test("Copying data No.2", () {
    String one = "teststring";
    String two = Copy.copy(one);
    two = "teststring2";
    expect(one, equals("teststring"));
  });

  test("Copying data No.3", () {
    int one = 4;
    int two = Copy.copy(one);
    two++;
    expect(one, equals(4));
  });
}