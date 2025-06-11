import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProbabilityScreen extends StatefulWidget {
  const ProbabilityScreen({super.key});

  @override
  State<ProbabilityScreen> createState() => _ProbabilityScreenState();
}

class _ProbabilityScreenState extends State<ProbabilityScreen> {
  String _selectedOperation = 'probability';
  String _output = '';

  // Controllers for probability
  final TextEditingController _favorableController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  // Controllers for permutation/combination
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _rController = TextEditingController();

  final List<String> _operations = [
    'probability',
    'permutation',
    'combination',
  ];

  @override
  void dispose() {
    _favorableController.dispose();
    _totalController.dispose();
    _nController.dispose();
    _rController.dispose();
    super.dispose();
  }

  void _calculateResult() {
    try {
      switch (_selectedOperation) {
        case 'probability':
          _calculateProbability();
          break;
        case 'permutation':
          _calculatePermutation();
          break;
        case 'combination':
          _calculateCombination();
          break;
        default:
          setState(() => _output = 'Invalid operation');
      }
    } catch (e) {
      setState(() => _output = 'Error: ${e.toString()}');
    }
  }

  void _calculateProbability() {
    if (_favorableController.text.isEmpty || _totalController.text.isEmpty) {
      setState(
          () => _output = 'Please enter both favorable and total outcomes');
      return;
    }

    int favorable = int.tryParse(_favorableController.text) ?? 0;
    int total = int.tryParse(_totalController.text) ?? 0;

    if (favorable < 0 || total <= 0 || favorable > total) {
      setState(() => _output =
          'Invalid input: favorable outcomes must be between 0 and total outcomes');
      return;
    }

    double probability = favorable / total;
    double percentage = probability * 100;

    setState(() {
      _output = 'Probability: ${probability.toStringAsFixed(4)}\n'
          'Percentage: ${percentage.toStringAsFixed(2)}%\n\n'
          'Favorable outcomes: $favorable\n'
          'Total outcomes: $total';
    });
  }

  void _calculatePermutation() {
    if (_nController.text.isEmpty || _rController.text.isEmpty) {
      setState(() => _output = 'Please enter both n and r values');
      return;
    }

    int n = int.tryParse(_nController.text) ?? 0;
    int r = int.tryParse(_rController.text) ?? 0;

    if (n < 0 || r < 0 || r > n) {
      setState(() => _output =
          'Invalid input: n must be positive and r must be between 0 and n');
      return;
    }

    // Calculate nPr = n! / (n-r)!
    BigInt result = _factorial(n) ~/ _factorial(n - r);

    setState(() {
      _output = 'Permutation (nPr):\n'
          'n = $n\n'
          'r = $r\n'
          'Result: $result\n\n'
          'Formula: n! / (n-r)!';
    });
  }

  void _calculateCombination() {
    if (_nController.text.isEmpty || _rController.text.isEmpty) {
      setState(() => _output = 'Please enter both n and r values');
      return;
    }

    int n = int.tryParse(_nController.text) ?? 0;
    int r = int.tryParse(_rController.text) ?? 0;

    if (n < 0 || r < 0 || r > n) {
      setState(() => _output =
          'Invalid input: n must be positive and r must be between 0 and n');
      return;
    }

    // Calculate nCr = n! / (r! * (n-r)!)
    BigInt result = _factorial(n) ~/ (_factorial(r) * _factorial(n - r));

    setState(() {
      _output = 'Combination (nCr):\n'
          'n = $n\n'
          'r = $r\n'
          'Result: $result\n\n'
          'Formula: n! / (r! * (n-r)!)';
    });
  }

  BigInt _factorial(int n) {
    if (n < 0)
      throw ArgumentError('Factorial is not defined for negative numbers');
    if (n == 0 || n == 1) return BigInt.one;

    BigInt result = BigInt.one;
    for (int i = 2; i <= n; i++) {
      result *= BigInt.from(i);
    }
    return result;
  }

  Widget _buildInputFields() {
    switch (_selectedOperation) {
      case 'probability':
        return Column(
          children: [
            TextField(
              controller: _favorableController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Favorable Outcomes',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black45,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Outcomes',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black45,
              ),
            ),
          ],
        );
      case 'permutation':
      case 'combination':
        return Column(
          children: [
            TextField(
              controller: _nController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'n (Total Items)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black45,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'r (Selected Items)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black45,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Probability Calculator'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Operation Selection
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _operations.length,
                itemBuilder: (context, index) {
                  String operation = _operations[index];
                  bool isSelected = _selectedOperation == operation;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        operation.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedOperation = operation;
                            _output = '';
                          });
                        }
                      },
                      backgroundColor: Colors.black26,
                      selectedColor: const Color(0xFF2196F3),
                    ),
                  );
                },
              ),
            ),

            // Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Values',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputFields(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Calculate Button
            ElevatedButton(
              onPressed: _calculateResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Output Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Result',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _output.isEmpty
                              ? 'Waiting for calculation...'
                              : _output,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
