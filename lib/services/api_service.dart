import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String apiKey = 'f84361484f994c79a77232206251106';

class WeatherApiService {
  final String _baseUrl = 'https://api.weatherapi.com/v1';

  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch data: ${res.body}');
    }
    final data = json.decode(res.body);

    if (data.containsKey('error')) {
      throw Exception(data['error']['message'] ?? 'Invalid location');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getPastSevenDaysWeather(
      String location,
      ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final date = today.subtract(Duration(days: i));
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';

      final url = Uri.parse(
        '$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data.containsKey('error')) {
          throw Exception(data['error']['message'] ?? 'Invalid location');
        }
        if (data['forecast']?['forecastday'] != null &&
            data['forecast']['forecastday'].isNotEmpty) {
          pastWeather.add(data);
        } else {
          debugPrint('Failed to fetch past data for $formattedDate: ${res.body}');
        }
      }
    }
    return pastWeather;
  }


  Future<Map<String, dynamic>> getCurrentLocationName(double lat, double lon) async {
    final url = 'http://api.weatherapi.com/v1/current.json?key=YOUR_API_KEY&q=$lat,$lon';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'name': data['location']['name'],
        'country': data['location']['country']
      };
    } else {
      throw Exception('Failed to get location name');
    }
  }
  Future<Map<String, dynamic>> getCurrentLocationWeather({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/current.json?key=$apiKey&q=$latitude,$longitude',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch current location weather: ${res.body}');
    }

    final data = json.decode(res.body);
    if (data.containsKey('error')) {
      throw Exception(data['error']['message'] ?? 'Invalid coordinates');
    }

    return data;
  }




  Future<Map<String, dynamic>> getHourlyForecastByCoordinates(double lat, double lon) async {
    final String apiUrl =
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lat,$lon&days=7&aqi=no&alerts=no';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<dynamic>> getPast7DaysWeatherByCoordinates(double lat, double lon) async {
    List<dynamic> pastWeather = [];

    for (int i = 1; i <= 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final String apiUrl =
          'http://api.weatherapi.com/v1/history.json?key=$apiKey&q=$lat,$lon&dt=$formattedDate';

      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          pastWeather.add(data);
        }
      } catch (e) {
        print('Error fetching past weather for $formattedDate: $e');
      }
    }

    return pastWeather;
  }
}
