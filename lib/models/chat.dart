// import 'package:chat_sample_app/models/chat_user.dart';
import 'package:chat_sample_app/utils/my_data.dart';

enum ChatStatus { waiting, accepted, rejected }

class Chat {
  late String id;
  // late ChatUser peer1;
  // late ChatUser peer2;
  // late String peer1;
  // late String peer2;
  late List<String> peers;
  late String createdBy;
  late String createdAt;
  String lastMessageText = "";
  String lastMessageTime = "";
  String? chatStatus;
  bool isPeer1Typing = false;
  bool isPeer2Typing = false;
  Chat();

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '-1';
    // peer1 = ChatUser.fromJson(json['peer1']);
    // peer2 = ChatUser.fromJson(json['peer2']);
    // peer1 = json['peer1'];
    // peer2 = json['peer2'];
    peers = List<String>.from(json['peers']);
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    lastMessageText = json['last_message_text'];
    lastMessageTime = json['last_message_time'];
    chatStatus = json['chat_status'];
    isPeer1Typing = json['is_peer1_typing'];
    isPeer2Typing = json['is_peer2_typing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    // data['peer1'] = peer1.toJson();
    // data['peer2'] = peer2.toJson();
    // data['peer1'] = peer1;
    // data['peer2'] = peer2;
    data['peers'] = peers;
    data['created_by'] = createdBy;
    data['created_at'] = DateTime.now().millisecondsSinceEpoch.toString();
    data['last_message_text'] = lastMessageText;
    data['last_message_time'] = lastMessageTime;
    data['chat_status'] = chatStatus;
    data['is_peer1_typing'] = isPeer1Typing;
    data['is_peer2_typing'] = isPeer2Typing;

    return data;
  }

  String getPeerId() {
    return peers.firstWhere((element) => element != myID);
  }
}
