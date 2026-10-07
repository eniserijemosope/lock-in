import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAccount {
  final String name;
  final String email;
  final String salt;
  final String passwordHash;

  const LocalAccount({
    required this.name,
    required this.email,
    required this.salt,
    required this.passwordHash,
  });

  factory LocalAccount.fromJson(Map<String, dynamic> json) {
    return LocalAccount(
      name: json['name'] as String,
      email: json['email'] as String,
      salt: json['salt'] as String,
      passwordHash: json['passwordHash'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'salt': salt,
        'passwordHash': passwordHash,
      };
}

class LocalAccountStore {
  static const _accountKey = 'lock_in_local_account';

  static Future<LocalAccount?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_accountKey);
    if (value == null) return null;

    final json = jsonDecode(value) as Map<String, dynamic>;
    return LocalAccount.fromJson(json);
  }

  static Future<LocalAccount> create({
    required String name,
    required String email,
    required String password,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_accountKey);
    if (existing != null) {
      throw StateError('An account is already saved on this device.');
    }

    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    final account = LocalAccount(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      salt: salt,
      passwordHash: _hash(password, salt),
    );
    final saved = await preferences.setString(
      _accountKey,
      jsonEncode(account.toJson()),
    );
    if (!saved) {
      throw StateError('The account could not be saved on this device.');
    }
    return account;
  }

  static bool verifyPassword(LocalAccount account, String password) {
    return _hash(password, account.salt) == account.passwordHash;
  }

  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}
