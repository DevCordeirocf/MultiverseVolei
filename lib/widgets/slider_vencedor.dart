import 'package:flutter/material.dart';
import '../models/game_models.dart';

class SliderVencedor extends StatefulWidget {
  final Team teamA;
  final Team teamB;
  final Function(Team vencedor) onVencedorSelecionado;

  const SliderVencedor({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.onVencedorSelecionado,
  });

  @override
  State<SliderVencedor> createState() => _SliderVencedorState();
}

class _SliderVencedorState extends State<SliderVencedor> {
  double _value = 0.5; 

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90A4).withOpacity(_value < 0.3 ? 1.0 : 0.6),
            const Color(0xFFD32F2F).withOpacity(_value > 0.7 ? 1.0 : 0.6),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text("<<< VENCEDOR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text("VENCEDOR >>>", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 60,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 25),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: _value,
              onChanged: (val) => setState(() => _value = val),
              onChangeEnd: (val) {
                if (val <= 0.1) {
                  widget.onVencedorSelecionado(widget.teamA);
                } else if (val >= 0.9) {
                  widget.onVencedorSelecionado(widget.teamB);
                }
                setState(() => _value = 0.5);
              },
            ),
          ),
        ],
      ),
    );
  }
}
