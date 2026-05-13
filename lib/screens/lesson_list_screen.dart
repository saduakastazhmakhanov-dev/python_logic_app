import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import 'auth_screen.dart'; // globalCurrentUser үшін
import 'lesson_page.dart';
import 'logic_challenges_screen.dart';

// Сабақтар деректері
final List<Lesson> lessonsData = [
  Lesson(
    id: 1,
    title: "1. Python-ға кіріспе",
    theory: "Python — әлемдегі ең танымал әрі оқуға жеңіл бағдарламалау тілі. Оны 1991 жылы Гвидо ван Россум ойлап тапқан. Негізгі ерекшеліктері: • Кодтың оқылуы өте оңай. • Көптеген салаларда қолданылады. Экранға шығару: print() функциясы қолданылады. Мәтін міндетті түрде тырнақша ішінде жазылуы тиіс. Мысалы: print('Сәлем, әлем!')",
    videoUrl: "https://youtu.be/la_FZsaFIT0",
    quiz: [
      QuizQuestion(question: "print(5+5)?", answers: ["55", "10", "Error"], correctAnswerIndex: 1, description: "Математикалық қосынды орындалады."),
      QuizQuestion(question: "Авторы кім?", answers: ["Гвидо", "Билл", "Стив"], correctAnswerIndex: 0, description: "Гвидо ван Россум - Python негізін қалаушы."),
      QuizQuestion(question: "Мәтін қалай жазылады?", answers: ["' ' ішінде", "Жай", "[]"], correctAnswerIndex: 0, description: "Python-да мәтін тырнақшаға алынады."),
      QuizQuestion(question: "print('A'*2)?", answers: ["A2", "AA", "Error"], correctAnswerIndex: 1, description: "Мәтінді санға көбейтсе, ол қайталанады."),
      QuizQuestion(question: "Шыққан жылы?", answers: ["1991", "2000", "1985"], correctAnswerIndex: 0, description: "1991 жылы жарық көрді."),
      QuizQuestion(question: "print(10//3)?", answers: ["3.3", "3", "1"], correctAnswerIndex: 1, description: "// операторы бүтін бөлікті алады."),
      QuizQuestion(question: "Кеңейтілімі?", answers: [".py", ".dart", ".txt"], correctAnswerIndex: 0, description: "Python файлдары .py болып сақталады.")
    ],
  ),
  Lesson(
    id: 2,
    title: "2. Айнымалылар және типтер",
    theory: """Айнымалы — бұл мәліметтерді уақытша сақтайтын 'қорап' сияқты.
    
Негізгі деректер типтері:
1. int — бүтін сандар.
2. float — бөлшек сандар.
3. str — мәтіндік жолдар.
4. bool — логикалық мәндер.""",
    videoUrl: "https://youtu.be/whFHHIg50nI",
    quiz: [
      QuizQuestion(question: "x=5 түрі қандай?", answers: ["str", "int", "float"], correctAnswerIndex: 1, description: "5 - бүтін сан (integer)."),
      QuizQuestion(question: "Қайсысы қате?", answers: ["_v", "1v", "v1"], correctAnswerIndex: 1, description: "Айнымалы саннан басталмайды."),
      QuizQuestion(question: "bool мәндері?", answers: ["0,1", "True, False", "Text"], correctAnswerIndex: 1, description: "Логикалық типте тек екі мән болады.")
    ],
  ),
  Lesson(
    id: 3,
    title: "3. Математикалық операторлар",
    theory: "Python сандармен жұмыс істеуге арналған қуатты операторларға ие: +, -, *, /, %, //, **.",
    videoUrl: "https://youtu.be/cTyV3mmw92M",
    quiz: [
      QuizQuestion(question: "10 % 3 мәні?", answers: ["3", "1", "0"], correctAnswerIndex: 1, description: "10-ды 3-ке бөлгендегі қалдық - 1.")
    ],
  ),
  Lesson(
    id: 4,
    title: "4. Пайдаланушымен байланыс: input()",
    theory: "input() функциясы пайдаланушыдан мәлімет алу үшін қолданылады. Ол әрқашан str (мәтін) қайтарады.",
    videoUrl: "https://youtu.be/sWaE84WJDf4",
    quiz: [
      QuizQuestion(question: "input() не қайтарады?", answers: ["int", "str", "bool"], correctAnswerIndex: 1, description: "Әдепкі бойынша мәтін қайтарады.")
    ],
  ),
  Lesson(
    id: 5,
    title: "5. Шарттар (If)",
    theory: "if, elif және else блоктары шартты тексеру үшін қолданылады. Салыстыру үшін == белгісі керек.",
    videoUrl: "https://youtu.be/Er_Qw-Y1i6o",
    quiz: [
      QuizQuestion(question: "Теңдік белгісі?", answers: ["=", "==", "==="], correctAnswerIndex: 1, description: "== - салыстыру операторы.")
    ],
  ),
  Lesson(
    id: 6,
    title: "6. For циклы",
    theory: """Бір іс-әрекетті бірнеше рет қайталау үшін 'for' циклі қолданылады. Ол көбінесе белгілі бір ауқымда (range) немесе тізім ішінде жұмыс істейді.
    
Мысалы:
range(5) — 0, 1, 2, 3, 4 сандарын береді (соңғы сан кірмейді).""",
    videoUrl: "https://youtu.be/lK_DHrNdmps",
    quiz: [
      QuizQuestion(
        question: "range(5) функциясы неше сан береді?",
        answers: ["4", "5", "6"],
        correctAnswerIndex: 1,
        description: "0-ден 4-ке дейін, барлығы 5 сан.",
      ),
      QuizQuestion(
        question: "Циклды бірден тоқтату үшін не қолданылады?",
        answers: ["stop", "break", "exit"],
        correctAnswerIndex: 1,
        description: "break операторы циклды мәжбүрлі түрде тоқтатады.",
      ),
    ],
  ),

  // 7-ші сабақ
  Lesson(
    id: 7,
    title: "7. While циклы",
    theory: """'while' циклі берілген шарт орындалып тұрғанша (True болса) жұмыс істей береді. 
Абай болыңыз: егер шарт ешқашан бұзылмаса, бағдарлама 'шексіз циклге' түсіп, қатып қалады.
    
Мысалы:
count = 0
while count < 3:
    print(count)
    count += 1""",
    videoUrl: "https://youtu.be/QLS1c6uKjUI",
    quiz: [
      QuizQuestion(
        question: "While циклі қашан тоқтайды?",
        answers: ["Шарт True болғанда", "Шарт False болғанда", "Ешқашан"],
        correctAnswerIndex: 1,
        description: "Шарт жалған (False) болған сәтте цикл жұмысын аяқтайды.",
      ),
    ],
  ),

  // 8-ші сабақ
  Lesson(
    id: 8,
    title: "8. Тізімдер (Lists)",
    theory: """Тізім бір айнымалының ішінде бірнеше мәнді сақтауға мүмкіндік береді. Тізім элементтері шаршы жақшаның [ ] ішіне жазылады.
    
Негізгі функциялар:
• append() — соңына элемент қосу.
• len() — тізім ұзындығын табу.
• Индекстеу 0-ден басталады.""",
    videoUrl: "https://youtu.be/zuWevAzox04",
    quiz: [
      QuizQuestion(
        question: "Тізімнің ең бірінші элементінің индексі неше?",
        answers: ["1", "0", "-1"],
        correctAnswerIndex: 1,
        description: "Бағдарламалауда санау әрқашан 0-ден басталады.",
      ),
    ],
  ),

  // 9-шы сабақ
  Lesson(
    id: 9,
    title: "9. Функциялар",
    theory: """Функция — бұл кодтың қайталанатын бөлігі. Оны бір рет жазып, бағдарламаның кез келген жерінде шақыруға болады. 
    
Python-да функция 'def' кілт сөзімен басталады.
Мысалы:
def slem():
    print("Сәлем!")""",
    videoUrl: "https://youtu.be/ohawYNNmKYM",
    quiz: [
      QuizQuestion(
        question: "Функцияны жариялау үшін қай сөз қолданылады?",
        answers: ["func", "def", "function"],
        correctAnswerIndex: 1,
        description: "def — 'define' (анықтау) сөзінен шыққан.",
      ),
    ],
  ),

  // 10-шы сабақ
  Lesson(
    id: 10,
    title: "10. Try-Except (Қателермен жұмыс)",
    theory: """Бағдарлама жұмыс істеп тұрғанда қате (Exception) шықса, ол тоқтап қалмауы үшін 'try-except' блогы қолданылады.
    
• try: қауіпті код жазылады.
• except: қате болғанда не істеу керектігі жазылады.
• finally: қате болса да, болмаса да орындалатын код.""",
    videoUrl: "https://youtu.be/oQyvvPg2QaE",
    quiz: [
      QuizQuestion(
        question: "Қатені 'ұстап алу' үшін қай блок жауапты?",
        answers: ["try", "except", "error"],
        correctAnswerIndex: 1,
        description: "except блогы қате шыққан жағдайда іске қосылады.",
      ),
    ],
  ),
];

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});
  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Оқу бағдарламасы")),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: lessonsData.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white24,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.psychology, color: Colors.amber, size: 35),
                title: const Text("Логикалық жаттығулар", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: const Text("Parson's Problems"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (c) => const LogicChallengesScreen()));
                  if (mounted) setState(() {});
                },
              ),
            );
          }

          final lesson = lessonsData[i - 1];
          bool isLocked = globalCurrentUser != null && lesson.id > globalCurrentUser!.progress;
          bool isCompleted = globalCurrentUser != null && lesson.id < globalCurrentUser!.progress;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: isLocked ? Colors.white10 : Colors.white24,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.play_circle_fill),
                color: isLocked ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.amber),
                size: 35,
              ),
              title: Text(lesson.title, style: TextStyle(fontWeight: isLocked ? FontWeight.normal : FontWeight.bold, fontSize: 18)),
              subtitle: Text(isLocked ? "Бұғатталған" : (isCompleted ? "Аяқталды (+70 XP)" : "Қазіргі сабақ")),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              onTap: isLocked ? null : () async {
                await Navigator.push(context, MaterialPageRoute(builder: (c) => LessonPage(lesson: lesson)));
                if (mounted) setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}