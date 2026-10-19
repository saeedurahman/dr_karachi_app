class BranchSwitchWarningModel {
  final String detail;
  final String currentBranchId;
  final String requestedBranchId;

  BranchSwitchWarningModel({
    required this.detail,
    required this.currentBranchId,
    required this.requestedBranchId,
  });

  factory BranchSwitchWarningModel.fromJson(Map<String, dynamic> json) {
    return BranchSwitchWarningModel(
      detail: json['detail'] as String? ?? 'Your cart belongs to a different branch. Clear it to switch.',
      currentBranchId: json['current_branch_id'] as String? ?? '',
      requestedBranchId: json['requested_branch_id'] as String? ?? '',
    );
  }
}

class BranchConflictException implements Exception {
  final BranchSwitchWarningModel warning;

  BranchConflictException(this.warning);

  @override
  String toString() => warning.detail;
}
