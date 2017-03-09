import 'dart:typed_data';

/// A narrow interface for reading from a specific space in RAM.
abstract class ReadableMemory {
  /// Reads a 8-bit integer at [address].
  int read8(int address);

  /// Reads a 16-bit integer at [address].
  int read16(int address);

  /// Reads a 32-bit integer at [address].
  int read32(int address);

  /// Returns a copy of the data buffer.
  ByteBuffer toBuffer();
}

/// A narrow interface for writing to a specific space in RAM.
abstract class WritableMemory {
  /// Writes a 8-bit integer [value] to address.
  void write8(int address, int value);

  /// Writes a 16-bit integer [value] to address.
  void write16(int address, int value);

  /// Writes a 32-bit integer [value] to address.
  void write32(int address, int value);
}

/// A combined interface for both reading and writing a specific space in RAM.
///
/// In the ARM7/TDMI only load, store, and swap instructions can access memory.
class Memory implements ReadableMemory, WritableMemory {
  final Uint8List _view8;
  final Uint16List _view16;
  final Uint32List _view32;

  /// Create a new block of memory of [length].
  factory Memory(int length) => new Memory.view(new ByteData(length).buffer);

  /// Create a new view of memory as a view into [buffer].
  factory Memory.view(
    ByteBuffer buffer, [
    int offsetInBytes = 0,
    int length,
  ]) =>
      new Memory._(
          new Uint8List.view(buffer, offsetInBytes, length),
          new Uint16List.view(buffer, offsetInBytes, length),
          new Uint32List.view(buffer, offsetInBytes, length));

  Memory._(this._view8, this._view16, this._view32);

  /// Returns as a read-only interface into memory.
  ReadableMemory asReadable() => this;

  /// Returns as a write-only interface into memory.
  WritableMemory asWritable() => this;

  @override
  int read8(int address) => _view8[address];

  @override
  int read16(int address) => _view16[address];

  @override
  int read32(int address) => _view32[address];

  @override
  void write8(int address, int value) {
    _view8[address] = value;
  }

  @override
  void write16(int address, int value) {
    _view16[address] = value;
  }

  @override
  void write32(int address, int value) {
    _view32[address] = value;
  }

  @override
  ByteBuffer toBuffer() => new Uint8List.fromList(_view8).buffer;
}
