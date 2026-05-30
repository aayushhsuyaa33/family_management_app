import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VoiceCommandScreen extends StatefulWidget {
  const VoiceCommandScreen({super.key});

  @override
  State<VoiceCommandScreen> createState() => _VoiceCommandScreenState();
}

class _VoiceCommandScreenState extends State<VoiceCommandScreen>
    with TickerProviderStateMixin {
  late AnimationController pulseController;

  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        heading: "Voice Commands",
        subTitle: "Use Voice to add tasks & events",
      ),

      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) {
                return SizedBox(
                  height: 350,
                  width: 350,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _pulseRing(220),
                      _pulseRing(180),
                      _pulseRing(140),
                      Lottie.asset(AppImages.aiMovingCircle),

                      // Wave bars
                      // ...List.generate(24, (index) => _waveBar(index)),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Recognized text
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(150)),
              ),
              child: const Text(
                "Assign cleaning task to John tomorrow at 9:00 AM",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const Spacer(),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.orange,
                    onTap: () {
                      setState(() {
                        isMuted = !isMuted;
                      });
                    },
                  ),
                  _actionButton(
                    icon: Icons.close,
                    color: Colors.redAccent,
                    onTap: () {},
                  ),
                  _actionButton(
                    icon: Icons.send_rounded,
                    color: Colors.green,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pulseRing(double size) {
    final scale = 0.8 + (pulseController.value * 0.4);

    return Transform.scale(
      scale: scale,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blueAccent.withOpacity(
              0.4 - (pulseController.value * 0.3),
            ),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(70),
          border: Border.all(color: color.withAlpha(70)),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
