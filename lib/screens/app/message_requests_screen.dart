import 'package:chat_sample_app/utils/time_date_send.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chat_sample_app/core/constants/colors_manager.dart';
import 'package:chat_sample_app/core/routes/routes_manager.dart';
import 'package:chat_sample_app/core/widgets/loading_widget.dart';
import 'package:chat_sample_app/core/widgets/no_data_widget.dart';
import 'package:chat_sample_app/firebase/fb_firestore_chats_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_messages_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_users_controller.dart';
import 'package:chat_sample_app/get/controllers/app/home_screen_controller.dart';
import 'package:chat_sample_app/models/chat.dart';
import 'package:chat_sample_app/models/chat_user.dart';
import 'package:chat_sample_app/utils/my_data.dart';
import 'package:chat_sample_app/utils/show_snackbar.dart';

class MessageRequestsScreen extends GetView<HomeScreenController> {
  const MessageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging Requests'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.forum_rounded),
                Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Text(
                    'Messaging requests from other Type Users',
                    style: TextStyle(
                      fontSize: 25.sp,
                    ),
                  ),
                ),
                Transform(
                    alignment: AlignmentDirectional.center,
                    transform: Matrix4.rotationY(3.14),
                    child: const Icon(Icons.forum_rounded)),
              ],
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Chat>>(
                stream: FbFireStoreChatsController()
                    .fetchChats(ChatStatus.waiting.name),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.docs.isNotEmpty &&
                      controller.counterMessagingRequests.value != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Chat chatData = snapshot.data!.docs[index].data();
                        String peerId = chatData.getPeerId();
                        if (chatData.createdBy != myID &&
                            chatData.lastMessageText.trim().isNotEmpty) {
                          return FutureBuilder<ChatUser?>(
                              future: FbFireStoreUsersController()
                                  .getPeerDetails(peerId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final peer = snapshot.data!;
                                  return Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        minVerticalPadding: 0,
                                        horizontalTitleGap: 40.w,
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              peer.name,
                                              style: TextStyle(
                                                fontSize: 25.sp,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  timeSend(int.tryParse(
                                                          chatData.createdAt) ??
                                                      0),
                                                  style: TextStyle(
                                                    color:
                                                        ColorsManager.hintColor,
                                                    fontSize: 18.sp,
                                                  ),
                                                ),
                                                SizedBox(width: 10.w),
                                                Icon(
                                                  Icons.schedule_rounded,
                                                  size: 22.r,
                                                  color:
                                                      ColorsManager.hintColor,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: ColorsManager.white,
                                          backgroundImage: peer
                                                      .image?.isNotEmpty ??
                                                  false
                                              ? NetworkImage(peer.image!)
                                              : const AssetImage(
                                                      'assets/images/avatar.png')
                                                  as ImageProvider,
                                          radius: 40.r,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              bool success =
                                                  await _performAccept(
                                                      chatData.id);
                                              if (success) {
                                                Get.back();
                                                Get.offAndToNamed(
                                                  RoutesManager.chatScreen,
                                                  arguments: {
                                                    'chat': chatData,
                                                    'peer': peer,
                                                  },
                                                );
                                              } else {
                                                showSnackbar(
                                                    message:
                                                        'Something went wrong!! Try again later.');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    ColorsManager.green,
                                                fixedSize:
                                                    Size(Get.width / 4, 60.h)),
                                            child: const Text('Accept'),
                                          ),
                                          SizedBox(width: 20.w),
                                          OutlinedButton(
                                            onPressed: () async {
                                              bool success =
                                                  await _performReject(
                                                      chatData.id);
                                              if (success) {
                                                await FbFireStoreMessagesController()
                                                    .deleteRejectedChatMessages(
                                                        chatData.id);
                                                await FbFireStoreChatsController()
                                                    .deleteChat(chatData.id);
                                              } else {
                                                showSnackbar(
                                                    message:
                                                        'Something went wrong!! Try again later.');
                                              }
                                            },
                                            child: const Text('Reject'),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: ColorsManager.dividerColor,
                                        thickness: 2,
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Text('');
                                }
                              });
                        } else {
                          return const Text('');
                        }
                      },
                    );
                  } else {
                    return snapshot.connectionState == ConnectionState.waiting
                        ? const LoadingWidget()
                        : const NoDataWidget(message: 'No Messaging Requests');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _performAccept(String chatId) async {
    return await FbFireStoreChatsController()
        .updateChatStatus(ChatStatus.accepted.name, chatId);
  }

  Future<bool> _performReject(String chatId) async {
    return await FbFireStoreChatsController()
        .updateChatStatus(ChatStatus.rejected.name, chatId);
  }
}
