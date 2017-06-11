import 'package:func/func.dart';
import 'package:math_expressions/math_expressions.dart';

/// Returns the result of evaluating a mathematical [expression].
dynamic eval(String expression, int lookup(String varName)) => new Parser()
    .parse(expression)
    .evaluate(EvaluationType.REAL, new _DynamicContext(lookup));

class _DynamicContext extends ContextModel {
  final Func1<String, int> _lookup;

  _DynamicContext(this._lookup);

  @override
  Expression getExpression(String varName) {
    final result = _lookup(varName);
    if (result != null) {
      return new Parser().parse('$result');
    }
    return super.getExpression(varName);
  }
}
