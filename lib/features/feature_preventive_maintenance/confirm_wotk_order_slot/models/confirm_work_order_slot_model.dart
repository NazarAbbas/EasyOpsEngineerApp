// ───────────────────────── Model ─────────────────────────
class SlotOption {
  final String id; // e.g., 'slot-1'
  final String label; // e.g., '13 Mar (Thu) | 02:00 PM to 06:00 PM'
  SlotOption(this.id, this.label);
}

// ───────────────────────── Fake API ─────────────────────────
class SlotsApi {
  Future<List<SlotOption>> fetchSlots({required String workOrderId}) async {
    //await Future.delayed(const Duration(milliseconds: 650));
    return [
      SlotOption('s1', '13 Mar (Thu) | 02:00 PM to 06:00 PM'),
      SlotOption('s2', '15 Mar (Sat) | 10:00 AM to 02:00 PM'),
    ];
  }
}
