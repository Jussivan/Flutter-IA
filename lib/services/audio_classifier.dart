import 'dart:async';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioClassifier {
  Interpreter? _interpreter;
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _recordTimer;
  
  final List<String> _labels = [
    'cima',
    'baixo',
    'esquerdo',
    'direito',
    'ligado',
    'desligado',
  ];

  Future<void> initialize() async {
    try {
      // Carrega o modelo TFLite
      _interpreter = await Interpreter.fromAsset('assets/model/model.tflite');
      print('Modelo carregado com sucesso');
    } catch (e) {
      print('Erro ao carregar modelo: $e');
      rethrow;
    }
  }

  Future<void> startListening(Function(String) onCommandDetected) async {
    // Solicita permissão de microfone
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Permissão de microfone negada');
    }

    // Inicia gravação
    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      // Processa áudio periodicamente
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final path = await _recorder.stop();
        if (path != null) {
          final command = await _classifyAudio(path);
          onCommandDetected(command);
          
          // Reinicia gravação
          await _recorder.start(
            const RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 16000,
              numChannels: 1,
            ),
          );
        }
      });
    }
  }

  Future<String> _classifyAudio(String audioPath) async {
    if (_interpreter == null) {
      return 'Nenhum';
    }

    try {
      // Aqui você processaria o áudio e criaria o input tensor
      // Por simplicidade, vou simular com dados aleatórios
      // Em produção, você precisaria processar o arquivo de áudio
      
      // Exemplo de input shape: [1, 16000] para 1 segundo de áudio a 16kHz
      var input = List.generate(16000, (i) => 0.0);
      var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
      
      _interpreter!.run(input.reshape([1, 16000]), output);
      
      // Encontra o índice com maior probabilidade
      var maxIndex = 0;
      var maxValue = output[0][0];
      for (var i = 1; i < _labels.length; i++) {
        if (output[0][i] > maxValue) {
          maxValue = output[0][i];
          maxIndex = i;
        }
      }
      
      return _labels[maxIndex];
    } catch (e) {
      print('Erro na classificação: $e');
      return 'Nenhum';
    }
  }

  Future<void> stopListening() async {
    _recordTimer?.cancel();
    await _recorder.stop();
  }

  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    _interpreter?.close();
  }
}
