import 'package:binary/binary.dart';

import '../arm/compiler.dart';

/// Decodes encoded 16-bit ARMv4t into executable [Instruction] instances.
class ThumbDecoder {
  // None of the instructions are yet implemented.
  //
  // ignore: unused_field
  final ArmCompiler _compiler;

  /// Create a new THUMB decoder.
  ///
  /// Optionally specify a custom [compiler] strategy.
  const ThumbDecoder({ArmCompiler compiler: const ArmCompiler()})
      : _compiler = compiler;

  /// Decodes and returns an executable instance from a THUMB [instruction].
  Instruction decode(int instruction) {
    assert(uint16.inRange(instruction), 'Requires a 16-bit input');
    throw new UnimplementedError();
  }
}
