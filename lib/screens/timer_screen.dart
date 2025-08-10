// lib/screens/timer_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/streak_provider.dart';

class TimerScreen extends StatefulWidget {
  final int durationInMinutes;

  const TimerScreen({super.key, required this.durationInMinutes});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationInMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        // Mark the session as complete only when the timer finishes
        Provider.of<StreakProvider>(context, listen: false).startReadingSession();
        // Show a completion dialog
        _showCompletionDialog();
      }
    });
  }

  // Very important to cancel the timer when the screen is closed
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Complete!'),
          content: const Text('Great job! You\'ve completed your daily reading session.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Awesome!'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back from the timer screen
              },
            ),
          ],
        );
      },
    );
  }

  // Helper to format the time into MM:SS
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Session'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Time Remaining',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              _formatTime(_remainingSeconds),
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Session'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                _timer.cancel();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}