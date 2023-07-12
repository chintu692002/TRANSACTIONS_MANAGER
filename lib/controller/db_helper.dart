import 'package:hive/hive.dart';
import 'package:money_manager/add_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbHelper {
  late Box box;
  late SharedPreferences preferences;
  DbHelper() {
    openBox();
  }
  openBox() {
    box = Hive.box('money');
  }

  Future deleteData(int index) async {
    await box.deleteAt(index);
  }

  Future addData(int amount, DateTime date, String note, String type) async {
    var value = {'amount': amount, 'date': date, 'type': type, 'note': note};
    box.add(value);
  }

  Future<Map> fetch() {
    if (box.values.isEmpty) {
      return Future.value({});
    } else {
      return Future.value(box.toMap());
    }
  }

  addName(String name) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('name', name);
  }

  getName() async {
    preferences = await SharedPreferences.getInstance();
    return preferences.getString('name');
  }
}
