/// Which slot to flip, and what to flip it to.
///
/// [isActive] is the value being *requested*, not the current one — the caller
/// negates before building this.
class SetSlotActiveParams {
  const SetSlotActiveParams({required this.slotId, required this.isActive});

  final String slotId;
  final bool isActive;
}
