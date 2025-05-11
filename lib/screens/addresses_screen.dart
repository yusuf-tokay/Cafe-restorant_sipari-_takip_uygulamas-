import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AddressesScreen extends StatefulWidget {
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final TextEditingController _addressController = TextEditingController();
  List<String> _addresses = [];
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Konum izni reddedildi.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin.')),
        );
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String locationText = 'Enlem: ${position.latitude}, Boylam: ${position.longitude}';
      setState(() {
        _addresses.add(locationText);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
    }
  }

  void _addAddress() {
    if (_addressController.text.trim().isNotEmpty) {
      setState(() {
        _addresses.add(_addressController.text.trim());
        _addressController.clear();
      });
    }
  }

  void _removeAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adreslerim')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adres Ekle', style: Theme.of(context).textTheme.titleLarge),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(hintText: 'Adresinizi girin'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_location_alt, color: Theme.of(context).primaryColor),
                  onPressed: _addAddress,
                ),
                IconButton(
                  icon: _isLoading ? CircularProgressIndicator() : Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                  onPressed: _isLoading ? null : _getCurrentLocation,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Kayıtlı Adresler', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: _addresses.isEmpty
                  ? Center(child: Text('Henüz adres eklenmedi.'))
                  : ListView.builder(
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                        title: Text(_addresses[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeAddress(index),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 