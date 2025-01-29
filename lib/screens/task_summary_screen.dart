import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding/decoding

Widget taskSummary() {
  return FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return const Center(child: Text("Error loading tasks"));
      }

      final prefs = snapshot.data!;
      final tasksJson = prefs.getString('tasks');
      List<Map<String, dynamic>> tasks = [];

      if (tasksJson != null) {
        tasks = List<Map<String, dynamic>>.from(json.decode(tasksJson));
      }

      final total = tasks.length;
      final completed = tasks.where((task) => task['isCompleted'] == true).length;
      final pending = total - completed;

      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Total: $total'),
              Text('Completed: $completed'),
              Text('Pending: $pending'),
            ],
          ),
        ),
      );
    },
  );
}
