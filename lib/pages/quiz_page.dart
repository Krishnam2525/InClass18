import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List questions = [];
  int index = 0;
  int score = 0;
  bool loading = true;
  bool answered = false;
  List<String> answers = [];
  String correct = "";

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() => loading = true);
    questions = await ApiService.fetchQuestions();
    setup();
    setState(() => loading = false);
  }

  void setup() {
    final q = questions[index];
    correct = q["correct_answer"];
    answers = [...q["incorrect_answers"], correct]..shuffle();
    answered = false;
  }

  void pick(String a) {
    if (answered) return;
    setState(() {
      answered = true;
      if (a == correct) score++;
    });
  }

  void next() {
    if (index < questions.length - 1) {
      setState(() {
        index++;
        setup();
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Quiz Finished!"),
          content: Text("Score: $score / ${questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                index = 0;
                score = 0;
                loadQuestions();
              },
              child: const Text("Restart"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[index];

    return Scaffold(
      appBar: AppBar(
        title: Text("Q ${index + 1} / ${questions.length}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q["question"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...answers.map(
              (a) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: answered
                        ? a == correct
                            ? Colors.green
                            : Colors.red
                        : null,
                  ),
                  onPressed: () => pick(a),
                  child: Text(a),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: next,
                child: const Text("Next"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

