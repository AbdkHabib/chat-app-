import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chat_sample_app/core/constants/colors_manager.dart';
import 'package:chat_sample_app/core/routes/routes_manager.dart';
import 'package:chat_sample_app/firebase/fb_firestore_chats_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_users_controller.dart';
import 'package:chat_sample_app/models/chat.dart';

import 'package:chat_sample_app/models/chat_user.dart';
import 'package:chat_sample_app/utils/my_data.dart';
import 'package:chat_sample_app/utils/view_message_request_dialog.dart';

class SearchUsersScreen extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Column();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot<ChatUser>>(
      stream: FbFireStoreUsersController().readUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final listOfSnapshotUser = snapshot.data!.docs;
          List<ChatUser> listOfUserChat = listOfSnapshotUser
              .where(
                (chatUser) {
                  return query.isNotEmpty &&
                      chatUser
                          .data()
                          .name
                          .toLowerCase()
                          .startsWith(query.toLowerCase());
                },
              )
              .toList()
              .map((e) => e.data())
              .toList();
          if (listOfUserChat.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.fromLTRB(40.w, 0.h, 40.w, 30.h),
              child: ListView.builder(
                itemCount: listOfUserChat.length,
                itemBuilder: (context, index) {
                  final peer = listOfUserChat[index];
                  return InkWell(
                    onTap: () async {
                      Chat chat = await FbFireStoreChatsController()
                          .manageChat(peer.id);
                      if (chat.chatStatus == ChatStatus.waiting.name &&
                          chat.createdBy != myID) {
                        viewMessageRequest(
                            chat: chat, peer: peer, context: context);
                      } else {
                        Get.toNamed(
                          RoutesManager.chatScreen,
                          arguments: {
                            'chat': chat,
                            'peer': peer,
                          },
                        );
                      }
                    },
                    child: ListTile(
                      minVerticalPadding: 40.h,
                      horizontalTitleGap: 40.w,
                      title: Text(
                        peer.name,
                        style: TextStyle(
                          fontSize: 25.sp,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text(
                          peer.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: ColorsManager.hintColor,
                          ),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundImage: peer.image?.isNotEmpty ?? false
                            ? NetworkImage(peer.image!)
                            : const AssetImage('assets/images/avatar.png')
                                as ImageProvider,
                        radius: 50.r,
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (query.isEmpty) {
            return Center(
              child: Text(
                "write contact name ..",
                style: TextStyle(
                  fontSize: 40.sp,
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                "No Contacts Found !",
                style: TextStyle(
                  fontSize: 40.sp,
                ),
              ),
            );
          }
        } else {
          return Center(
            child: Text(
              "No Contacts Found !",
              style: TextStyle(
                fontSize: 40.sp,
              ),
            ),
          );
        }
      },
    );
  }
}
