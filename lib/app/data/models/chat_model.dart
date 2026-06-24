class UserPublic {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  UserPublic({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  factory UserPublic.fromJson(Map<String, dynamic> json) {
    return UserPublic(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class FriendshipResponse {
  final String id;
  final String requesterId;
  final String addresseeId;
  final String status;
  final UserPublic? requester;
  final UserPublic? addressee;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  FriendshipResponse({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    this.requester,
    this.addressee,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory FriendshipResponse.fromJson(Map<String, dynamic> json) {
    return FriendshipResponse(
      id: json['id'],
      requesterId: json['requester_id'],
      addresseeId: json['addressee_id'],
      status: json['status'],
      requester: json['requester'] != null ? UserPublic.fromJson(json['requester']) : null,
      addressee: json['addressee'] != null ? UserPublic.fromJson(json['addressee']) : null,
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null ? DateTime.parse(json['last_message_time']).toLocal() : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class ChatListItem {
  final String friendshipId;
  final String friendId;
  final String friendName;
  final String status;
  final bool isRequester;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatListItem({
    required this.friendshipId,
    required this.friendId,
    required this.friendName,
    required this.status,
    required this.isRequester,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
}
