class ChatUser {
  late String image;
  late String about;
  late String name;
  late String createdAt;
  late String id;
  late bool isOnline;
  late String lastActive;
  late String pushToken;
  late String email;

  ChatUser(
      {required this.image,
      required this.about,
      required this.name,
      required this.createdAt,
      required this.id,
      required this.isOnline,
      required this.lastActive,
      required this.pushToken,
      required this.email});

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['about'] = this.about;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['is_online'] = this.isOnline;
    data['last_active'] = this.lastActive;
    data['push_token'] = this.pushToken;
    data['email'] = this.email;
    return data;
  }
}
