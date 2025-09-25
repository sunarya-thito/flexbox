import 'package:demo/main.dart';

void main() {
  // assuming that the layout visuallly looks correct
  // this function will generate the test code for performTest()
  // based on the actual layout
  // although the process is automated,
  // the result still needs to be verified manually
  for (var testCase in testCases) {
    testCase.generateTest();
  }
}
