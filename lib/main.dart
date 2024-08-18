import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _points = [];
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  List<LatLng> _path = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Picker and Shortest Path'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startController,
                    decoration: InputDecoration(
                      labelText: 'Start Location',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endController,
                    decoration: InputDecoration(
                      labelText: 'End Location',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocations,
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(51.5, -0.09),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _points.map((point) => Marker(
                    point: point,
                    builder: (ctx) => Icon(Icons.pin_drop, color: Colors.red),
                  )).toList(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _path,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions),
        onPressed: _findShortestPath,
      ),
    );
  }

  Future<void> _searchLocations() async {
    final startLocation = _startController.text;
    final endLocation = _endController.text;

    if (startLocation.isEmpty || endLocation.isEmpty) {
      return;
    }

    final startCoords = await _geocodeLocation(startLocation);
    final endCoords = await _geocodeLocation(endLocation);

    if (startCoords != null && endCoords != null) {
      setState(() {
        _points.clear();
        _points.add(startCoords);
        _points.add(endCoords);
        _mapController.move(startCoords, 13.0);
      });
    }
  }

  Future<LatLng?> _geocodeLocation(String location) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$location');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final firstResult = data[0];
        final lat = double.parse(firstResult['lat']);
        final lon = double.parse(firstResult['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  void _findShortestPath() {
    if (_points.length < 2) return;

    final graph = <int, Map<int, double>>{};
    for (var i = 0; i < _points.length; i++) {
      graph[i] = <int, double>{};
      for (var j = 0; j < _points.length; j++) {
        if (i != j) {
          graph[i]![j] = _distance(_points[i], _points[j]);
        }
      }
    }

    final shortestPath = _dijkstra(graph, 0, _points.length - 1);
    setState(() {
      _path = shortestPath.map((index) => _points[index]).toList();
    });
  }

  double _distance(LatLng p1, LatLng p2) {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Meter, p1, p2);
  }

  List<int> _dijkstra(Map<int, Map<int, double>> graph, int start, int goal) {
    final dist = <int, double>{};
    final prev = <int, int>{};
    final q = <int>{};

    for (var node in graph.keys) {
      dist[node] = double.infinity;
      prev[node] = -1;
      q.add(node);
    }

    dist[start] = 0;

    while (q.isNotEmpty) {
      final u = q.reduce((a, b) => dist[a]! < dist[b]! ? a : b);
      q.remove(u);

      if (u == goal) {
        final path = <int>[];
        var current = u;
        while (current != -1) {
          path.insert(0, current);
          current = prev[current]!;
        }
        return path;
      }

      for (var neighbor in graph[u]!.keys) {
        final alt = dist[u]! + graph[u]![neighbor]!;
        if (alt < dist[neighbor]!) {
          dist[neighbor] = alt;
          prev[neighbor] = u;
        }
      }
    }

    return [];
  }
}
