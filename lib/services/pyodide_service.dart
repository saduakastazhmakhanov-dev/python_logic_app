import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// 1. Пакетті universal_html арқылы импорттаймыз (Android-та қате бермейді)
import 'package:universal_html/html.dart' as html;

// 2. ШАРТТЫ ИМПОРТ: dart:js тек браузерде болса ғана жүктеледі
import 'dart:js' if (dart.library.js) 'dart:js' as js;

class PyodideService {
  static const String _pyodideVersion = '0.26.2';

  static String _pyodideJsUrl() =>
      'https://cdn.jsdelivr.net/pyodide/v$_pyodideVersion/full/pyodide.js';

  static String _indexUrl() =>
      'https://cdn.jsdelivr.net/pyodide/v$_pyodideVersion/full/';

  dynamic _pyodide;
  Future<void>? _initFuture;

  Future<void> ensureInitialized() {
    // Егер бұл веб-сайт болмаса, Pyodide-ты іске қоспаймыз
    if (!kIsWeb) return Future.value();
    
    if (_initFuture != null) return _initFuture!;
    _initFuture = _init();
    return _initFuture!;
  }

  Future<void> _init() async {
    if (!kIsWeb) return;

    final existing = html.document.getElementById('pyodide-script');
    if (existing == null) {
      final script = html.ScriptElement()
        ..id = 'pyodide-script'
        ..src = _pyodideJsUrl()
        ..type = 'text/javascript';

      final completer = Completer<void>();
      script.onLoad.listen((_) => completer.complete());
      script.onError.listen((_) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Failed to load pyodide.js'));
        }
      });

      html.document.head?.append(script);
      await completer.future;
    }

    // js.context тек Web-те жұмыс істейді
    if (!js.context.hasProperty('loadPyodide')) {
      throw Exception('loadPyodide is not available after script load');
    }

    final options = js.JsObject.jsify({'indexURL': _indexUrl()});
    final promise = js.context.callMethod('loadPyodide', [options]);
    final pyodide = await _promiseToFuture(promise);

    _pyodide = pyodide;
  }

  Future<String> runPython(String code) async {
    // Android/iOS үшін хабарлама
    if (!kIsWeb) {
      return "Python интерпретаторы мобильді нұсқада әзірге қолжетімді емес. Веб нұсқасын қолданыңыз.";
    }

    await ensureInitialized();

    final b64 = base64Encode(utf8.encode(code));

    final python = '''
import base64, io, sys, traceback
_code = base64.b64decode("$b64").decode("utf-8")
_stdout = io.StringIO()
_stderr = io.StringIO()
_old_stdout, _old_stderr = sys.stdout, sys.stderr
sys.stdout, sys.stderr = _stdout, _stderr
try:
    exec(_code, {})
except Exception:
    traceback.print_exc()
finally:
    sys.stdout, sys.stderr = _old_stdout, _old_stderr
_stdout.getvalue() + _stderr.getvalue()
''';

    final promise = (js.JsObject(_pyodide)).callMethod('runPythonAsync', [python]);
    final result = await _promiseToFuture(promise);

    return result?.toString() ?? '';
  }

  Future<dynamic> _promiseToFuture(dynamic promise) {
    final completer = Completer<dynamic>();
    // then және catch тек Web-тегі JS Promise үшін
    promise.callMethod('then', [
      (value) {
        if (!completer.isCompleted) completer.complete(value);
      }
    ]);
    promise.callMethod('catch', [
      (error) {
        if (!completer.isCompleted) completer.completeError(error);
      }
    ]);
    return completer.future;
  }
}