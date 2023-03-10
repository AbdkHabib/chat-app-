import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chat_sample_app/core/constants/colors_manager.dart';
import 'package:chat_sample_app/core/routes/routes_manager.dart';
import 'package:chat_sample_app/core/widgets/loading_widget.dart';
import 'package:chat_sample_app/core/widgets/no_data_widget.dart';
import 'package:chat_sample_app/firebase/fb_firestore_chats_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_users_controller.dart';
import 'package:chat_sample_app/models/chat.dart';
import 'package:chat_sample_app/models/chat_user.dart';
import 'package:chat_sample_app/screens/core/search_users_screen.dart';
import 'package:chat_sample_app/utils/my_data.dart';
import 'package:chat_sample_app/utils/view_message_request_dialog.dart';

class AllContactsScreen extends StatelessWidget {
  const AllContactsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Contact'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: SearchUsersScreen());
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<ChatUser>>(
          stream: FbFireStoreUsersController().readUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.fromLTRB(40.w, 0.h, 40.w, 30.h),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.people_alt_rounded,
                        size: 42.r,
                      ),
                      horizontalTitleGap: 0,
                      title: Text(
                        'All contacts in Type',
                        style: TextStyle(
                          fontSize: 25.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final peer = snapshot.data!.docs[index].data();
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
                              minVerticalPadding: 35.h,
                              horizontalTitleGap: 40.w,
                              title: Text(
                                peer.name,
                                style: TextStyle(
                                  fontSize: 26.sp,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: Text(
                                  peer.bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: ColorsManager.hintColor,
                                  ),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: ColorsManager.white,
                                backgroundImage: peer.image?.isNotEmpty ?? false
                                    ? NetworkImage(peer.image!)
                                    : const AssetImage(
                                            'assets/images/avatar.png')
                                        as ImageProvider,
                                radius: 50.r,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.fromLTRB(40.w, 0.h, 40.w, 30.h),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.people_alt_rounded,
                        size: 40.r,
                      ),
                      horizontalTitleGap: 0,
                      title: Text(
                        'All contacts in Type',
                        style: TextStyle(
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const LoadingWidget()
                          : const NoDataWidget(
                              message: 'No Contacts Yet!!',
                            ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
