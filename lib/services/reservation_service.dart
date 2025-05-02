import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createReservation(Reservation reservation) async {
    await _firestore.collection('reservations').doc(reservation.id).set(reservation.toMap());
  }

  Future<List<Reservation>> getUserReservations(String userId) async {
    final snapshot = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Reservation.fromMap(doc.data())).toList();
  }

  Future<List<Reservation>> getAllReservations() async {
    final snapshot = await _firestore
        .collection('reservations')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Reservation.fromMap(doc.data())).toList();
  }

  Future<void> updateReservationStatus(String reservationId, String status) async {
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .update({'status': status});
  }
} 