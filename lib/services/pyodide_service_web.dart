import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:universal_html/html.dart' as html;

class PyodideService {
  static const String _pyodideVersion = '0.26.2';

  static String _pyodideJsUrl() =>
      'https://cdn.jsdelivr.net/pyodide/v$_pyodideVersion/full/pyodide.js';

  static String _indexUrl() =>
      'https://cdn.jsdelivr.net/pyodide/v$_pyodideVersion/full/';

  dynamic _pyodide;
  Future<void>? _initFuture;

  Future<void> ensureInitialized() {
    _initFuture ??= _init();
    return _initFuture!;
  }

  Future<void> _init() async {
    final existing = html.document.getElementById('pyodide-script');
    if (existing == null) {
      final script = html.ScriptElement()
        ..id = 'pyodide-script'
        ..src = _pyodideJsUrl()
        ..type = 'text/javascript';

      final completer = Completer<void>();
      script.onLoad.listen((_) {
        if (!completer.isCompleted) completer.complete();
      });
      script.onError.listen((_) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Failed to load pyodide.js'));
        }
      });

      html.document.head?.append(script);
      await completer.future;
    }

    if (!js.context.hasProperty('loadPyodide')) {
      throw Exception('loadPyodide is not available after script load');
    }

    final options = js.JsObject.jsify({'indexURL': _indexUrl()});
    final promise = js.context.callMethod('loadPyodide', [options]);
    _pyodide = await _promiseToFuture(promise);
  }

  Future<String> runPython(String code) async {
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

    final promise =
        js.JsObject(_pyodide).callMethod('runPythonAsync', [python]);
    final result = await _promiseToFuture(promise);
    final output = result?.toString() ?? '';
    return output.isEmpty ? 'Нәтиже жоқ' : output;
  }

  Future<dynamic> _promiseToFuture(dynamic promise) {
    final completer = Completer<dynamic>();
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

