import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> getChatGptReplay({required String message}) async {
  final cloudFunctions = FirebaseFunctions.instance;

  try {
    final result = await cloudFunctions.httpsCallable("chatGpt").call({
      "message": message,
    });
    return result.data['replay'];
  } on FirebaseException catch (exe) {
    return "Error $exe";
  }
}
