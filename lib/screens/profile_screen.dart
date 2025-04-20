import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Email: ${user?.email ?? 'Kullanıcı girişi yapılmamış'}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
} 