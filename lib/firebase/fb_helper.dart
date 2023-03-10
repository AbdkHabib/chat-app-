import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_sample_app/models/process_response.dart';

mixin FbHelper {
  ProcessResponse get failureResponse =>
      ProcessResponse("Something went wrong!! try again later.", false);

  ProcessResponse getAuthExceptionResponse(FirebaseAuthException e) {
    return ProcessResponse(e.message ?? "", false);
  }
}
