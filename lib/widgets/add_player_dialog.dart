import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/game_controller.dart';

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _nameController = TextEditingController();
  PlayerGender _selectedGender = PlayerGender.male;

  // Usamos um Set para evitar posições duplicadas e facilitar a seleção
  final Set<PlayerPosition> _selectedPositions = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty) return;

    // Chama o Controller para salvar
    Provider.of<GameController>(context, listen: false).addPlayer(
      _nameController.text,
      _selectedGender,
      _selectedPositions.toList(),
    );

    Navigator.of(context).pop(); // Fecha o dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Jogador 🏐'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de Nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome / Apelido',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),

            // Seleção de Gênero
            const Text('Gênero:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<PlayerGender>(
                    title: const Text('Masc'),
                    value: PlayerGender.male,
                    groupValue: _selectedGender,
                    onChanged: (val) => setState(() => _selectedGender = val!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<PlayerGender>(
                    title: const Text('Fem'),
                    value: PlayerGender.female,
                    groupValue: _selectedGender,
                    onChanged: (val) => setState(() => _selectedGender = val!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Seleção de Posições (Chips)
            const Text('Posições:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: PlayerPosition.values.map((pos) {
                final isSelected = _selectedPositions.contains(pos);
                return FilterChip(
                  label: Text(_getPositionName(pos)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedPositions.add(pos)
                          : _selectedPositions.remove(pos);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  // Auxiliar para nome bonito na tela
  String _getPositionName(PlayerPosition pos) {
    switch (pos) {
      case PlayerPosition.setter: return 'Levantador';
      case PlayerPosition.spiker: return 'Atacante';
      case PlayerPosition.libero: return 'Líbero';
      case PlayerPosition.allRounder: return 'Universal';
    }
  }
}