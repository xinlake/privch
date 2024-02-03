import 'package:envied/envied.dart';

part 'privch.g.dart';

@Envied(path: '.privch')
final class PrivCh {
  @EnviedField(varName: 'APP_EMAIL')
  static const String appEmail = _PrivCh.appEmail;
  @EnviedField(varName: 'APP_PRIVACY_POLICY')
  static const String appPrivacyPolicy = _PrivCh.appPrivacyPolicy;

  @EnviedField(varName: 'CLIENT_IP_API')
  static const String clientIpApi = _PrivCh.clientIpApi;

  @EnviedField(varName: 'STORAGE_ENDPOINT')
  static const String storageEndpoint = _PrivCh.storageEndpoint;
  @EnviedField(varName: 'STORAGE_ED25519_PRIV')
  static const String storageEd25519Priv = _PrivCh.storageEd25519Priv;
  @EnviedField(varName: 'STORAGE_ED25519_PUB')
  static const String storageEd25519Pub = _PrivCh.storageEd25519Pub;
}
