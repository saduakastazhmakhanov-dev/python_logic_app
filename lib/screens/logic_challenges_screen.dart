import 'dart:math';

import 'package:flutter/material.dart';

class LogicChallengesScreen extends StatefulWidget {
  const LogicChallengesScreen({super.key});

  @override
  State<LogicChallengesScreen> createState() => _LogicChallengesScreenState();
}

class _LogicChallengesScreenState extends State<LogicChallengesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _random = Random();

  late final List<_ParsonsProblem> _parsonsProblems;
  late final List<_PredictOutputProblem> _predictProblems;

  int _parsonsIndex = 0;
  int _predictIndex = 0;

  late List<String> _parsonsCurrent;
  bool _parsonsSolved = false;

  int? _selectedOption;
  bool _predictSolved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _parsonsProblems = [
      _ParsonsProblem(
        title: "If шарты",
        prompt: "Кодты дұрыс ретке қой: егер x 10-нан үлкен болса, 'Big' шығарсын, әйтпесе 'Small'.",
        correct: const [
          "x = 7",
          "if x > 10:",
          "    print('Big')",
          "else:",
          "    print('Small')",
        ],
      ),
      _ParsonsProblem(
        title: "For циклы",
        prompt: "Кодты дұрыс ретке қой: 1-ден 3-ке дейінгі сандардың қосындысын есептесін.",
        correct: const [
          "total = 0",
          "for i in range(1, 4):",
          "    total += i",
          "print(total)",
        ],
      ),
      _ParsonsProblem(
        title: "Айнымалыны жаңарту",
        prompt: "Кодты дұрыс ретке қой: x-ті 2 есе көбейтіп, нәтижесін шығар.",
        correct: const [
          "x = 5",
          "x = x * 2",
          "print(x)",
        ],
      ),
    ];

    _predictProblems = [
      _PredictOutputProblem(
        title: "Қосу",
        code: "x = 5\ny = 10\nprint(x + y)",
        options: const ["15", "510", "Error"],
        correctIndex: 0,
      ),
      _PredictOutputProblem(
        title: "For + жинақтау",
        code: "s = 0\nfor i in range(3):\n    s += i\nprint(s)",
        options: const ["3", "6", "0", "Error"],
        correctIndex: 0,
      ),
      _PredictOutputProblem(
        title: "If/else",
        code: "x = 12\nif x > 10:\n    print('A')\nelse:\n    print('B')",
        options: const ["A", "B", "AB", "Error"],
        correctIndex: 0,
      ),
    ];

    _loadParsons();
    _loadPredict();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadParsons() {
    final p = _parsonsProblems[_parsonsIndex];
    _parsonsCurrent = List<String>.from(p.correct);
    _parsonsCurrent.shuffle(_random);
    _parsonsSolved = false;
  }

  void _loadPredict() {
    _selectedOption = null;
    _predictSolved = false;
  }

  void _nextParsons() {
    setState(() {
      _parsonsIndex = (_parsonsIndex + 1) % _parsonsProblems.length;
      _loadParsons();
    });
  }

  void _nextPredict() {
    setState(() {
      _predictIndex = (_predictIndex + 1) % _predictProblems.length;
      _loadPredict();
    });
  }

  void _checkParsons() {
    final correct = _parsonsProblems[_parsonsIndex].correct;
    final ok = _listEquals(_parsonsCurrent, correct);
    if (!mounted) return;

    setState(() {
      _parsonsSolved = ok;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Логикалық дұрыс!" : "Әлі де тексеріп көр: шарт/цикл реті дұрыс па?"),
        backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  void _checkPredict() {
    final p = _predictProblems[_predictIndex];
    final ok = _selectedOption == p.correctIndex;
    if (!mounted) return;

    setState(() {
      _predictSolved = ok;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Логикалық дұрыс!" : "Дұрыс емес. Айнымалылардың мәнін қадамдап есептеп көр."),
        backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logic Challenges"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Parson's"),
            Tab(text: "Predict Output"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParsons(context),
          _buildPredict(context),
        ],
      ),
    );
  }

  Widget _buildParsons(BuildContext context) {
    final p = _parsonsProblems[_parsonsIndex];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _headerCard(
            context,
            title: "Parson's Problems • ${p.title}",
            subtitle: p.prompt,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _parsonsCurrent.length,
                buildDefaultDragHandles: true,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _parsonsCurrent.removeAt(oldIndex);
                    _parsonsCurrent.insert(newIndex, item);
                    _parsonsSolved = false;
                  });
                },
                itemBuilder: (context, i) {
                  final line = _parsonsCurrent[i];
                  return Container(
                    key: ValueKey("$i|$line"),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.white54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            line,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 15,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _checkParsons,
                  icon: const Icon(Icons.check),
                  label: const Text("Тексеру", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => setState(_loadParsons),
                  icon: const Icon(Icons.shuffle),
                  label: const Text("Араластыру"),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: "Келесі",
                onPressed: _nextParsons,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          if (_parsonsSolved)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Логикалық дұрыс!",
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPredict(BuildContext context) {
    final p = _predictProblems[_predictIndex];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _headerCard(
            context,
            title: "Predict Output • ${p.title}",
            subtitle: "Кодты іске қоспай, нәтижесін логикамен тап.",
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                p.code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: RadioGroup<int>(
                groupValue: _selectedOption,
                onChanged: (v) => setState(() {
                  _selectedOption = v;
                  _predictSolved = false;
                }),
                child: ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: p.options.length,
                  itemBuilder: (context, i) {
                    return RadioListTile<int>(
                      value: i,
                      activeColor: Colors.amber,
                      title: Text(
                        p.options[i],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _selectedOption == null ? null : _checkPredict,
                  icon: const Icon(Icons.check),
                  label: const Text("Тексеру", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => setState(_loadPredict),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Қайта таңдау"),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: "Келесі",
                onPressed: _nextPredict,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          if (_predictSolved)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Логикалық дұрыс!",
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerCard(BuildContext context, {required String title, required String subtitle}) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.psychology, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _ParsonsProblem {
  final String title;
  final String prompt;
  final List<String> correct;

  _ParsonsProblem({
    required this.title,
    required this.prompt,
    required this.correct,
  });
}

class _PredictOutputProblem {
  final String title;
  final String code;
  final List<String> options;
  final int correctIndex;

  _PredictOutputProblem({
    required this.title,
    required this.code,
    required this.options,
    required this.correctIndex,
  });
}

