import 'package:flutter_test/flutter_test.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/start/app_link.dart';
import 'package:wundertolle_einkaufsliste/start/invite.dart';
import 'package:wundertolle_einkaufsliste/start/start_manager.dart';

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

  test("Link parsing No.1", () {
    String parsed = testOnOpenFromLink("https://wundertolle.einkaufsliste/?list=123456789&?inviter=User1");
    expect(parsed, equals("123456789 | User1"));
  });

  test("Link parsing No.2", () {
    String parsed = testOnOpenFromLink("https://wundertolle.einkaufsliste/?list=123456789&?inviter=");
    expect(parsed, equals("123456789 | "));
  });

  test("AppStart No.1", () {
    StartManager startManager = StartManager();
    startManager.addListener(StartEvent(requireLogin: true, callback: (s) {
      print("Event called");
      expect((s as Invitation).listID, equals("1234"));
    }));
    startManager.registerEvent(loadedMe: true);
    startManager.registerStartLink(Invitation("1234", "1234"));
  });

  test("AppStart No.2", () {
    StartManager startManager = StartManager();
    startManager.addListener(StartEvent(requireLogin: true, callback: (s) {
      print("Event called");
      expect((s as Invitation).listID, equals("1234"));
    }));
    startManager.registerStartLink(Invitation("1234", "1234"));
    startManager.registerEvent(loadedMe: true);
  });

  test("AppStart No.3", () {
    StartManager startManager = StartManager();
    startManager.addListener(StartEvent(requireLogin: true, requireAppLoad: true, callback: (s) {
      print("Event called"); // <- shouldn't happen!!!
      expect((s as Invitation).listID, equals("1234"));
    }));
    startManager.registerEvent(loadedMe: true);
    startManager.registerStartLink(Invitation("1234", "1234"));
  });
}