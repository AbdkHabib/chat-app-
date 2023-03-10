import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_sample_app/firebase/fb_auth_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_users_controller.dart';
import 'package:chat_sample_app/firebase/fb_helper.dart';
import 'package:chat_sample_app/firebase/fb_storage_controller.dart';
import 'package:chat_sample_app/models/chat_user.dart';
import 'package:chat_sample_app/utils/my_data.dart';
import 'package:chat_sample_app/utils/show_snackbar.dart';

class ProfileScreenController extends GetxController with FbHelper {
  final nameController = TextEditingController().obs;
  final bioController = TextEditingController().obs;
  XFile? pickedImage;
  ImagePicker imagePicker = ImagePicker();
  String? url;
  bool isReady = false;

  final formKey = GlobalKey<FormState>();
  final isEditedProfile = false.obs;

  @override
  void onReady() async {
    await getMyData().then((value) {
      myData = value;
      url = value.image;
      isReady = true;
      update();
    });
    nameController(TextEditingController(text: myData?.name));
    bioController(TextEditingController(text: myData?.bio));
    super.onReady();
  }

  Future<void> pickImage() async {
    XFile? img = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (img != null) {
      pickedImage = img;
      update();
    }
  }

  Future<void> uploadImage() async {
    try {
      TaskSnapshot taskSnapshot =
          await FbStorageController().upload(file: File(pickedImage!.path));
      if (taskSnapshot.state == TaskState.success) {
        url = await taskSnapshot.ref.getDownloadURL();
        await FbFireStoreUsersController().updateMyImage(url!);
        await FbAuthController().currentUser?.updatePhotoURL(url);
        update();
      }
    } on FirebaseException catch (e) {
      showSnackbar(message: e.message ?? '', success: false);
    } catch (e) {
      showSnackbar(message: e.toString(), success: false);
    }
  }
}

ChatUser? myData;

Future<ChatUser> getMyData() async {
  final docRef = FirebaseFirestore.instance
      .collection("Users")
      .doc(myID)
      .withConverter<ChatUser>(
        fromFirestore: (snapshot, options) =>
            ChatUser.fromJson(snapshot.data()!),
        toFirestore: (value, options) => value.toJson(),
      );
  final docSnap = await docRef.get();
  final chatUser = docSnap.data();
  return chatUser!;
}
