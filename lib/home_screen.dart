import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/register_screen.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _getHabitsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No habits added yet!'));
          }
          final habits = snapshot.data!.docs;
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(habit['name'] ?? 'Unnamed Habit'),
                subtitle: Text(
                  habit['createdAt'] != null
                      ? (habit['createdAt'] as Timestamp).toDate().toString()
                      : 'No date',
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getHabitsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return const Stream.empty();
  }
}
