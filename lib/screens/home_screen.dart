import 'package:choice_wheel/shared/choice_list_item.dart';
import 'package:choice_wheel/shared/choice_manager.dart';
import 'package:choice_wheel/shared/winner_dialog.dart';
import 'package:choice_wheel/widgets/wheel_widget.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChoiceManager _choiceManager = ChoiceManager();
  final TextEditingController _addController = TextEditingController();

  void _addChoice() {
    if (_addController.text.trim().isNotEmpty) {
      setState(() {
        _choiceManager.addChoice(_addController.text.trim());
        _addController.clear();
      });
    }
  }

  void _removeChoice(int index) {
    setState(() {
      _choiceManager.removeChoice(index);
    });
  }

  void _editChoice(int index, String newChoice) {
    setState(() {
      _choiceManager.updateChoice(index, newChoice);
    });
  }

  void _showWinner(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinnerDialog(winner: winner),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
            
          ),
          // Wheel Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                WheelWidget(
                  choices: _choiceManager.choices,
                  onSpinComplete: _showWinner,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tap the wheel to spin!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Add Choice Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: 'Add new choice',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                      ),
                    ),
                    onSubmitted: (_) => _addChoice(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addChoice,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Choices List
          Expanded(
            child: _choiceManager.isEmpty
                ? const Center(
                    child: Text(
                      'No choices yet!\nAdd some options to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _choiceManager.length,
                    itemBuilder: (context, index) {
                      return ChoiceListItem(
                        choice: _choiceManager.choices[index],
                        index: index,
                        onDelete: () => _removeChoice(index),
                        onEdit: (newChoice) => _editChoice(index, newChoice),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }
}