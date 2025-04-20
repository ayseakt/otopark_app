import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  bool _showEmptyParkingSpots = false;
  bool _showFreeParking = false;
  bool _show24HourParking = false;
  bool _showTrafficCondition = false;

  Offset _filterButtonPosition = const Offset(20, 300); // Hareketli butonun ilk konumu
  final LatLng _izmir = const LatLng(38.4192, 27.1287);

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchLocation() {
    final searchText = _searchController.text;
    if (searchText.isNotEmpty) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_izmir, 14),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$searchText" için konum aranıyor...')),
      );
    }
  }

  void _applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtreler uygulandı')),
    );
  }

  void _toggleFilterPanel() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: _buildFilterPanel(),
        );
      },
    );
  }

  Widget _buildFilterPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            'Filtreler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildFilterOption(
            'Boş Park Yerleri',
            _showEmptyParkingSpots,
            (value) => setState(() => _showEmptyParkingSpots = value),
          ),
          _buildFilterOption(
            'Ücretsiz Park Süresi Olanlar',
            _showFreeParking,
            (value) => setState(() => _showFreeParking = value),
          ),
          _buildFilterOption(
            '24 Saat Açık Olanlar',
            _show24HourParking,
            (value) => setState(() => _show24HourParking = value),
          ),
          _buildFilterOption(
            'Trafik Durumunu Göster',
            _showTrafficCondition,
            (value) => setState(() => _showTrafficCondition = value),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _applyFilters();
                Navigator.pop(context); // Paneli kapat
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF246AFB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Uygula'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EgeParkGo'),
        backgroundColor: const Color(0xFF246AFB),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _izmir,
              zoom: 12,
            ),
            myLocationEnabled: true,
            compassEnabled: true,
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
          ),
          // Search bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Konum ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ),
          // Hareketli filtre butonu
          Positioned(
            left: _filterButtonPosition.dx,
            top: _filterButtonPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _filterButtonPosition += details.delta;
                });
              },
              child: FloatingActionButton(
                heroTag: "filterButton",
                backgroundColor: const Color(0xFF246AFB),
                onPressed: _toggleFilterPanel,
                child: const Icon(Icons.filter_list),
                mini: true,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF246AFB),
        child: const Icon(Icons.my_location),
        onPressed: () {
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(_izmir),
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterOption(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF246AFB),
          ),
        ],
      ),
    );
  }
}
