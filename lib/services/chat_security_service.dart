import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class ChatSecurityService {
  // A unique salt for TokN ecosystem. In a real production app, 
  // this should be stored securely or derived dynamically.
  static const _keyBase = "TokN_Secure_Chat_Ecosystem_2024_Key_Salt_1234567890"; 

  static String encryptMessage(String plainText, String? senderId, String? receiverId) {
    if (plainText.isEmpty) return plainText;
    
    try {
      final conversationId = _deriveConversationId(senderId, receiverId);
      final key = _deriveKey(conversationId);
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // Format: IV:EncryptedData
      return "${iv.base64}:${encrypted.base64}";
    } catch (e) {
      print("Encryption error: $e");
      return plainText;
    }
  }

  static String decryptMessage(String cipherText, String? senderId, String? receiverId) {
    if (!cipherText.contains(':')) return cipherText; // Likely not encrypted
    
    try {
      final parts = cipherText.split(':');
      if (parts.length != 2) return cipherText;
      
      final iv = IV.fromBase64(parts[0]);
      final conversationId = _deriveConversationId(senderId, receiverId);
      final key = _deriveKey(conversationId);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      
      return encrypter.decrypt(Encrypted.fromBase64(parts[1]), iv: iv);
    } catch (e) {
      print("Decryption error: $e");
      return "[Encrypted Message]";
    }
  }

  static String _deriveConversationId(String? id1, String? id2) {
    // Stable ID regardless of who is sender/receiver
    final ids = [id1 ?? "admin", id2 ?? "admin"];
    ids.sort();
    return ids.join("_");
  }

  static Key _deriveKey(String conversationId) {
    final bytes = utf8.encode(conversationId + _keyBase);
    final digest = sha256.convert(bytes);
    return Key(Uint8List.fromList(digest.bytes));
  }
}
