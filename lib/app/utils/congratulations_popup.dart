import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CongratulationButton extends StatefulWidget {
  const CongratulationButton({super.key});

  @override
  State<CongratulationButton> createState() => _CongratulationButtonState();
}

class _CongratulationButtonState extends State<CongratulationButton> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onPressed() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        IconButton(
          icon: const Icon(Icons.done, color: Colors.green, size: 30),
          onPressed: _onPressed,
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality:
              BlastDirectionality.explosive, // spread in all directions
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
          numberOfParticles: 20,
          maxBlastForce: 20,
          minBlastForce: 10,
          emissionFrequency: 0.05,
          gravity: 0.1,
        ),
      ],
    );
  }
}
