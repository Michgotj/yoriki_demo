import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightmachine/utils/constants.dart';

class AppStateController extends GetxService {
  RxDouble headerHeight = 15.0.obs;
  RxBool isFIFO = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadHeaderHeight();
    loadIsFIFO();
  }

  void loadHeaderHeight() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(HEADER_HEIGHT_PERCENT)) {
      double height = prefs.getDouble(HEADER_HEIGHT_PERCENT)!;
      headerHeight.value = height;
    }
  }

  void loadIsFIFO() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(IS_FIFO)) {
      bool boolValue = prefs.getBool(IS_FIFO)!;
      isFIFO.value = boolValue;
    }
  }

  void setHeaderHeight(double heightPercent) {
    headerHeight.value = heightPercent;
    if (heightPercent != 0) {
      _saveHeaderHeight(heightPercent);
    }
  }

  void changeIsFIFO() {
    isFIFO.value = !isFIFO.value;
    _saveIsFIFO();
  }

  void _saveHeaderHeight(double heightPercent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(HEADER_HEIGHT_PERCENT, heightPercent);
  }

  void _saveIsFIFO() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IS_FIFO, isFIFO.value);
  }
}
