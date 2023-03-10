import 'package:chat_sample_app/core/widgets/shimmers/home_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chat_sample_app/core/constants/colors_manager.dart';
import 'package:chat_sample_app/core/routes/routes_manager.dart';
import 'package:chat_sample_app/core/widgets/loading_widget.dart';
import 'package:chat_sample_app/firebase/fb_auth_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_chats_controller.dart';
import 'package:chat_sample_app/firebase/fb_firestore_users_controller.dart';
import 'package:chat_sample_app/get/controllers/app/home_screen_controller.dart';
import 'package:chat_sample_app/models/chat.dart';
import 'package:chat_sample_app/models/chat_user.dart';
import 'package:chat_sample_app/screens/core/search_users_screen.dart';
import 'package:chat_sample_app/utils/view_logout_dialog.dart';
import 'package:chat_sample_app/utils/my_data.dart';
import 'package:chat_sample_app/utils/show_snackbar.dart';
import 'package:chat_sample_app/utils/time_date_send.dart';
import 'package:chat_sample_app/firebase/fb_notifications.dart';
import 'package:chat_sample_app/utils/view_profile_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, FbNotifications {
  final controller = Get.find<HomeScreenController>();
  // late StreamBuilder<QuerySnapshot<Chat>> myStream;
  @override
  void initState() {
    requestNotificationPermissions();
    WidgetsBinding.instance.addObserver(this);
    if (myID != '0') {
      FbFireStoreUsersController().updateMyOnlineStatus(true);
    }
    super.initState();
  }

  @override
  void dispose() {
    FbFireStoreUsersController().updateMyOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await FbFireStoreUsersController().updateMyOnlineStatus(true);
    } else {
      await FbFireStoreUsersController().updateMyOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Chats'),
            actions: [
              IconButton(
                onPressed: () async {
                  showSearch(context: context, delegate: SearchUsersScreen());
                },
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              setState(() {});
            }
          },
          drawer: SafeArea(
            child: Drawer(
              backgroundColor: ColorsManager.bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.horizontal(
                    end: Radius.circular(80.sp)),
              ),
              child: ListView(
                children: [
                  FutureBuilder<ChatUser?>(
                      future: FbFireStoreUsersController().getPeerDetails(myID),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          ChatUser myData = snapshot.data!;
                          return UserAccountsDrawerHeader(
                            accountName: Text(myData.name),
                            accountEmail: Text(myData.email),
                            currentAccountPicture: CircleAvatar(
                              radius: 40.r,
                              backgroundColor: ColorsManager.white,
                              backgroundImage: myData.image != null
                                  ? NetworkImage(myData.image!)
                                  : const AssetImage('assets/images/avatar.png')
                                      as ImageProvider,
                            ),
                            decoration: const BoxDecoration(
                              color: ColorsManager.purble,
                            ),
                          );
                        } else {
                          return UserAccountsDrawerHeader(
                            accountName: Text(myName ?? ''),
                            accountEmail: Text(myEmail),
                            currentAccountPicture: CircleAvatar(
                              radius: 40.r,
                              backgroundColor: ColorsManager.white,
                            ),
                            decoration: const BoxDecoration(
                              color: ColorsManager.purble,
                            ),
                          );
                        }
                      }),
                  InkWell(
                    onTap: () {
                      Get.toNamed(RoutesManager.profileScreen);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.manage_accounts_rounded),
                      title: Text('My Profile'),
                    ),
                  ),
                  Visibility(
                    visible: FirebaseAuth.instance.currentUser?.providerData
                            .first.providerId ==
                        'password',
                    child: InkWell(
                      onTap: () async {
                        Get.toNamed(RoutesManager.changePasswordScreen);
                      },
                      child: const ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change Password'),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Get.toNamed(RoutesManager.messageRequestsScreen);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.forum_rounded),
                      title: const Text('Messaging Requests'),
                      trailing: StreamBuilder<QuerySnapshot<Chat>>(
                          stream: FbFireStoreChatsController()
                              .fetchChats(ChatStatus.waiting.name),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!.docs.isNotEmpty) {
                              controller.counterMessagingRequests(
                                  snapshot.data!.docs.length);
                              for (int i = 0;
                                  i < snapshot.data!.docs.length;
                                  i++) {
                                if (snapshot.data!.docs[i].data().createdBy ==
                                        myID ||
                                    snapshot.data!.docs[i]
                                        .data()
                                        .lastMessageText
                                        .trim()
                                        .isEmpty) {
                                  controller.counterMessagingRequests.value--;
                                }
                              }
                              return controller
                                          .counterMessagingRequests.value !=
                                      0
                                  ? CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor: ColorsManager.green,
                                      foregroundColor: ColorsManager.white,
                                      child: Text(
                                          '${controller.counterMessagingRequests.value}'),
                                    )
                                  : const Text('');
                            } else {
                              return const Text('');
                            }
                          }),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      viewLogoutDialog(
                          context: context,
                          message: 'Are you sure?',
                          content: 'You are about to log out.',
                          onConfirm: () async {
                            Get.back();
                            controller.isLoggingOut(true);
                            await _performLogout();
                          });
                    },
                    child: const ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Container(
            margin: EdgeInsets.only(bottom: 30.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.r),
              gradient: const LinearGradient(
                colors: ColorsManager.purbleGradient,
              ),
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () {
                Get.toNamed(RoutesManager.allContactsScreen);
              },
              child: const Icon(
                Icons.chat_rounded,
                color: ColorsManager.white,
              ),
            ),
          ),
          body: StreamBuilder<QuerySnapshot<Chat>>(
            stream: FbFireStoreChatsController()
                .fetchChats(ChatStatus.accepted.name),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(40.w, 30.h, 0, 30.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequent contacts',
                        style: TextStyle(
                          color: ColorsManager.hintColor,
                          fontSize: 25.sp,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      SizedBox(
                        height: 160.h,
                        child: ListView.separated(
                          padding: EdgeInsetsDirectional.only(end: 40.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Chat chatData = snapshot.data!.docs[index].data();
                            String peerId = chatData.getPeerId();
                            return StreamBuilder<QuerySnapshot<ChatUser>>(
                              stream: FbFireStoreUsersController()
                                  .readPeerData(peerId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!.docs.isNotEmpty) {
                                  final peer = snapshot.data!.docs.first.data();
                                  return InkWell(
                                    onTap: () async {
                                      Get.toNamed(
                                        RoutesManager.chatScreen,
                                        arguments: {
                                          'chat': chatData,
                                          'peer': peer,
                                        },
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment:
                                              AlignmentDirectional.bottomEnd,
                                          children: [
                                            CircleAvatar(
                                              radius: 50.r,
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
                                            CircleAvatar(
                                              backgroundColor: peer.online
                                                  ? ColorsManager.green
                                                  : ColorsManager.grey,
                                              radius: 12.r,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 130.w,
                                          child: Text(
                                            peer.name,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Text('');
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 25.w),
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Text(
                        'Recent conversations',
                        style: TextStyle(
                          color: ColorsManager.hintColor,
                          fontSize: 25.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsetsDirectional.only(end: 40.w),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Chat chatData = snapshot.data!.docs[index].data();
                            String peerId = chatData.getPeerId();
                            final String myPeer = getMyPeer(chatData.createdBy);
                            return StreamBuilder<QuerySnapshot<ChatUser>>(
                                stream: FbFireStoreUsersController()
                                    .readPeerData(peerId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    final peer =
                                        snapshot.data!.docs.first.data();
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            Get.toNamed(
                                              RoutesManager.chatScreen,
                                              arguments: {
                                                'chat': chatData,
                                                'peer': peer,
                                              },
                                            );
                                          },
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            minVerticalPadding: 40.h,
                                            horizontalTitleGap: 40.w,
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                      timeSend(int.tryParse(chatData
                                                              .lastMessageTime) ??
                                                          0),
                                                      style: TextStyle(
                                                        color: ColorsManager
                                                            .hintColor,
                                                        fontSize: 18.sp,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    Icon(
                                                      Icons.schedule_rounded,
                                                      size: 22.r,
                                                      color: ColorsManager
                                                          .hintColor,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            subtitle: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10.h),
                                                child: ((myPeer ==
                                                                'is_peer1_typing' &&
                                                            chatData
                                                                .isPeer2Typing) ||
                                                        chatData.isPeer1Typing)
                                                    ? Text(
                                                        'typing ...',
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          color: ColorsManager
                                                              .green,
                                                        ),
                                                      )
                                                    : Text(
                                                        chatData
                                                            .lastMessageText,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          color: ColorsManager
                                                              .hintColor,
                                                        ),
                                                      )),
                                            leading: InkWell(
                                              onTap: () => viewProfile(
                                                  partner: peer,
                                                  context: context),
                                              child: Stack(
                                                alignment: AlignmentDirectional
                                                    .bottomEnd,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        ColorsManager.white,
                                                    backgroundImage: peer.image
                                                                ?.isNotEmpty ??
                                                            false
                                                        ? NetworkImage(
                                                            peer.image!)
                                                        : const AssetImage(
                                                                'assets/images/avatar.png')
                                                            as ImageProvider,
                                                    radius: 50.r,
                                                  ),
                                                  CircleAvatar(
                                                    backgroundColor: peer.online
                                                        ? ColorsManager.green
                                                        : ColorsManager.grey,
                                                    radius: 12.r,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return HomeShimmer(
                    enabled:
                        snapshot.connectionState == ConnectionState.waiting);
              }
            },
          ),
        ),
        Obx(() => Visibility(
              visible: controller.isLoggingOut.value,
              child: const LoadingWidget(),
            )),
      ],
    );
  }

  Future<void> _performLogout() async {
    await FbAuthController().signOut();
    controller.isLoggingOut(false);
    Get.offAllNamed(RoutesManager.loginScreen);
    showSnackbar(message: 'Logged out successfully');
  }
}
