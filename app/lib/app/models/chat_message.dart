// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatMessage {
  String id;
  String text;
  bool isSystem;
  ChatMessage({required this.id, required this.text, required this.isSystem});

  ChatMessage copyWith({String? id, String? text, bool? isSystem}) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'text': text, 'isSystem': isSystem};
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      text: map['text'] as String,
      isSystem: map['isSystem'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ChatMessage(id: $id, text: $text, isSystem: $isSystem)';

  @override
  bool operator ==(covariant ChatMessage other) {
    if (identical(this, other)) return true;

    return other.id == id && other.text == text && other.isSystem == isSystem;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ isSystem.hashCode;
}
