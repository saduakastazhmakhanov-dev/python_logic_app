import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import 'auth_screen.dart'; // globalCurrentUser үшін
import 'lesson_page.dart';

// Сабақтар деректері (Модельге толық айналдырылған нұсқасы)
final List<Lesson> lessonsData = [
  Lesson(
      id: 1,
      title: "1. Кіріспе",
      theory: "Python - 1991 жылы Гвидо ван Россум жасаған тіл. print() - экранға ақпарат шығарады.",
      quiz: [
        QuizQuestion(question: "print(5+5)?", answers: ["55", "10", "Error"], correctAnswerIndex: 1, description: "Математикалық қосынды орындалады."),
        QuizQuestion(question: "Авторы кім?", answers: ["Гвидо", "Билл", "Стив"], correctAnswerIndex: 0, description: "Гвидо ван Россум - Python негізін қалаушы."),
        QuizQuestion(question: "Мәтін қалай жазылады?", answers: ["' ' ішінде", "Жай", "[]"], correctAnswerIndex: 0, description: "Python-да мәтін тырнақшаға алынады."),
        QuizQuestion(question: "print('A'*2)?", answers: ["A2", "AA", "Error"], correctAnswerIndex: 1, description: "Мәтінді санға көбейтсе, ол қайталанады."),
        QuizQuestion(question: "Шыққан жылы?", answers: ["1991", "2000", "1985"], correctAnswerIndex: 0, description: "1991 жылы жарық көрді."),
        QuizQuestion(question: "print(10//3)?", answers: ["3.3", "3", "1"], correctAnswerIndex: 1, description: "// операторы бүтін бөлікті алады."),
        QuizQuestion(question: "Кеңейтілімі?", answers: [".py", ".dart", ".txt"], correctAnswerIndex: 0, description: "Python файлдары .py болып сақталады.")
      ]),
  Lesson(
      id: 2,
      title: "2. Айнымалылар",
      theory: "Айнымалы - мәліметті сақтайтын орын. int (бүтін), str (мәтін), bool (логикалық) түрлері бар.",
      quiz: [
        QuizQuestion(question: "x=5 түрі қандай?", answers: ["str", "int", "float"], correctAnswerIndex: 1, description: "5 - бүтін сан (integer)."),
        QuizQuestion(question: "Қайсысы қате?", answers: ["_v", "1v", "v1"], correctAnswerIndex: 1, description: "Айнымалы саннан басталмайды."),
        QuizQuestion(question: "bool мәндері?", answers: ["0,1", "True, False", "Text"], correctAnswerIndex: 1, description: "Логикалық типте тек екі мән болады."),
        QuizQuestion(question: "x='5' түрі?", answers: ["int", "str", "float"], correctAnswerIndex: 1, description: "Тырнақша ішіндегінің бәрі - мәтін."),
        QuizQuestion(question: "type() не істейді?", answers: ["Шығарады", "Типті анықтайды", "Өшіреді"], correctAnswerIndex: 1, description: "Айнымалының типін анықтауға арналған."),
        QuizQuestion(question: "x=2, y=3; x+y?", answers: ["5", "23", "Error"], correctAnswerIndex: 0, description: "2 + 3 = 5."),
        QuizQuestion(question: "str деген не?", answers: ["Сан", "Мәтін", "Тізім"], correctAnswerIndex: 1, description: "String - мәтіндік деректер типі.")
      ]),
  Lesson(
      id: 3,
      title: "3. Операторлар",
      theory: "Математикалық операторлар: +, -, *, /, % (қалдық), // (бүтін бөлік), ** (дәреже).",
      quiz: [
        QuizQuestion(question: "10 % 3 мәні?", answers: ["3", "1", "0"], correctAnswerIndex: 1, description: "10-ды 3-ке бөлгендегі қалдық - 1."),
        QuizQuestion(question: "2 ** 3 мәні?", answers: ["6", "8", "9"], correctAnswerIndex: 1, description: "2-нің 3 дәрежесі - 8."),
        QuizQuestion(question: "15 // 4 мәні?", answers: ["3", "3.75", "4"], correctAnswerIndex: 0, description: "15-тің ішінде 4 үш рет бүтін сыяды."),
        QuizQuestion(question: "2+2*2?", answers: ["8", "6", "4"], correctAnswerIndex: 1, description: "Алдымен көбейту орындалады."),
        QuizQuestion(question: "Қалдық белгісі?", answers: ["/", "//", "%"], correctAnswerIndex: 2, description: "% - қалдықты есептеу."),
        QuizQuestion(question: "Дәреже белгісі?", answers: ["^", "**", "*"], correctAnswerIndex: 1, description: "** - дәрежеге шығару."),
        QuizQuestion(question: "10 / 2 түрі?", answers: ["int", "float", "str"], correctAnswerIndex: 1, description: "/ операторы әрқашан бөлшек сан береді.")
      ]),
  Lesson(
      id: 4,
      title: "4. input() функциясы",
      theory: "input() қолданушыдан мәлімет алу үшін керек. Ол әрқашан 'str' (мәтін) қайтарады.",
      quiz: [
        QuizQuestion(question: "input() не қайтарады?", answers: ["int", "str", "bool"], correctAnswerIndex: 1, description: "Әдепкі бойынша мәтін қайтарады."),
        QuizQuestion(question: "Санға айналдыру?", answers: ["int()", "str()", "float()"], correctAnswerIndex: 0, description: "int() мәтінді санға айналдырады."),
        QuizQuestion(question: "input()+5 не болады?", answers: ["Қосылады", "Error", "Жалғанады"], correctAnswerIndex: 1, description: "Мәтін мен санды қосуға болмайды."),
        QuizQuestion(question: "Шығару функциясы?", answers: ["input", "print", "get"], correctAnswerIndex: 1, description: "print - ақпаратты экранға шығарады."),
        QuizQuestion(question: "Бөлшекке айналдыру?", answers: ["int", "float", "bool"], correctAnswerIndex: 1, description: "float() функциясы қолданылады."),
        QuizQuestion(question: "x=int('5'); x*2?", answers: ["10", "55", "Error"], correctAnswerIndex: 0, description: "5 * 2 = 10."),
        QuizQuestion(question: "x = input() '10' болса?", answers: ["Сан", "Мәтін", "Тізім"], correctAnswerIndex: 1, description: "input-тан келген 10 - мәтін.")
      ]),
  Lesson(
      id: 5,
      title: "5. Шарттар (If)",
      theory: "if, elif, else - логикалық таңдау жасау үшін қолданылады. Шегініс (indent) жасау міндетті.",
      quiz: [
        QuizQuestion(question: "Теңдік белгісі?", answers: ["=", "==", "==="], correctAnswerIndex: 1, description: "== - салыстыру операторы."),
        QuizQuestion(question: "Тең емес белгісі?", answers: ["!=", "not", "<>"], correctAnswerIndex: 0, description: "!= - тең емес дегенді білдіреді."),
        QuizQuestion(question: "elif деген не?", answers: ["Соңы", "Басқа шарт", "Басы"], correctAnswerIndex: 1, description: "Else if - қосымша шарт."),
        QuizQuestion(question: "Шегініс керек пе?", answers: ["Жоқ", "Иә", "Кейде"], correctAnswerIndex: 1, description: "Python-да шегініс - басты ереже."),
        QuizQuestion(question: "and операторы?", answers: ["Және", "Немесе", "Емес"], correctAnswerIndex: 0, description: "and - екі шарт та орындалуы тиіс."),
        QuizQuestion(question: "5 > 3 True ма?", answers: ["Иә", "Жоқ", "Қате"], correctAnswerIndex: 0, description: "Иә, 5 үштен үлкен."),
        QuizQuestion(question: "else-ге шарт керек пе?", answers: ["Иә", "Жоқ", "Кейде"], correctAnswerIndex: 1, description: "Else ешқандай шартты қабылдамайды.")
      ]),
  Lesson(
      id: 6,
      title: "6. For циклы",
      theory: "For циклы тізбектерді (тізім, мәтін, range) аралап шығу үшін қолданылады.",
      quiz: [
        QuizQuestion(question: "range(5) неше сан?", answers: ["4", "5", "6"], correctAnswerIndex: 1, description: "0, 1, 2, 3, 4 - барлығы 5 сан."),
        QuizQuestion(question: "Тоқтату операторы?", answers: ["stop", "break", "exit"], correctAnswerIndex: 1, description: "break циклды бірден тоқтатады."),
        QuizQuestion(question: "Келесіге өту?", answers: ["next", "continue", "skip"], correctAnswerIndex: 1, description: "continue қазіргі қадамды аттап өтеді."),
        QuizQuestion(question: "range(1, 3)?", answers: ["1, 2", "1, 2, 3", "0, 1, 2"], correctAnswerIndex: 0, description: "Соңғы сан (3) кірмейді."),
        QuizQuestion(question: "Итерация деген не?", answers: ["Қате", "Бір айналым", "Айнымалы"], correctAnswerIndex: 1, description: "Циклдың бір рет қайталануы."),
        QuizQuestion(question: "range(0, 10, 2)?", answers: ["1 қадам", "2 қадам", "10 қадам"], correctAnswerIndex: 1, description: "Үшінші сан - қадам мөлшері."),
        QuizQuestion(question: "Цикл қайда басталады?", answers: ["for", "while", "do"], correctAnswerIndex: 0, description: "for операторымен басталады.")
      ]),
  Lesson(
      id: 7,
      title: "7. While циклы",
      theory: "While циклы шарт орындалып тұрғанша жұмыс істей береді.",
      quiz: [
        QuizQuestion(question: "Шексіз цикл?", answers: ["while True", "while False", "while 0"], correctAnswerIndex: 0, description: "True болса, шарт ешқашан бұзылмайды."),
        QuizQuestion(question: "Цикл қашан тоқтайды?", answers: ["True болса", "False болса", "Әрқашан"], correctAnswerIndex: 1, description: "Шарт жалған (False) болғанда."),
        QuizQuestion(question: "While-дан кейін не?", answers: [";", ":", "."], correctAnswerIndex: 1, description: "Шарттан кейін қос нүкте қойылады."),
        QuizQuestion(question: "i += 1 не істейді?", answers: ["Азайтады", "Қосады", "Көбейтеді"], correctAnswerIndex: 1, description: "Айнымалыны 1-ге арттырады."),
        QuizQuestion(question: "While vs For?", answers: ["Бірдей", "While шартқа негізделген", "For тезірек"], correctAnswerIndex: 1, description: "While - логикалық шартқа негізделеді."),
        QuizQuestion(question: "i=0; while i<2?", answers: ["1 рет", "2 рет", "3 рет"], correctAnswerIndex: 1, description: "0 және 1 мәндерінде жұмыс істейді."),
        QuizQuestion(question: "Басында тексеріле ме?", answers: ["Иә", "Жоқ", "Қате"], correctAnswerIndex: 0, description: "Иә, шарт цикл басында тексеріледі.")
      ]),
  Lesson(
      id: 8,
      title: "8. Тізімдер (Lists)",
      theory: "Тізім - бірнеше мәнді бір айнымалыда сақтау тәсілі. [ ] жақшасымен жазылады.",
      quiz: [
        QuizQuestion(question: "Элемент қосу?", answers: ["add", "append", "push"], correctAnswerIndex: 1, description: "append() тізім соңына қосады."),
        QuizQuestion(question: "Бірінші индекс?", answers: ["1", "0", "-1"], correctAnswerIndex: 1, description: "Индекстеу әрқашан 0-ден басталады."),
        QuizQuestion(question: "Ұзындығын табу?", answers: ["len()", "size()", "count()"], correctAnswerIndex: 0, description: "len() (length) - элемент санын береді."),
        QuizQuestion(question: "Өшіру функциясы?", answers: ["remove", "del", "clear"], correctAnswerIndex: 0, description: "remove() мәні бойынша өшіреді."),
        QuizQuestion(question: "L=[1,2]; L[0]?", answers: ["1", "2", "Error"], correctAnswerIndex: 0, description: "0-ші орында 1 тұр."),
        QuizQuestion(question: "pop() не істейді?", answers: ["Қосады", "Соңғысын алады", "Көшіреді"], correctAnswerIndex: 1, description: "pop() соңғы элементті алып тастайды."),
        QuizQuestion(question: "Тізім белгісі?", answers: ["[]", "()", "{}"], correctAnswerIndex: 0, description: "Тізімдер шаршы жақшамен жазылады.")
      ]),
  Lesson(
      id: 9,
      title: "9. Функциялар",
      theory: "Функция - қайта қолдануға болатын код блогы. def сөзімен басталады.",
      quiz: [
        QuizQuestion(question: "Жариялау сөзі?", answers: ["func", "def", "function"], correctAnswerIndex: 1, description: "def (define) қолданылады."),
        QuizQuestion(question: "Мән қайтару?", answers: ["get", "return", "back"], correctAnswerIndex: 1, description: "return - функция нәтижесін қайтарады."),
        QuizQuestion(question: "Аргумент қайда?", answers: ["Жақша ішінде", "Сыртта", "Қате"], correctAnswerIndex: 0, description: "Аргументтер жақша ішіне жазылады."),
        QuizQuestion(question: "Шақыру тәсілі?", answers: ["f()", "f[]", "call f"], correctAnswerIndex: 0, description: "Аты және жай жақша."),
        QuizQuestion(question: "def f(): print(1)?", answers: ["1", "Error", "Ештеңе"], correctAnswerIndex: 0, description: "Функция ішіндегіні орындайды."),
        QuizQuestion(question: "Параметрсіз бола ма?", answers: ["Иә", "Жоқ", "Қате"], correctAnswerIndex: 0, description: "Иә, бос жақшамен де жұмыс істейді."),
        QuizQuestion(question: "Локальды айнымалы?", answers: ["Сыртта", "Іште", "Глобалды"], correctAnswerIndex: 1, description: "Функция ішіндегі айнымалы - локальды.")
      ]),
  Lesson(
      id: 10,
      title: "10. Try-Except",
      theory: "Қателерді өңдеу (Exception Handling) бағдарламаның тоқтап қалмауы үшін керек.",
      quiz: [
        QuizQuestion(question: "Қате ұстау блогы?", answers: ["catch", "except", "error"], correctAnswerIndex: 1, description: "except блогы қате болса орындалады."),
        QuizQuestion(question: "Әрқашан істейтін блок?", answers: ["finally", "always", "end"], correctAnswerIndex: 0, description: "finally соңында міндетті түрде істейді."),
        QuizQuestion(question: "0-ге бөлу қатесі?", answers: ["ValueError", "ZeroDivisionError", "TypeError"], correctAnswerIndex: 1, description: "Нөлге бөлуге болмайды қатесі."),
        QuizQuestion(question: "Қатені қолдан шығару?", answers: ["raise", "throw", "error"], correctAnswerIndex: 0, description: "raise операторы қате тудырады."),
        QuizQuestion(question: "Try ішінде не?", answers: ["Қауіпті код", "Түсіндірме", "Тек print"], correctAnswerIndex: 0, description: "Қате шығуы мүмкін код жазылады."),
        QuizQuestion(question: "TypeError қайда?", answers: ["Тип қате болса", "Сан қате болса", "Әрқашан"], correctAnswerIndex: 0, description: "Деректер типі сәйкес келмегенде."),
        QuizQuestion(question: "Тоқтамауы үшін?", answers: ["If", "Try-Except", "For"], correctAnswerIndex: 1, description: "Try-Except қателерді бақылайды.")
      ]),
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
        itemCount: lessonsData.length,
        itemBuilder: (context, i) {
          final lesson = lessonsData[i];
          // globalCurrentUser null емес екеніне көз жеткізіңіз
          bool isLocked = globalCurrentUser != null && lesson.id > globalCurrentUser!.progress;
          bool isCompleted = globalCurrentUser != null && lesson.id < globalCurrentUser!.progress;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: isLocked ? Colors.white10 : Colors.white24,
            elevation: isLocked ? 0 : 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Icon(
                isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.play_circle_fill),
                color: isLocked ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.amber),
                size: 35,
              ),
              title: Text(lesson.title,
                  style: TextStyle(fontWeight: isLocked ? FontWeight.normal : FontWeight.bold, fontSize: 18)),
              subtitle: Text(isLocked ? "Бұғатталған" : (isCompleted ? "Аяқталды (+70 XP)" : "Қазіргі сабақ")),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              onTap: isLocked
                  ? null
                  : () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (c) => LessonPage(lesson: lesson)));
                      setState(() {});
                    },
            ),
          );
        },
      ),
    );
  }
}