import 'dart:math';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:ntp/ntp.dart';

class TOTPGenerator {
  final String secret;
  final int interval;
  final int digits;
  final String algorithm;

  TOTPGenerator({
    required this.secret,
    this.interval = 30,
    this.digits = 6,
    this.algorithm = 'SHA1',
  });

  /// Gera o código TOTP atual utilizando tempo sincronizado via NTP
  Future<String> now() async {
    try {
      final DateTime synchronizedTime = await NTP.now();
      final int unixTime = synchronizedTime.millisecondsSinceEpoch ~/ 1000;
      return generate(unixTime);
    } catch (e) {
      print("TOTPGenerator: Erro ao obter tempo via NTP: $e");
      final int unixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return generate(unixTime);
    }
  }

  /// Gera o código TOTP para um timestamp específico
  String generate(int timestamp) {
    final counter = timestamp ~/ interval;

    final bytes = _intToBytes(counter);

    final key = base32.decode(secret.replaceAll(' ', '').toUpperCase());

    Hmac hmac;
    switch (algorithm.toUpperCase()) {
      case 'SHA1':
        hmac = Hmac(sha1, key);
        break;
      case 'SHA256':
        hmac = Hmac(sha256, key);
        break;
      case 'SHA512':
        hmac = Hmac(sha512, key);
        break;
      default:
        throw ArgumentError('Algoritmo não suportado: $algorithm');
    }

    final hash = hmac.convert(bytes).bytes;

    final offset = hash.last & 0x0F;
    final binary = ((hash[offset] & 0x7F) << 24) |
        ((hash[offset + 1] & 0xFF) << 16) |
        ((hash[offset + 2] & 0xFF) << 8) |
        (hash[offset + 3] & 0xFF);

    final otp = binary % pow(10, digits).toInt(); // Correção aqui

    return otp.toString().padLeft(digits, '0');
  }

  /// Converte um inteiro para um byte array de 8 bytes (big endian)
  Uint8List _intToBytes(int value) {
    final bytes = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xFF;
      value = value >> 8;
    }
    return bytes;
  }
}
