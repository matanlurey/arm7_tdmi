import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:meta/meta.dart';

/// ARM7/TDMI simulation service (virtual machine).
class VM {
  /// Processor.
  final Cpu cpu;

  /// Memory interface.
  final Memory memory;

  final _devices = <Device>[];

  VM._({
    @required this.cpu,
    Iterable<Device> devices: const [],
    @required this.memory,
  }) {
    _devices.addAll(devices);
  }

  /// Registers the specified [device] with the virtual machine.
  ///
  /// Returns `true` if the device was successfully registered.
  bool registerDevice(Device device) {
    if (device.onRegister(this)) {
      _devices.add(device);
      return true;
    }
    return false;
  }

  /// Removes the specified [device] from the virtual machine.
  ///
  /// Returns `true` if the device was successfully removed.
  bool removeDevice(Device device) {
    if (_devices.contains(device) && device.onRemove(this)) {
      _devices.remove(device);
      return true;
    }
    return false;
  }
}
