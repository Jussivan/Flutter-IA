import 'package:flutter/material.dart';
import '../services/audio_classifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioClassifier _classifier = AudioClassifier();
  String _currentCommand = 'Nenhum';
  bool _isListening = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeClassifier();
  }

  Future<void> _initializeClassifier() async {
    try {
      await _classifier.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _showError('Erro ao inicializar: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      _showError('Classificador não inicializado');
      return;
    }

    if (_isListening) {
      await _classifier.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      await _classifier.startListening((command) {
        setState(() {
          _currentCommand = command;
        });
      });
      setState(() {
        _isListening = true;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _getIconForCommand(String command) {
    switch (command.toLowerCase()) {
      case 'cima':
        return Icons.arrow_upward;
      case 'baixo':
        return Icons.arrow_downward;
      case 'esquerdo':
      case 'esquerda':
        return Icons.arrow_back;
      case 'direito':
      case 'direita':
        return Icons.arrow_forward;
      case 'ligado':
        return Icons.power_settings_new;
      case 'desligado':
        return Icons.power_off;
      default:
        return Icons.mic_off;
    }
  }

  Color _getColorForCommand(String command) {
    switch (command.toLowerCase()) {
      case 'cima':
        return Colors.blue;
      case 'baixo':
        return Colors.orange;
      case 'esquerdo':
      case 'esquerda':
        return Colors.purple;
      case 'direito':
      case 'direita':
        return Colors.green;
      case 'ligado':
        return Colors.teal;
      case 'desligado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconhecimento de Comandos de Voz'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone animado do comando
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _getColorForCommand(_currentCommand).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForCommand(_currentCommand),
                size: 120,
                color: _getColorForCommand(_currentCommand),
              ),
            ),
            const SizedBox(height: 40),
            
            // Texto do comando reconhecido
            const Text(
              'Comando Reconhecido:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _currentCommand.toUpperCase(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _getColorForCommand(_currentCommand),
              ),
            ),
            const SizedBox(height: 60),
            
            // Botão de controle
            ElevatedButton.icon(
              onPressed: _isInitialized ? _toggleListening : null,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'Parar' : 'Iniciar Escuta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            
            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isListening ? Icons.circle : Icons.circle_outlined,
                    color: _isListening ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isListening ? 'Escutando...' : 'Aguardando',
                    style: TextStyle(
                      color: _isListening ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
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

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }
}
