import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Weather Map',
      home: Map(),
    );
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> {
  final _controller = MapController();

  final TileLayer _defaultLayer = TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.example.app',
  );

  TileLayer _weatherLayer = TileLayer(
    urlTemplate: '',
  );

  DateTime _forecastDate = DateTime.now();
  _setWeatherTile(DateTime date) async {
    const String mapType = 'PR0';
    final timestamp = date.millisecondsSinceEpoch ~/ 1000;
    const double opacity = 0.4;
    final TileLayer weatherLayer = TileLayer(
      urlTemplate:
          'http://maps.openweathermap.org/maps/2.0/weather/$mapType/{z}/{x}/{y}?date=$timestamp&opacity=$opacity&fill_bound=true&appid=9de243494c0b295cca9337e1e96b00e2',
      backgroundColor: Colors.transparent,
    );
    setState(() {
      _weatherLayer = weatherLayer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            options: MapOptions(
                center: const LatLng(51.509364, -0.128928),
                zoom: 16,
                minZoom: 9,
                onMapReady: () {
                  _setWeatherTile(_forecastDate);
                }),
            mapController: _controller,
            children: _weatherLayer.urlTemplate != ''
                ? [_defaultLayer, _weatherLayer]
                : [
                    _defaultLayer,
                  ],
          ),
          Positioned(
            bottom: 30,
            child: Container(
              height: 70,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _forecastDate =
                              _forecastDate.subtract(const Duration(hours: 3));
                        });
                        _setWeatherTile(_forecastDate);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Forecast Date:\n${DateFormat('yyyy-MM-dd ha').format(_forecastDate)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    child: ElevatedButton(
                      onPressed:
                          _forecastDate.difference(DateTime.now()).inDays >= 10
                              ? null
                              : () {
                                  setState(() {
                                    _forecastDate = _forecastDate
                                        .add(const Duration(hours: 3));
                                  });
                                  _setWeatherTile(_forecastDate);
                                },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
