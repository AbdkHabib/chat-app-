class NotificationModel {
  late String to;
  late NotificationData notification;

  NotificationModel();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['to'] = to;
    data['notification'] = notification.toJson();
    return data;
  }
}

class NotificationData {
  late String title;
  late String body;
  late String image;

  NotificationData();

  NotificationData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    image = json['image'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    data['image'] = image;
    return data;
  }
}
