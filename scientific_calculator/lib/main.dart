import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() {
  runApp(const CalculatorApp(key: Key('calculator_app')));
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const Key('calculator_material_app'),
      debugShowCheckedModeBanner: false,
      title: 'Scientific Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const CalculatorScreen(key: Key('calculator_screen')),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _output = '';
  bool _isRadians = true;
  String _selectedUnit = 'len'; // 'len', 'temp', 'mass', 'time'
  final ScrollController _inputScrollController = ScrollController();
  final ScrollController _outputScrollController = ScrollController();

  final List<String> _scientificButtons = [
    'sin',
    'cos',
    'tan',
    'log',
    'ln',
    'π',
    '√',
    '^',
    '(',
    ')',
    'e',
    '!',
  ];

  final List<String> _basicButtons = [
    '7',
    '8',
    '9',
    '÷',
    '4',
    '5',
    '6',
    '×',
    '1',
    '2',
    '3',
    '-',
    '.',
    '0',
    '%',
    '+',
  ];

  @override
  void dispose() {
    _inputScrollController.dispose();
    _outputScrollController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == '=') {
        try {
          _calculateResult();
        } catch (e) {
          _output = 'Error';
        }
      } else if (buttonText == 'C') {
        _input = '';
        _output = '';
      } else if (buttonText == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else {
        if (_scientificButtons.contains(buttonText)) {
          if (['sin', 'cos', 'tan'].contains(buttonText)) {
            _input += '$buttonText(';
          } else {
            _input += buttonText;
          }
        } else {
          _input += buttonText;
        }
      }
    });

    // Scroll to the right end after setState
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_inputScrollController.hasClients) {
        _inputScrollController.animateTo(
          _inputScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      if (_outputScrollController.hasClients && buttonText == '=') {
        _outputScrollController.animateTo(
          _outputScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _processTrigonometry(String input) {
    RegExp trigExp = RegExp(r'(sin|cos|tan)\(([-0-9.]+)\)');
    String processed = input;

    processed = processed.replaceAllMapped(trigExp, (Match m) {
      String func = m.group(1)!;
      double angle = double.parse(m.group(2)!);

      // Convert degree to radian if in degree mode
      if (!_isRadians) {
        angle = angle * pi / 180;
      }

      double result;
      switch (func) {
        case 'sin':
          result = sin(angle);
          break;
        case 'cos':
          result = cos(angle);
          break;
        case 'tan':
          result = tan(angle);
          break;
        default:
          return m.group(0)!;
      }

      // Round small values near zero to zero
      if (result.abs() < 1e-10) {
        result = 0;
      }
      return result.toString();
    });

    return processed;
  }

  void _calculateResult() {
    String finalInput = _input;

    // Process trigonometric functions first
    finalInput = _processTrigonometry(finalInput);

    // Replace other mathematical symbols
    finalInput = finalInput.replaceAll('×', '*');
    finalInput = finalInput.replaceAll('÷', '/');
    finalInput = finalInput.replaceAll('π', '3.141592653589793');
    finalInput = finalInput.replaceAll('e', '2.718281828459045');

    // Process percentage
    if (finalInput.contains('%')) {
      finalInput = finalInput.replaceAll('%', '/100');
    }

    Parser p = Parser();
    Expression exp = p.parse(finalInput);
    ContextModel cm = ContextModel();
    double result = exp.evaluate(EvaluationType.REAL, cm);

    _output = result.toString();
    if (_output.endsWith('.0')) {
      _output = _output.substring(0, _output.length - 2);
    }
  }

  void _showUnitConverter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnitConverterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // RAD/DEG Section with deep green background
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF004D40), // Deep green color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Scientific Calculator Text
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.greenAccent, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'SCIENTIFIC CALCULATOR',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // RAD/DEG Switch
                    Row(
                      children: [
                        Switch(
                          value: _isRadians,
                          onChanged: (value) {
                            setState(() {
                              _isRadians = value;
                            });
                          },
                        ),
                        Text(
                          _isRadians ? 'RAD' : 'DEG',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Display Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _inputScrollController,
                            child: Text(
                              _input,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _outputScrollController,
                            child: Text(
                              _output,
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scientific Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _scientificButtons.map((text) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 0,
                      maxWidth: (MediaQuery.of(context).size.width - 40) / 4,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _onButtonPressed(text),
                      child: Text(text),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Basic Calculator Buttons
              Expanded(
                child: Column(
                  children: [
                    _buildButtonRow(['C', '⌫', '=', 'UNIT']),
                    _buildButtonRow(['7', '8', '9', '÷']),
                    _buildButtonRow(['4', '5', '6', '×']),
                    _buildButtonRow(['1', '2', '3', '-']),
                    _buildButtonRow(['.', '0', '%', '+']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((text) {
          Color buttonColor;
          VoidCallback onPressed;

          if (text == 'UNIT') {
            buttonColor = const Color(0xFFE53935);
            onPressed = _showUnitConverter;
          } else if (text == 'C' || text == '⌫') {
            buttonColor = const Color(0xFFE57373);
            onPressed = () => _onButtonPressed(text);
          } else if (text == '=') {
            buttonColor = const Color(0xFF4CAF50);
            onPressed = () => _onButtonPressed(text);
          } else if ('+-×÷%'.contains(text)) {
            buttonColor = const Color(0xFF42A5F5);
            onPressed = () => _onButtonPressed(text);
          } else {
            buttonColor = const Color(0xFF424242);
            onPressed = () => _onButtonPressed(text);
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: onPressed,
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String _selectedUnit = 'len';
  String _input = '';
  String _output = '';
  String _fromUnit = '';
  String _toUnit = '';
  final TextEditingController _inputController = TextEditingController();

  final Map<String, List<String>> unitOptions = {
    'len': ['m', 'km', 'cm', 'mm', 'μm', 'nm', 'mi', 'yd', 'ft', 'in'],
    'area': [
      'm²',
      'km²',
      'cm²',
      'mm²',
      'ha',
      'acre',
      'sq mi',
      'sq yd',
      'sq ft',
      'sq in',
    ],
    'vol': [
      'm³',
      'km³',
      'cm³',
      'mm³',
      'L',
      'mL',
      'gal',
      'qt',
      'pt',
      'fl oz',
      'cu ft',
      'cu in',
    ],
    'temp': ['°C', '°F', 'K', 'R'],
    'mass': ['kg', 'g', 'mg', 'μg', 'ton', 'lb', 'oz', 'ct', 'gr'],
    'time': ['s', 'ms', 'μs', 'ns', 'min', 'h', 'day', 'week', 'month', 'year'],
    'data': ['bit', 'B', 'KB', 'MB', 'GB', 'TB', 'PB'],
    'speed': ['m/s', 'km/h', 'mi/h', 'ft/s', 'kn'],
    'energy': ['J', 'kJ', 'cal', 'kcal', 'eV', 'kWh', 'BTU', 'ft⋅lb'],
    'power': ['W', 'kW', 'MW', 'hp', 'BTU/h', 'ft⋅lb/s'],
    'pressure': [
      'Pa',
      'kPa',
      'MPa',
      'bar',
      'psi',
      'atm',
      'mmHg',
      'inHg',
      'torr',
    ],
    'angle': ['deg', 'rad', 'grad', 'arcmin', 'arcsec', 'rev'],
    'frequency': ['Hz', 'kHz', 'MHz', 'GHz', 'rpm', 'rad/s'],
    'current': ['A', 'mA', 'μA', 'kA'],
    'voltage': ['V', 'mV', 'μV', 'kV', 'MV'],
    'resistance': ['Ω', 'mΩ', 'kΩ', 'MΩ'],
  };

  final Map<String, Map<String, dynamic>> unitData = {
    'len': {
      'title': 'Length',
      'icon': Icons.straighten,
      'color': const Color(0xFF4CAF50),
    },
    'area': {
      'title': 'Area',
      'icon': Icons.square_foot,
      'color': const Color(0xFF9C27B0),
    },
    'vol': {
      'title': 'Volume',
      'icon': Icons.view_in_ar,
      'color': const Color(0xFF3F51B5),
    },
    'temp': {
      'title': 'Temperature',
      'icon': Icons.thermostat,
      'color': const Color(0xFFFF5722),
    },
    'mass': {
      'title': 'Mass',
      'icon': Icons.fitness_center,
      'color': const Color(0xFF2196F3),
    },
    'time': {
      'title': 'Time',
      'icon': Icons.timer,
      'color': const Color(0xFFFF9800),
    },
    'data': {
      'title': 'Data',
      'icon': Icons.data_usage,
      'color': const Color(0xFF607D8B),
    },
    'speed': {
      'title': 'Speed',
      'icon': Icons.speed,
      'color': const Color(0xFFF44336),
    },
    'energy': {
      'title': 'Energy',
      'icon': Icons.bolt,
      'color': const Color(0xFFFFEB3B),
    },
    'power': {
      'title': 'Power',
      'icon': Icons.power,
      'color': const Color(0xFFFF4081),
    },
    'pressure': {
      'title': 'Pressure',
      'icon': Icons.compress,
      'color': const Color(0xFF00BCD4),
    },
    'angle': {
      'title': 'Angle',
      'icon': Icons.architecture,
      'color': const Color(0xFF795548),
    },
    'frequency': {
      'title': 'Frequency',
      'icon': Icons.waves,
      'color': const Color(0xFF8BC34A),
    },
    'current': {
      'title': 'Current',
      'icon': Icons.electric_bolt,
      'color': const Color(0xFFE91E63),
    },
    'voltage': {
      'title': 'Voltage',
      'icon': Icons.electrical_services,
      'color': const Color(0xFF673AB7),
    },
    'resistance': {
      'title': 'Resistance',
      'icon': Icons.power_input,
      'color': const Color(0xFF009688),
    },
  };

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convertUnit() {
    if (_input.isEmpty || _fromUnit.isEmpty || _toUnit.isEmpty) {
      setState(() => _output = '');
      return;
    }

    try {
      double? inputValue = double.tryParse(_input);
      if (inputValue == null) {
        setState(() => _output = 'Invalid input');
        return;
      }

      double result = 0;

      // Length conversions
      if (_selectedUnit == 'len') {
        // Convert to meters first
        double inMeters = inputValue;
        Map<String, double> toMeters = {
          'm': 1,
          'km': 1000,
          'cm': 0.01,
          'mm': 0.001,
          'μm': 0.000001,
          'nm': 0.000000001,
          'mi': 1609.344,
          'yd': 0.9144,
          'ft': 0.3048,
          'in': 0.0254,
        };
        inMeters *= toMeters[_fromUnit] ?? 1;
        result = inMeters / (toMeters[_toUnit] ?? 1);
      }
      // Area conversions
      else if (_selectedUnit == 'area') {
        // Convert to square meters first
        double inSquareMeters = inputValue;
        Map<String, double> toSquareMeters = {
          'm²': 1,
          'km²': 1000000,
          'cm²': 0.0001,
          'mm²': 0.000001,
          'ha': 10000,
          'acre': 4046.86,
          'sq mi': 2589988.11,
          'sq yd': 0.836127,
          'sq ft': 0.092903,
          'sq in': 0.00064516,
        };
        inSquareMeters *= toSquareMeters[_fromUnit] ?? 1;
        result = inSquareMeters / (toSquareMeters[_toUnit] ?? 1);
      }
      // Volume conversions
      else if (_selectedUnit == 'vol') {
        // Convert to cubic meters first
        double inCubicMeters = inputValue;
        Map<String, double> toCubicMeters = {
          'm³': 1,
          'km³': 1000000000,
          'cm³': 0.000001,
          'mm³': 0.000000001,
          'L': 0.001,
          'mL': 0.000001,
          'gal': 0.003785,
          'qt': 0.000946,
          'pt': 0.000473,
          'fl oz': 0.0000296,
          'cu ft': 0.0283168,
          'cu in': 0.0000164,
        };
        inCubicMeters *= toCubicMeters[_fromUnit] ?? 1;
        result = inCubicMeters / (toCubicMeters[_toUnit] ?? 1);
      }
      // Temperature conversions
      else if (_selectedUnit == 'temp') {
        if (_fromUnit == '°C') {
          if (_toUnit == '°F') result = (inputValue * 9 / 5) + 32;
          if (_toUnit == 'K') result = inputValue + 273.15;
          if (_toUnit == 'R') result = (inputValue + 273.15) * 9 / 5;
          if (_toUnit == '°C') result = inputValue;
        } else if (_fromUnit == '°F') {
          double celsius = (inputValue - 32) * 5 / 9;
          if (_toUnit == '°C') result = celsius;
          if (_toUnit == 'K') result = celsius + 273.15;
          if (_toUnit == 'R') result = inputValue + 459.67;
          if (_toUnit == '°F') result = inputValue;
        } else if (_fromUnit == 'K') {
          if (_toUnit == '°C') result = inputValue - 273.15;
          if (_toUnit == '°F') result = (inputValue * 9 / 5) - 459.67;
          if (_toUnit == 'R') result = inputValue * 9 / 5;
          if (_toUnit == 'K') result = inputValue;
        } else if (_fromUnit == 'R') {
          if (_toUnit == '°C') result = (inputValue - 491.67) * 5 / 9;
          if (_toUnit == '°F') result = inputValue - 459.67;
          if (_toUnit == 'K') result = inputValue * 5 / 9;
          if (_toUnit == 'R') result = inputValue;
        }
      }
      // Mass conversions
      else if (_selectedUnit == 'mass') {
        // Convert to grams first
        double inGrams = inputValue;
        Map<String, double> toGrams = {
          'kg': 1000,
          'g': 1,
          'mg': 0.001,
          'μg': 0.000001,
          'ton': 907185,
          'lb': 453.592,
          'oz': 28.3495,
          'ct': 0.2,
          'gr': 0.0648,
        };
        inGrams *= toGrams[_fromUnit] ?? 1;
        result = inGrams / (toGrams[_toUnit] ?? 1);
      }
      // Time conversions
      else if (_selectedUnit == 'time') {
        // Convert to seconds first
        double inSeconds = inputValue;
        Map<String, double> toSeconds = {
          's': 1,
          'ms': 0.001,
          'μs': 0.000001,
          'ns': 0.000000001,
          'min': 60,
          'h': 3600,
          'day': 86400,
          'week': 604800,
          'month': 2592000,
          'year': 31536000,
        };
        inSeconds *= toSeconds[_fromUnit] ?? 1;
        result = inSeconds / (toSeconds[_toUnit] ?? 1);
      }
      // Data conversions
      else if (_selectedUnit == 'data') {
        // Convert to bytes first
        double inBytes = inputValue;
        Map<String, double> toBytes = {
          'bit': 0.125,
          'B': 1,
          'KB': 1024,
          'MB': 1048576,
          'GB': 1073741824,
          'TB': 1099511627776,
          'PB': 1125899906842624,
        };
        inBytes *= toBytes[_fromUnit] ?? 1;
        result = inBytes / (toBytes[_toUnit] ?? 1);
      }
      // Speed conversions
      else if (_selectedUnit == 'speed') {
        // Convert to meters per second first
        double inMPS = inputValue;
        Map<String, double> toMPS = {
          'm/s': 1,
          'km/h': 0.277778,
          'mi/h': 0.44704,
          'ft/s': 0.3048,
          'kn': 0.514444,
        };
        inMPS *= toMPS[_fromUnit] ?? 1;
        result = inMPS / (toMPS[_toUnit] ?? 1);
      }
      // Energy conversions
      else if (_selectedUnit == 'energy') {
        // Convert to Joules first
        double inJoules = inputValue;
        Map<String, double> toJoules = {
          'J': 1,
          'kJ': 1000,
          'cal': 4.184,
          'kcal': 4184,
          'eV': 1.602176634e-19,
          'kWh': 3600000,
          'BTU': 1055.06,
          'ft⋅lb': 1.355818,
        };
        inJoules *= toJoules[_fromUnit] ?? 1;
        result = inJoules / (toJoules[_toUnit] ?? 1);
      }
      // Power conversions
      else if (_selectedUnit == 'power') {
        // Convert to Watts first
        double inWatts = inputValue;
        Map<String, double> toWatts = {
          'W': 1,
          'kW': 1000,
          'MW': 1000000,
          'hp': 745.7,
          'BTU/h': 0.29307107,
          'ft⋅lb/s': 1.355818,
        };
        inWatts *= toWatts[_fromUnit] ?? 1;
        result = inWatts / (toWatts[_toUnit] ?? 1);
      }
      // Pressure conversions
      else if (_selectedUnit == 'pressure') {
        // Convert to Pascals first
        double inPascals = inputValue;
        Map<String, double> toPascals = {
          'Pa': 1,
          'kPa': 1000,
          'MPa': 1000000,
          'bar': 100000,
          'psi': 6894.76,
          'atm': 101325,
          'mmHg': 133.322,
          'inHg': 3386.39,
          'torr': 133.322,
        };
        inPascals *= toPascals[_fromUnit] ?? 1;
        result = inPascals / (toPascals[_toUnit] ?? 1);
      }
      // Angle conversions
      else if (_selectedUnit == 'angle') {
        // Convert to degrees first
        double inDegrees = inputValue;
        Map<String, double> toDegrees = {
          'deg': 1,
          'rad': 57.2958,
          'grad': 0.9,
          'arcmin': 1 / 60,
          'arcsec': 1 / 3600,
          'rev': 360,
        };
        inDegrees *= toDegrees[_fromUnit] ?? 1;
        result = inDegrees / (toDegrees[_toUnit] ?? 1);
      }
      // Frequency conversions
      else if (_selectedUnit == 'frequency') {
        // Convert to Hertz first
        double inHertz = inputValue;
        Map<String, double> toHertz = {
          'Hz': 1,
          'kHz': 1000,
          'MHz': 1000000,
          'GHz': 1000000000,
          'rpm': 1 / 60,
          'rad/s': 0.159155,
        };
        inHertz *= toHertz[_fromUnit] ?? 1;
        result = inHertz / (toHertz[_toUnit] ?? 1);
      }
      // Current conversions
      else if (_selectedUnit == 'current') {
        // Convert to Amperes first
        double inAmperes = inputValue;
        Map<String, double> toAmperes = {
          'A': 1,
          'mA': 0.001,
          'μA': 0.000001,
          'kA': 1000,
        };
        inAmperes *= toAmperes[_fromUnit] ?? 1;
        result = inAmperes / (toAmperes[_toUnit] ?? 1);
      }
      // Voltage conversions
      else if (_selectedUnit == 'voltage') {
        // Convert to Volts first
        double inVolts = inputValue;
        Map<String, double> toVolts = {
          'V': 1,
          'mV': 0.001,
          'μV': 0.000001,
          'kV': 1000,
          'MV': 1000000,
        };
        inVolts *= toVolts[_fromUnit] ?? 1;
        result = inVolts / (toVolts[_toUnit] ?? 1);
      }
      // Resistance conversions
      else if (_selectedUnit == 'resistance') {
        // Convert to Ohms first
        double inOhms = inputValue;
        Map<String, double> toOhms = {
          'Ω': 1,
          'mΩ': 0.001,
          'kΩ': 1000,
          'MΩ': 1000000,
        };
        inOhms *= toOhms[_fromUnit] ?? 1;
        result = inOhms / (toOhms[_toUnit] ?? 1);
      }

      setState(() {
        _output = result.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
      });
    } catch (e) {
      setState(() => _output = 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      child: Scaffold(
        body: Column(
          children: [
            // Modern AppBar with gradient
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (unitData[_selectedUnit]!['color'] as Color).withOpacity(
                      0.8,
                    ),
                    (unitData[_selectedUnit]!['color'] as Color).withOpacity(
                      0.2,
                    ),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Unit Converter',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Categories ScrollView
            Container(
              height: 90,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: unitData.length,
                itemBuilder: (context, index) {
                  String key = unitData.keys.elementAt(index);
                  Map<String, dynamic> data = unitData[key]!;
                  bool isSelected = _selectedUnit == key;

                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedUnit = key;
                      _fromUnit = '';
                      _toUnit = '';
                      _output = '';
                    }),
                    child: Container(
                      width: 70,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 16 : 8,
                        right: index == unitData.length - 1 ? 16 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (data['color'] as Color).withOpacity(0.15)
                            : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (data['color'] as Color)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            data['icon'] as IconData,
                            color: isSelected
                                ? (data['color'] as Color)
                                : Colors.white54,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['title'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input and Unit Selection Section
            Expanded(
              child: Column(
                children: [
                  // Input and From Units Row
                  Expanded(
                    child: Row(
                      children: [
                        // Input Field
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Input Value',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Center(
                                    child: TextField(
                                      controller: _inputController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter value',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 32,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        setState(() {
                                          _input = value;
                                          _convertUnit();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // From Unit Selection
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'From',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    itemCount:
                                        unitOptions[_selectedUnit]!.length,
                                    itemBuilder: (context, index) {
                                      String unit =
                                          unitOptions[_selectedUnit]![index];
                                      bool isSelected = _fromUnit == unit;
                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _fromUnit = unit;
                                              _convertUnit();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (unitData[_selectedUnit]![
                                                          'color'] as Color)
                                                      .withOpacity(0.2)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              unit,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white70,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Output and To Units Row
                  Expanded(
                    child: Row(
                      children: [
                        // Output Display
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (unitData[_selectedUnit]!['color'] as Color)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    (unitData[_selectedUnit]!['color'] as Color)
                                        .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Result',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Center(
                                    child: _output.isNotEmpty &&
                                            _fromUnit.isNotEmpty &&
                                            _toUnit.isNotEmpty
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _output,
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$_fromUnit → $_toUnit',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      unitData[_selectedUnit]![
                                                          'color'] as Color,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Waiting for input...',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // To Unit Selection
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'To',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    itemCount:
                                        unitOptions[_selectedUnit]!.length,
                                    itemBuilder: (context, index) {
                                      String unit =
                                          unitOptions[_selectedUnit]![index];
                                      bool isSelected = _toUnit == unit;
                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _toUnit = unit;
                                              _convertUnit();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (unitData[_selectedUnit]![
                                                          'color'] as Color)
                                                      .withOpacity(0.2)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              unit,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white70,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
