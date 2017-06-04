import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:matcher/matcher.dart';

class EqualsPsr extends Matcher {
  final Psr _cpsr;

  const EqualsPsr(this._cpsr);

  @override
  Description describe(Description description) {
    return description.addDescriptionOf(_cpsr);
  }

  @override
  bool matches(Object item, _) => item is Psr && item == _cpsr;

  @override
  Description describeMismatch(
    covariant Psr item,
    Description mismatchDescription,
    _,
    __,
  ) {
    if (item.v != _cpsr.v) {
      mismatchDescription = mismatchDescription.add(
        'v: Was ${item.v}, got ${_cpsr.v}',
      );
    }
    if (item.c != _cpsr.c) {
      mismatchDescription = mismatchDescription.add(
        'c: Was ${item.c}, got ${_cpsr.c}',
      );
    }
    if (item.n != _cpsr.n) {
      mismatchDescription = mismatchDescription.add(
        'n: Was ${item.n}, got ${_cpsr.n}',
      );
    }
    if (item.z != _cpsr.z) {
      mismatchDescription = mismatchDescription.add(
        'z: Was ${item.z}, got ${_cpsr.z}',
      );
    }
    return mismatchDescription;
  }
}
