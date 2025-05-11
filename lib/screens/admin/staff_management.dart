import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffManagement extends StatefulWidget {
  @override
  _StaffManagementState createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'Garson';
  final List<String> _roles = ['Garson', 'Aşçı', 'Kasiyer', 'Yönetici'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personel Yönetimi'),
        backgroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showAddStaffDialog(context),
              child: Text('Yeni Personel Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('staff').snapshots(),
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
                    var staff = snapshot.data!.docs[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(staff['name'][0].toUpperCase()),
                          backgroundColor: Colors.red[900],
                          foregroundColor: Colors.white,
                        ),
                        title: Text(staff['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pozisyon: ${staff['role']}'),
                            Text('E-posta: ${staff['email']}'),
                            Text('Telefon: ${staff['phone']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditStaffDialog(context, staff),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStaff(staff.id),
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

  void _showAddStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Personel Ekle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Ad Soyad'),
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen ad soyad girin' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen e-posta girin' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Telefon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen telefon girin' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Pozisyon'),
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
                _addStaff();
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

  void _showEditStaffDialog(BuildContext context, DocumentSnapshot staff) {
    _nameController.text = staff['name'];
    _emailController.text = staff['email'];
    _phoneController.text = staff['phone'];
    _selectedRole = staff['role'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Personel Düzenle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Ad Soyad'),
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen ad soyad girin' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen e-posta girin' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Telefon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Lütfen telefon girin' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Pozisyon'),
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
                _updateStaff(staff.id);
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

  Future<void> _addStaff() async {
    await FirebaseFirestore.instance.collection('staff').add({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'role': _selectedRole,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
  }

  Future<void> _updateStaff(String staffId) async {
    await FirebaseFirestore.instance.collection('staff').doc(staffId).update({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'role': _selectedRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteStaff(String staffId) async {
    await FirebaseFirestore.instance.collection('staff').doc(staffId).delete();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 