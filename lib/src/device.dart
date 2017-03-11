import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:meta/meta.dart';

/// A virtual device interface for the ARM7/TDMI to interact with.
abstract class Device {
  /// The base address of the device's memory-mapped registers.
  @protected
  final int baseAddress;

  Device(this.baseAddress);

  /// Called when [vm] is registering the device.
  ///
  /// Returns if device registration should be considered successful.
  bool onRegister(VM vm);

  /// Called when [vm] removes the device.
  ///
  /// May be used to un-map H/W registers from memory, dispose of timeouts, etc.
  ///
  /// Returns if device removal should be considered successful.
  bool onRemove(VM vm);
}
