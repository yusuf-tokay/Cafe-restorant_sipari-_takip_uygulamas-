import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryManagement extends StatefulWidget {
  @override
  _InventoryManagementState createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _unitController = TextEditingController();
  String _selectedCategory = 'Yiyecek';
  final List<String> _categories = ['Yiyecek', 'İçecek', 'Temizlik', 'Diğer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Takibi'),
        backgroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showAddItemDialog(context),
              child: Text('Yeni Ürün Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Bir hata oluştu'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data!.docs[index];
                    bool isLowStock = item['quantity'] <= item['minQuantity'];
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isLowStock ? Colors.red[50] : null,
                      child: ListTile(
                        title: Text(item['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kategori: ${item['category']}'),
                            Text('Miktar: ${item['quantity']} ${item['unit']}'),
                            Text('Minimum Stok: ${item['minQuantity']} ${item['unit']}'),
                            if (isLowStock)
                              Text(
                                'Düşük Stok Uyarısı!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () => _showUpdateQuantityDialog(context, item, true),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.orange),
                              onPressed: () => _showUpdateQuantityDialog(context, item, false),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditItemDialog(context, item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Ürün Ekle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Ürün Adı'),
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen ürün adı girin' : null,
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: 'Miktar'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen miktar girin' : null,
                ),
                TextFormField(
                  controller: _minQuantityController,
                  decoration: InputDecoration(labelText: 'Minimum Stok'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen minimum stok girin' : null,
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(labelText: 'Birim (kg, adet, lt)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen birim girin' : null,
                ),
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
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addItem();
                Navigator.pop(context);
              }
            },
            child: Text('Ekle'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, DocumentSnapshot item) {
    _nameController.text = item['name'];
    _quantityController.text = item['quantity'].toString();
    _minQuantityController.text = item['minQuantity'].toString();
    _unitController.text = item['unit'];
    _selectedCategory = item['category'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ürün Düzenle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Ürün Adı'),
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen ürün adı girin' : null,
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: 'Miktar'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen miktar girin' : null,
                ),
                TextFormField(
                  controller: _minQuantityController,
                  decoration: InputDecoration(labelText: 'Minimum Stok'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen minimum stok girin' : null,
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(labelText: 'Birim (kg, adet, lt)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen birim girin' : null,
                ),
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
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateItem(item.id);
                Navigator.pop(context);
              }
            },
            child: Text('Güncelle'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
          ),
        ],
      ),
    );
  }

  void _showUpdateQuantityDialog(BuildContext context, DocumentSnapshot item, bool isAdd) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdd ? 'Stok Ekle' : 'Stok Çıkar'),
        content: TextFormField(
          controller: quantityController,
          decoration: InputDecoration(
            labelText: 'Miktar',
            suffixText: item['unit'],
          ),
          keyboardType: TextInputType.number,
          validator: (value) =>
              value!.isEmpty ? 'Lütfen miktar girin' : null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (quantityController.text.isNotEmpty) {
                double quantity = double.parse(quantityController.text);
                if (isAdd) {
                  _updateQuantity(item.id, item['quantity'] + quantity);
                } else {
                  _updateQuantity(item.id, item['quantity'] - quantity);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isAdd ? 'Ekle' : 'Çıkar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    await FirebaseFirestore.instance.collection('inventory').add({
      'name': _nameController.text,
      'quantity': double.parse(_quantityController.text),
      'minQuantity': double.parse(_minQuantityController.text),
      'unit': _unitController.text,
      'category': _selectedCategory,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _quantityController.clear();
    _minQuantityController.clear();
    _unitController.clear();
  }

  Future<void> _updateItem(String itemId) async {
    await FirebaseFirestore.instance.collection('inventory').doc(itemId).update({
      'name': _nameController.text,
      'quantity': double.parse(_quantityController.text),
      'minQuantity': double.parse(_minQuantityController.text),
      'unit': _unitController.text,
      'category': _selectedCategory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateQuantity(String itemId, double newQuantity) async {
    await FirebaseFirestore.instance.collection('inventory').doc(itemId).update({
      'quantity': newQuantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteItem(String itemId) async {
    await FirebaseFirestore.instance.collection('inventory').doc(itemId).delete();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
} 