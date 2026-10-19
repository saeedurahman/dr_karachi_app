class DoctorReviewSummaryModel {
  final double avgRating;
  final int totalCount;
  final Map<int, int> distribution;

  DoctorReviewSummaryModel({
    required this.avgRating,
    required this.totalCount,
    required this.distribution,
  });

  factory DoctorReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawDist = json['distribution'] as Map<String, dynamic>? ?? {};
    final distMap = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distMap[i] = (rawDist[i.toString()] as num?)?.toInt() ?? 0;
    }

    return DoctorReviewSummaryModel(
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      distribution: distMap,
    );
  }

  factory DoctorReviewSummaryModel.empty() {
    return DoctorReviewSummaryModel(
      avgRating: 0.0,
      totalCount: 0,
      distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    );
  }
}

class DoctorReviewItemModel {
  final String id;
  final String userId;
  final String authorName;
  final int rating;
  final String? comment;
  final bool isApproved;
  final DateTime createdAt;

  DoctorReviewItemModel({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.rating,
    this.comment,
    required this.isApproved,
    required this.createdAt,
  });

  factory DoctorReviewItemModel.fromJson(Map<String, dynamic> json) {
    String author = 'Verified Patient';
    if (json['author'] is Map) {
      author = (json['author']['full_name'] as String?) ?? 'Verified Patient';
    }

    return DoctorReviewItemModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      authorName: author,
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String?,
      isApproved: json['is_approved'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class DoctorReviewEligibilityModel {
  final bool eligible;
  final bool hasReviewed;
  final DoctorReviewItemModel? existingReview;
  final String? reason;

  DoctorReviewEligibilityModel({
    required this.eligible,
    required this.hasReviewed,
    this.existingReview,
    this.reason,
  });

  factory DoctorReviewEligibilityModel.fromJson(Map<String, dynamic> json) {
    DoctorReviewItemModel? existing;
    if (json['existing_review'] is Map<String, dynamic>) {
      existing = DoctorReviewItemModel.fromJson(
        json['existing_review'] as Map<String, dynamic>,
      );
    }

    return DoctorReviewEligibilityModel(
      eligible: json['eligible'] as bool? ?? false,
      hasReviewed: json['has_reviewed'] as bool? ?? false,
      existingReview: existing,
      reason: json['reason'] as String?,
    );
  }
}
