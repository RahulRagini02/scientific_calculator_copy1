import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class CalculusScreen extends StatefulWidget {
  const CalculusScreen({super.key});

  @override
  State<CalculusScreen> createState() => _CalculusScreenState();
}

class _CalculusScreenState extends State<CalculusScreen> {
  String _input = '';
  String _output = '';
  String _selectedOperation = 'derivative';
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _variableController =
      TextEditingController(text: 'x');
  final TextEditingController _orderController =
      TextEditingController(text: '1');

  final List<String> _operations = [
    'derivative',
    'integral',
    'definite_integral',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _variableController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _calculateResult() {
    if (_input.isEmpty) {
      setState(() => _output = 'Enter an expression');
      return;
    }

    try {
      String expression = _input;
      String variable = _variableController.text;
      int order = int.tryParse(_orderController.text) ?? 1;

      switch (_selectedOperation) {
        case 'derivative':
          _calculateDerivative(expression, variable, order);
          break;
        case 'integral':
          _calculateIntegral(expression, variable);
          break;
        case 'definite_integral':
          // TODO: Implement definite integral
          setState(() => _output = 'Definite integral coming soon');
          break;
        default:
          setState(() => _output = 'Invalid operation');
      }
    } catch (e) {
      setState(() => _output = 'Error: ${e.toString()}');
    }
  }

  void _calculateDerivative(String expression, String variable, int order) {
    // Simple derivative calculation for basic expressions
    // This is a basic implementation and should be expanded for more complex cases
    Parser p = Parser();
    Expression exp = p.parse(expression);

    // For now, we'll just show a message that this is a placeholder
    // In a real implementation, you would need a proper symbolic math library
    setState(() {
      _output = 'Derivative calculation coming soon\n'
          'Expression: $expression\n'
          'Variable: $variable\n'
          'Order: $order';
    });
  }

  void _calculateIntegral(String expression, String variable) {
    // Simple integral calculation for basic expressions
    // This is a basic implementation and should be expanded for more complex cases
    Parser p = Parser();
    Expression exp = p.parse(expression);

    // For now, we'll just show a message that this is a placeholder
    // In a real implementation, you would need a proper symbolic math library
    setState(() {
      _output = 'Integral calculation coming soon\n'
          'Expression: $expression\n'
          'Variable: $variable';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Calculus Calculator'),
        backgroundColor: const Color(0xFF9C27B0),
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
                        operation.replaceAll('_', ' ').toUpperCase(),
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
                      selectedColor: const Color(0xFF9C27B0),
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
                    'Enter Expression',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g., x^2 + 2*x + 1',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.black45,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _input = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Variable',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _variableController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order (for derivative)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _orderController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Calculate Button
            ElevatedButton(
              onPressed: _calculateResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
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
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
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
