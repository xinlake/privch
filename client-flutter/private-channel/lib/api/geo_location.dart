import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeoLocationService {
  final String url;
  final String keyCountry;
  final String keyRegion;
  final String keyCity;

  /// https://freeipapi.com
  /// 60/minute
  GeoLocationService.freeIpAip(String ip)
      : url = "https://freeipapi.com/api/json/$ip",
        keyCountry = "countryCode",
        keyRegion = "regionName",
        keyCity = "cityName";

  /// http://ip-api.com
  /// 45/minus
  GeoLocationService.ipApi(String ip)
      : url = "http://ip-api.com/json/$ip",
        keyCountry = "country",
        keyRegion = "regionName",
        keyCity = "city";

  /// http://ipinfo.io
  /// 50k/month
  GeoLocationService.ipInfo(String ip)
      : url = "http://ipinfo.io/$ip/json",
        keyCountry = "country",
        keyRegion = "region",
        keyCity = "city";

  // TODO proxy mode
  Future<String?> getGeoLocation() async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(
          utf8.decode(response.bodyBytes),
        ) as Map;

        final country = jsonBody[keyCountry] as String?;
        final region = jsonBody[keyRegion] as String?;
        final city = jsonBody[keyCity] as String?;

        var location = country ?? "";
        if (region != null && region.isNotEmpty) {
          location += " $region";
        }
        if (city != null && city.isNotEmpty) {
          location += " $city";
        }

        return location.trimLeft();
      } else if (response.statusCode == 204 ||
          response.statusCode == 301 ||
          response.statusCode == 429) {
        return "";
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    return null;
  }
}
