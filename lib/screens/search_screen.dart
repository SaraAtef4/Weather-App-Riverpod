import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:weather_app_riverpod/screens/settings_screen.dart';
import 'package:weather_app_riverpod/screens/weekly_forecast_screen.dart';
import 'package:weather_app_riverpod/services/api_service.dart';
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<SearchScreen> {
  final _weatherService = WeatherApiService();
  String city = 'Cairo';
  String country = '';
  Map<String, dynamic> currentValue = {};
  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7days = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final forecast = await _weatherService.getHourlyForecast(city);
      final past = await _weatherService.getPastSevenDaysWeather(city);
      setState(() {
        currentValue = forecast['current'] ?? {};
        hourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];
        next7days = forecast['forecast']?['forecastday'] ?? [];
        pastWeek = past;
        city = forecast['location']?['name'] ?? city;
        country = forecast['location']?['country'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        pastWeek = [];
        next7days = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'City not found or invalid. Please enter a valid city name',
          ),
        ),
      );
    }
  }

  String formateTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    String iconPath = currentValue['condition']?['icon'] ?? '';
    String imageUrl = iconPath.isNotEmpty ? "https:$iconPath" : "";
    Widget imageWidgets =
        imageUrl.isNotEmpty
            ? Image.network(
              imageUrl,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
            : SizedBox();
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            SizedBox(width: 25),
            SizedBox(
              width: 300,
              height: 50,
              child: TextField(
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                onSubmitted: (value) {
                  if (value.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.enterCityName)),
                    );
                    return;
                  }
                  city = value.trim();
                  _fetchWeather();
                },
                decoration: InputDecoration(
                  labelText: localizations.searchCity,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingScreen()),
                );
              },
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
      
            SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (currentValue.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$city ${country.isNotEmpty ? ',$country' : ''}",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${currentValue['temp_c']}°C',
                        style: TextStyle(
                          fontSize: 40,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${currentValue['condition']['text']}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      imageWidgets,
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          height: 100,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary,
                                offset: Offset(1, 1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://cdn3d.iconscout.com/3d/premium/thumb/humidity-weather-3d-icon-download-in-png-blend-fbx-gltf-file-formats--percentage-level-temperature-humid-pack-nature-icons-9734394.png?f=webp',
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text(
                                    '${currentValue['humidity']}%',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    localizations.humidity,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    "https://cdn3d.iconscout.com/3d/premium/thumb/windy-3d-icon-download-in-png-blend-fbx-gltf-file-formats--wind-air-storm-weather-pack-nature-icons-6044096.png",
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text(
                                    '${currentValue['wind_kph']}K/h',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    localizations.wind,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://cdn3d.iconscout.com/3d/premium/thumb/temperature-3d-icon-download-in-png-blend-fbx-gltf-file-formats--thermometer-weather-medical-cold-fever-pack-icons-5665190.png?f=webp',
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text(
                                    '${hourly.isNotEmpty ? hourly.map((h) => h['temp_c']).reduce((a, b) => a > b ? a : b) : 'N/A'}°',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    localizations.maxTemp,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 250,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    localizations.todayForecast,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => WeeklyForecastScreen(
                                                city: city,
                                                currentValue: currentValue,
                                                next7days: next7days,
                                                pastWeek: pastWeek,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      localizations.weeklyForecast,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: hourly.length,
                                itemBuilder: (context, index) {
                                  final hour = hourly[index];
                                  final now = DateTime.now();
                                  final hourTime = DateTime.parse(hour['time']);
                                  final isCurrentHour =
                                      now.hour == hourTime.hour &&
                                      now.day == hourTime.day;
                                  return Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Container(
                                      height: 70,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            isCurrentHour
                                                ? Colors.orangeAccent
                                                : Colors.black38,
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isCurrentHour
                                                ? "Now"
                                                : formateTime(hour['time']),
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Image.network(
                                            "https:${hour['condition']?['icon']}",
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            '${hour["temp_c"]}°C',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
