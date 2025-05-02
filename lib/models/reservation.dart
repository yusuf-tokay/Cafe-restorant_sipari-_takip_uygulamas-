class Reservation {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime date;
  final String time;
  final int numberOfPeople;
  final String status; // 'pending', 'approved', 'cancelled'
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.date,
    required this.time,
    required this.numberOfPeople,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'date': date.toIso8601String(),
      'time': time,
      'numberOfPeople': numberOfPeople,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      numberOfPeople: map['numberOfPeople'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 