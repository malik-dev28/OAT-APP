import 'package:get/get.dart';

// Controller for state management
class HomeController extends GetxController {
  var firstName = ''.obs;
  var lastName = ''.obs;

  var selectedDate = DateTime.now();
  var date = DateTime.now().obs;
  void showFullName() {
    Get.snackbar(
      'Full Name',
      '${firstName.value} ${lastName.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
