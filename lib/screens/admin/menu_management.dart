import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MenuManagement extends StatefulWidget {
  @override
  _MenuManagementState createState() => _MenuManagementState();
}

class _MenuManagementState extends State<MenuManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Ana Yemekler';
  File? _imageFile;
  final List<String> _categories = [
    'Ana Yemekler',
    'İçecekler',
    'Tatlılar',
    'Başlangıçlar',
    'Salatalar',
    'Pizzalar'
  ];

  // Ürün seçenekleri için
  final List<Map<String, dynamic>> _sizePrices = [];
  final List<Map<String, dynamic>> _extraToppings = [];
  final _sizeController = TextEditingController();
  final _sizePriceController = TextEditingController();
  final _toppingNameController = TextEditingController();
  final _toppingPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menü Yönetimi'),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Ürün Resmi
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.add_photo_alternate, size: 50),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Ürün Adı
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Ürün Adı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen ürün adını girin';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Kategori
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Açıklama
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen açıklama girin';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Boyut ve Fiyat Ekleme
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Boyut ve Fiyatlar',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _sizeController,
                                  decoration: InputDecoration(
                                    labelText: 'Boyut (örn: Küçük)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _sizePriceController,
                                  decoration: InputDecoration(
                                    labelText: 'Fiyat',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addSizePrice,
                            child: Text('Boyut Ekle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                            ),
                          ),
                          SizedBox(height: 16),
                          ..._sizePrices.map((sizePrice) => ListTile(
                                title: Text(sizePrice['size']),
                                subtitle: Text('${sizePrice['price']} TL'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _removeSizePrice(sizePrice),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Ekstra Malzeme Ekleme
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ekstra Malzemeler',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _toppingNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Malzeme Adı',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _toppingPriceController,
                                  decoration: InputDecoration(
                                    labelText: 'Fiyat',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addTopping,
                            child: Text('Malzeme Ekle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                            ),
                          ),
                          SizedBox(height: 16),
                          ..._extraToppings.map((topping) => ListTile(
                                title: Text(topping['name']),
                                subtitle: Text('${topping['price']} TL'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _removeTopping(topping),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Kaydet Butonu
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text('Ürünü Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Mevcut Ürünler Listesi
            Text('Mevcut Ürünler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('menu').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Bir hata oluştu');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data!.docs[index];
                    return Card(
                      child: ListTile(
                        leading: item['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.restaurant),
                        title: Text(item['name']),
                        subtitle: Text(item['category']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteProduct(item.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _addSizePrice() {
    if (_sizeController.text.isNotEmpty && _sizePriceController.text.isNotEmpty) {
      setState(() {
        _sizePrices.add({
          'size': _sizeController.text,
          'price': double.parse(_sizePriceController.text),
        });
        _sizeController.clear();
        _sizePriceController.clear();
      });
    }
  }

  void _removeSizePrice(Map<String, dynamic> sizePrice) {
    setState(() {
      _sizePrices.remove(sizePrice);
    });
  }

  void _addTopping() {
    if (_toppingNameController.text.isNotEmpty &&
        _toppingPriceController.text.isNotEmpty) {
      setState(() {
        _extraToppings.add({
          'name': _toppingNameController.text,
          'price': double.parse(_toppingPriceController.text),
        });
        _toppingNameController.clear();
        _toppingPriceController.clear();
      });
    }
  }

  void _removeTopping(Map<String, dynamic> topping) {
    setState(() {
      _extraToppings.remove(topping);
    });
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('menu_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('menu').add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'imageUrl': imageUrl,
          'sizePrices': _sizePrices,
          'extraToppings': _extraToppings,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Formu temizle
        _formKey.currentState!.reset();
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _imageFile = null;
          _sizePrices.clear();
          _extraToppings.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün başarıyla eklendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün silindi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }
} 