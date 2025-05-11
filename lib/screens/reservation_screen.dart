import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reservation_service.dart';
import '../models/reservation.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import '../theme/app_theme.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reservationService = ReservationService();
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '12:00';
  int _numberOfPeople = 2;
  List<Reservation> _userReservations = [];
  String name = '';
  String phone = '';

  final List<String> _availableTimes = [
    '12:00', '13:00', '14:00', '15:00', '16:00',
    '17:00', '18:00', '19:00', '20:00', '21:00'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserReservations();
  }

  Future<void> _loadUserReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final reservations = await _reservationService.getUserReservations(user.uid);
      setState(() {
        _userReservations = reservations;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createReservation() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final reservation = Reservation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          userName: userDoc.data()!['name'],
          userEmail: user.email!,
          date: _selectedDate,
          time: _selectedTime,
          numberOfPeople: _numberOfPeople,
          createdAt: DateTime.now(),
        );

        await _reservationService.createReservation(reservation);
        await _loadUserReservations();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rezervasyonunuz başarıyla oluşturuldu')),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'approved':
        return 'Onaylandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryLinearGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rezervasyon',
                      style: AppTheme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Ana İçerik
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rezervasyon Formu
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rezervasyon Bilgileri',
                                style: AppTheme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 24),

                              // Tarih Seçimi
                              Text(
                                'Tarih',
                                style: AppTheme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedDate == null ? 'Tarih Seçin' : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textColor.withOpacity(0.7),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Saat Seçimi
                              Text(
                                'Saat',
                                style: AppTheme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedTime = picked.format(context);
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedTime == null ? 'Saat Seçin' : _selectedTime,
                                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textColor.withOpacity(0.7),
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Kişi Sayısı
                              Text(
                                'Kişi Sayısı',
                                style: AppTheme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_numberOfPeople} Kişi',
                                      style: AppTheme.textTheme.bodyMedium,
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: AppTheme.primaryColor,
                                          ),
                                          onPressed: () => setState(() => _numberOfPeople--),
                                        ),
                                        Text(
                                          '$_numberOfPeople',
                                          style: AppTheme.textTheme.titleMedium,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: AppTheme.primaryColor,
                                          ),
                                          onPressed: () => setState(() => _numberOfPeople++),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Not
                              Text(
                                'Not',
                                style: AppTheme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Özel isteklerinizi belirtebilirsiniz...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Rezervasyon Yap Butonu
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
                                      _formKey.currentState!.save();
                                      Provider.of<ReservationProvider>(context, listen: false).addReservation(
                                        Reservation(
                                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                                          userId: 'user123',
                                          userName: name,
                                          userEmail: 'user@example.com',
                                          date: _selectedDate!,
                                          time: _selectedTime,
                                          numberOfPeople: _numberOfPeople,
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Rezervasyonunuz alındı!')),
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Rezervasyon Yap',
                                    style: AppTheme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Rezervasyon Bilgileri
                        Text(
                          'Rezervasyon Bilgileri',
                          style: AppTheme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.access_time,
                                title: 'Çalışma Saatleri',
                                subtitle: 'Her gün 09:00 - 22:00',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                icon: Icons.phone,
                                title: 'Rezervasyon',
                                subtitle: '+90 555 123 4567',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                icon: Icons.info,
                                title: 'Bilgi',
                                subtitle: 'Rezervasyonlar en az 2 saat önceden yapılmalıdır.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 