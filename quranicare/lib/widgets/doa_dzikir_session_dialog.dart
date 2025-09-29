import 'package:flutter/material.dart';
import '../models/doa_dzikir.dart';

// Session Dialog Widget
class DoaDzikirSessionDialog extends StatefulWidget {
  final DoaDzikir doaDzikir;

  const DoaDzikirSessionDialog({super.key, required this.doaDzikir});

  @override
  State<DoaDzikirSessionDialog> createState() => _DoaDzikirSessionDialogState();
}

class _DoaDzikirSessionDialogState extends State<DoaDzikirSessionDialog> {
  int _currentCount = 0;
  int _targetCount = 33; // Default target
  bool _isSessionActive = false;
  DateTime? _startTime;
  
  final List<int> _targetOptions = [7, 11, 33, 99, 100];

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _startTime = DateTime.now();
      _currentCount = 0;
    });
  }

  void _incrementCount() {
    if (_isSessionActive && _currentCount < _targetCount) {
      setState(() {
        _currentCount++;
      });
      
      // Check if target reached
      if (_currentCount >= _targetCount) {
        _completeSession();
      }
    }
  }

  void _completeSession() {
    final duration = _startTime != null 
        ? DateTime.now().difference(_startTime!).inSeconds 
        : 0;
        
    setState(() {
      _isSessionActive = false;
    });

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Selesai!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF8FA68E),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Alhamdulillah! Anda telah menyelesaikan $_currentCount kali dzikir dalam ${duration}s.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close completion dialog
              Navigator.of(context).pop(); // Close session dialog
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.doaDzikir.nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),

            if (!_isSessionActive) ...[
              // Target selection
              const Text(
                'Pilih Target Dzikir:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D5A5A),
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: _targetOptions.map((count) {
                  return FilterChip(
                    label: Text('$count'),
                    selected: _targetCount == count,
                    onSelected: (selected) {
                      setState(() {
                        _targetCount = count;
                      });
                    },
                    selectedColor: const Color(0xFF8FA68E).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF2D5A5A),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FA68E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Mulai Dzikir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Session active - counter
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8FA68E).withOpacity(0.2),
                  border: Border.all(
                    color: const Color(0xFF8FA68E),
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_currentCount',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                      ),
                      Text(
                        '/ $_targetCount',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8FA68E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Progress bar
              LinearProgressIndicator(
                value: _currentCount / _targetCount,
                backgroundColor: const Color(0xFF8FA68E).withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
              ),
              
              const SizedBox(height: 20),
              
              // Tap to count button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _incrementCount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FA68E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'TAP UNTUK HITUNG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Complete session button
              TextButton(
                onPressed: _completeSession,
                child: const Text(
                  'Selesai Sekarang',
                  style: TextStyle(
                    color: Color(0xFF8FA68E),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFF8FA68E),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}