import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:chat_sample_app/core/constants/colors_manager.dart';
import 'package:chat_sample_app/core/widgets/message_card.dart';
import 'package:chat_sample_app/core/widgets/typing_indicator.dart';
import 'package:chat_sample_app/core/widgets/text_field_widget.dart';
import 'package:chat_sample_app/firebase/fb_firestore_chats_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_messages_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_users_controller.dart';
import 'package:chat_sample_app/firebase/fb_notifications.dart';
import 'package:chat_sample_app/models/chat.dart';
import 'package:chat_sample_app/models/chat_message.dart';
import 'package:chat_sample_app/models/chat_user.dart';
import 'package:chat_sample_app/models/notification_model.dart';
import 'package:chat_sample_app/utils/my_data.dart';
import 'package:chat_sample_app/utils/time_date_send.dart';
import 'package:chat_sample_app/utils/view_profile_dialog.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with FbNotifications {
  StreamController<String> streamController = StreamController();
  final TextEditingController messageController = TextEditingController();
  final Chat chat = Get.arguments['chat'];
  final ChatUser peer = Get.arguments['peer'];
  final String myPeer = getMyPeer(Get.arguments['chat'].createdBy);

  // final String myPeer =
  //     getMyPeer(Get.arguments['chat'].peer1.id, Get.arguments['chat'].peer2.id);

  @override
  void initState() {
    super.initState();
    streamController.stream.debounce(const Duration(seconds: 3)).listen((s) {
      FbFireStoreChatsController().updateMyTypingStatus(
          isTyping: false, chatId: chat.id, myPeer: myPeer);
    });
  }

  @override
  void dispose() {
    messageController.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (chat.lastMessageText.isEmpty) {
          FbFireStoreChatsController().deleteChat(chat.id);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => viewProfile(partner: peer, context: context),
                child: Text(peer.name),
              ),
              SizedBox(
                height: 5.h,
              ),
              StreamBuilder(
                stream: FbFireStoreChatsController().fetchChat(chat.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return ((myPeer == 'is_peer1_typing' &&
                                chat.isPeer2Typing) ||
                            chat.isPeer1Typing)
                        ? Text(
                            'typing ...',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: ColorsManager.green,
                            ),
                          )
                        : StreamBuilder<QuerySnapshot<ChatUser>>(
                            stream: FbFireStoreUsersController()
                                .readPeerData(peer.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                return snapshot.data!.docs.first.data().online
                                    ? Text(
                                        'online',
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          color: ColorsManager.green,
                                        ),
                                      )
                                    : Text(
                                        'offline',
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          color: ColorsManager.hintColor,
                                        ),
                                      );
                              } else {
                                return const Text('');
                              }
                            });
                  } else {
                    return const Text('');
                  }
                },
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              color: ColorsManager.purble,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              onSelected: (value) {
                viewProfile(partner: peer, context: context);
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'view_profile',
                    child: Text('View user profile'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(40.w, 0.h, 40.w, 30.h),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<ChatMessage>>(
                  stream: FbFireStoreMessagesController()
                      .fetchChatMessages(chat.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData &&
                        snapshot.data!.docs.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GroupedListView<
                                QueryDocumentSnapshot<ChatMessage>, String>(
                              reverse: true,
                              order: GroupedListOrder.DESC,
                              elements: snapshot.data!.docs,
                              sort: false,
                              groupSeparatorBuilder: (value) =>
                                  Center(child: Text(value)),
                              groupBy: (element) =>
                                  dateSend(element.data().sentAt),
                              padding: EdgeInsets.symmetric(vertical: 30.h),
                              itemBuilder: (context, element) {
                                return Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(top: 20.h),
                                  child: Row(
                                    mainAxisAlignment: element.data().sentByMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: !element.data().sentByMe,
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.only(
                                              end: 20.w),
                                          child: CircleAvatar(
                                            radius: 40.r,
                                            backgroundColor:
                                                ColorsManager.white,
                                            backgroundImage: peer
                                                        .image?.isNotEmpty ??
                                                    false
                                                ? NetworkImage(peer.image!)
                                                : const AssetImage(
                                                        'assets/images/avatar.png')
                                                    as ImageProvider,
                                          ),
                                        ),
                                      ),
                                      MessageCard(
                                        isMe: element.data().sentByMe,
                                        message: element.data().message,
                                        date: element.data().sentAt,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          StreamBuilder(
                            stream:
                                FbFireStoreChatsController().fetchChat(chat.id),
                            builder: (context, snapshot) {
                              return (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty)
                                  ? TypingIndicator(
                                      showIndicator:
                                          (myPeer == 'is_peer1_typing')
                                              ? snapshot.data!.docs.first
                                                  .data()
                                                  .isPeer2Typing
                                              : snapshot.data!.docs.first
                                                  .data()
                                                  .isPeer1Typing,
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text('NO CHATS'),
                      );
                    }
                  },
                ),
              ),
              Divider(
                color: ColorsManager.dividerColor,
                thickness: 2,
                height: 40.h,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: TextFieldWidget(
                      controller: messageController,
                      hintText: 'Type a message...',
                      isChatField: true,
                      textInputAction: TextInputAction.send,
                      onChange: (value) {
                        FbFireStoreChatsController().updateMyTypingStatus(
                            isTyping: true, chatId: chat.id, myPeer: myPeer);
                        streamController.add(value);
                      },
                      onEditingComplete: () {
                        FbFireStoreChatsController().updateMyTypingStatus(
                            isTyping: false, chatId: chat.id, myPeer: myPeer);
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _performSendMessage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.textFieldColor,
                      ),
                      icon: Icon(
                        Icons.send_rounded,
                        size: 28.r,
                      ),
                      label: Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _checkData() {
    return messageController.text.trim().isNotEmpty;
  }

  void _performSendMessage() async {
    if (_checkData()) {
      bool sent = await FbFireStoreMessagesController().sendMessage(message);
      chat.lastMessageText = messageController.text.trim();
      sendNotification(notificationModel: notificationModel);
      FbFireStoreChatsController().updateMyTypingStatus(
          isTyping: false, chatId: chat.id, myPeer: myPeer);
      if (sent) {
        messageController.clear();
      }
    }
  }

  ChatMessage get message {
    ChatMessage message = ChatMessage();
    message.chatId = chat.id;
    message.message = messageController.text.trim();
    message.senderId = myID;
    message.receiverId = chat.getPeerId();
    message.sentAt = DateTime.now().millisecondsSinceEpoch.toString();
    return message;
  }

  NotificationModel get notificationModel {
    NotificationModel notificationModel = NotificationModel();
    notificationModel.to = peer.fcmToken;
    notificationModel.notification = NotificationData.fromJson({
      'title': myName,
      'body': message.message,
      'image': myImage,
    });
    return notificationModel;
  }
}
