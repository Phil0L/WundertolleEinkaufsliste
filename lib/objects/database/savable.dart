import 'dart:math';

abstract class Savable<T>{

  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson();

}

class IDRandom{

  String _chars = '1234567890';
  Random _rnd = Random();

  String getSaltKeyID() {
    return DateTime.now().toString().replaceAll(new RegExp(r'[-:. ]*'), '') +
        _getRandomString(5);
  }

  String _getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

}