class ChoiceManager {
  List<String> _choices = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  List<String> get choices => List.unmodifiable(_choices);

  void addChoice(String choice) {
    if (choice.trim().isNotEmpty) {
      _choices.add(choice.trim());
    }
  }

  void removeChoice(int index) {
    if (index >= 0 && index < _choices.length) {
      _choices.removeAt(index);
    }
  }

  void updateChoice(int index, String newChoice) {
    if (index >= 0 && index < _choices.length && newChoice.trim().isNotEmpty) {
      _choices[index] = newChoice.trim();
    }
  }

  void clearAllChoices() {
    _choices.clear();
  }

  bool get isEmpty => _choices.isEmpty;
  int get length => _choices.length;
}