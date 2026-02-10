import 'package:flutter/material.dart';
import '../models/game_models.dart';

class SliderVencedor extends StatefulWidget {
  final Function(Team) onTeamSelected;
  final Team teamA;
  final Team teamB;

  const SliderVencedor({
    super.key,
    required this.onTeamSelected,
    required this.teamA,
    required this.teamB,
  });

  @override
  State<SliderVencedor> createState() => _SliderVencedorState();
}

class _SliderVencedorState extends State<SliderVencedor> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Slider
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.blue[400]!, Colors.red[400]!],
            ),
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 20,
                elevation: 4,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
              onChangeEnd: (value) {
                if (value < 0.5) {
                  widget.onTeamSelected(widget.teamA);
                } else {
                  widget.onTeamSelected(widget.teamB);
                }
                // Reset slider
                setState(() {
                  _sliderValue = 0.5;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TIME A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TIME B',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
