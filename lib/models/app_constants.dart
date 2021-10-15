

import 'package:flutter/foundation.dart';

const String client_id = '7461675f68785f69e65';
const String client_secret = '746167626f6e645f686966785f6970686f6';

const String mapboxKey =
    'pk.eyJ1IjoiamF5YXN1cnlhIiwiYSI6ImNrZmg3cHZ2ZzBsN2QycW1remZ3Y2lkaGkifQ.-cGTjG9LOZ-0xKkGg4KfmA';
const String stripePublishableKeyTest =
    'pk_test_51Hc4egCpMQbvFPPiJB3UEtABdD6iFOKB4CT9V8jYSGslVa27hTjhkw2FQRrW6U6XdW8g8l9iJ8EFyosKlnLxRLGi00n74ARCxS';
const String stripePublishableKeyLive =
    'pk_live_51Hc4egCpMQbvFPPifaKkQAplFDNqcgb1TKfEEKxxTGux4eDiT10vm3JhSIwzGHFCrafxnY91oQLZ0x2JSlHee9oA00PRuXtRPS';

String accessToken;
String refreshToken;

String deviceId;
String deviceName;
String appName;

Map liveTokenData;
DateTime demoStartTime;

String appHomeMode = 'normal'; //normal,usersite,whitelabel,module
String siteOwner;
bool businessOwner = false;

String activeModule;

String _flavor = 'production'; //production or development

setDevelopmentFlavor() {
  _flavor = 'development';
}

setProductionFlavor() {
  _flavor = 'production';
}

String getChatServerUrl() => "https://chat.tagcash.com/";

String getServer() {
  if (_flavor == 'development') {
    return 'beta';
  } else {
    return 'live';
  }
}

String getServerPath() {
  if (_flavor == 'development') {
    return 'https://apibeta.tagcash.com/';
  } else {
    return 'https://api.tagcash.com/';
  }
}

String getUserImagePath() {
  if (_flavor == 'development') {
    return 'https://apibeta.tagcash.com/public/userImage/';
  } else {
    return 'https://api.tagcash.com/public/userImage/';
  }
}

String getCommunityImagePath() {
  if (_flavor == 'development') {
    return 'https://apibeta.tagcash.com/public/communityImage/';
  } else {
    return 'https://api.tagcash.com/public/communityImage/';
  }
}

String getScaReturnUrl() {
  return kIsWeb ? 'https://www.tagcash.com' : 'tagcash://www.tagcash.com';
}

String getCryptoWalletServerPath() {
  if (_flavor == 'development') {
    return 'https://testnet.tagbond.com/api/v1/';
  } else {
    return 'https://tagbond.com/api/v1/';
  }
}

String getBTCAPIURL() {
  if (_flavor == 'development') {
    return 'https://api.blockcypher.com/v1/btc/test3/';
  } else {
    return 'https://api.blockcypher.com/v1/btc/main/';
  }
}

String getETHAPIURL() {
  if (_flavor == 'development') {
    return 'http://18.211.191.88:8545/';
  } else {
    return 'http://18.211.191.88:8545/';
  }
}
