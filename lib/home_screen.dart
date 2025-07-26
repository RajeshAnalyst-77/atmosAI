import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'location_service.dart';
import 'weather_service.dart';
import 'suggestion_utils.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _weatherFuture;
  List<String> _selectedInterests = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInterests().then((_) {
      _weatherFuture = _getWeatherData();
      setState(() {}); // Trigger rebuild after data is ready
    });
  }

  Future<void> _loadInterests() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedInterests = prefs.getStringList('selectedInterests') ?? [];
  }

  Future<Map<String, dynamic>> _getWeatherData() async {
    final position = await LocationService.getCurrentLocation();
    if (position == null) {
      throw Exception("Location permission not granted");
    }
    return await WeatherService.fetchWeather(position.latitude, position.longitude);
  }

  void _refreshWeather() {
    setState(() {
      _weatherFuture = _getWeatherData();
    });
  }

  String getWeatherBackground(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('clear')) return 'assets/bg_clear.jpg';
    if (condition.contains('cloud')) return 'assets/bg_cloudy.jpg';
    if (condition.contains('rain')) return 'assets/bg_rain.jpg';
    if (condition.contains('thunder')) return 'assets/bg_thunder.jpg';
    if (condition.contains('snow')) return 'assets/bg_snow.jpg';
    if (condition.contains('mist') || condition.contains('haze') || condition.contains('fog')) {
      return 'assets/bg_mist.jpg';
    }
    return 'assets/bg_clear.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atmos - Weather for Photography'),
        actions: [
          Row(
            children: [
              Icon(widget.isDarkMode ? Icons.nightlight : Icons.wb_sunny),
              Switch(
                value: widget.isDarkMode,
                onChanged: (_) => widget.onThemeToggle(),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _refreshWeather,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Weather',
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: ToggleButtons(
              isSelected: [
                _selectedTabIndex == 0,
                _selectedTabIndex == 1,
                _selectedTabIndex == 2,
              ],
              onPressed: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.blueAccent,
              color: Colors.grey[300],
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Current"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Hourly"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Weekly"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  final errorMsg = snapshot.error.toString();
                  if (errorMsg.contains('Location permission')) {
                    return _buildLocationError();
                  }
                  return Center(child: Text('Error: $errorMsg'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  if (_selectedTabIndex == 0) return _buildCurrentWeather(data);
                  if (_selectedTabIndex == 1) return _buildHourlyForecast(data);
                  return _buildWeeklyForecast(data);
                } else {
                  return Center(child: Text('Failed to load weather data'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 60, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Location permission denied',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
          Text(
            'Please enable location to get weather info.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await openAppSettings();
            },
            icon: Icon(Icons.settings),
            label: Text("Open App Settings"),
          )
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(Map<String, dynamic> weather) {
    final temp = weather['main']['temp'];
    final desc = weather['weather'][0]['description'];
    final iconCode = weather['weather'][0]['icon'];
    final iconUrl = 'http://openweathermap.org/img/wn/$iconCode@4x.png';
    final suggestion = SuggestionUtils.getSuggestion(desc, temp, _selectedInterests);
    final bgImage = getWeatherBackground(desc);

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: Duration(seconds: 1),
          child: Image.asset(
            bgImage,
            key: ValueKey(bgImage),
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.1),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(20),
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("📍 ${weather['name']}",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(height: 12),
                    Image.network(iconUrl, width: 80),
                    Text("🌡️ ${temp.toStringAsFixed(1)}°C",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.white,
                        )),
                    Text("☁️ ${desc[0].toUpperCase()}${desc.substring(1)}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white70,
                        )),
                    SizedBox(height: 16),
                    Text("📸 Suggestion",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        )),
                    SizedBox(height: 8),
                    Text(suggestion,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(Map<String, dynamic> data) {
    final hourlyList = data['hourly']?.take(8).toList();
    if (hourlyList == null) return Center(child: Text("Hourly data not available"));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: hourlyList.length,
      itemBuilder: (context, index) {
        final hour = hourlyList[index];
        final time = DateTime.fromMillisecondsSinceEpoch(hour['dt'] * 1000);
        final temp = hour['temp'];
        final desc = hour['weather'][0]['description'];
        final icon = hour['weather'][0]['icon'];

        return Card(
          color: Colors.black.withOpacity(0.3),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Image.network('http://openweathermap.org/img/wn/$icon@2x.png'),
            title: Text("${time.hour}:00  -  ${temp.toStringAsFixed(1)}°C",
                style: GoogleFonts.poppins(color: Colors.white)),
            subtitle: Text(desc, style: TextStyle(color: Colors.white70)),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyForecast(Map<String, dynamic> data) {
    final dailyList = data['daily']?.take(7).toList();
    if (dailyList == null) return Center(child: Text("Weekly data not available"));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: dailyList.length,
      itemBuilder: (context, index) {
        final day = dailyList[index];
        final date = DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);
        final temp = day['temp']['day'];
        final desc = day['weather'][0]['description'];
        final icon = day['weather'][0]['icon'];

        return Card(
          color: Colors.black.withOpacity(0.3),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Image.network('http://openweathermap.org/img/wn/$icon@2x.png'),
            title: Text("${date.day}/${date.month} - ${temp.toStringAsFixed(1)}°C",
                style: GoogleFonts.poppins(color: Colors.white)),
            subtitle: Text(desc, style: TextStyle(color: Colors.white70)),
          ),
        );
      },
    );
  }
}
