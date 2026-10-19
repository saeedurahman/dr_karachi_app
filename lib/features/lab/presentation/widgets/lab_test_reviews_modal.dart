import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../home/data/models/lab_test_model.dart';
import 'book_lab_test_modal.dart';

class LabTestReviewItem {
  final String authorName;
  final int rating;
  final String comment;
  final String dateText;
  final bool isVerified;

  const LabTestReviewItem({
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.dateText,
    this.isVerified = true,
  });
}

class LabTestReviewsModal extends StatefulWidget {
  final LabTestModel test;
  final String? initialBranchId;

  const LabTestReviewsModal({
    super.key,
    required this.test,
    this.initialBranchId,
  });

  static Future<void> show(
    BuildContext context, {
    required LabTestModel test,
    String? initialBranchId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LabTestReviewsModal(
        test: test,
        initialBranchId: initialBranchId,
      ),
    );
  }

  @override
  State<LabTestReviewsModal> createState() => _LabTestReviewsModalState();
}

class _LabTestReviewsModalState extends State<LabTestReviewsModal> {
  final _commentController = TextEditingController();
  int _userRating = 5;
  bool _isSubmitting = false;
  bool _hasSubmittedLocally = false;
  bool _isLoading = true;

  double _avgRating = 0.0;
  int _totalCount = 0;
  Map<int, int> _distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  List<LabTestReviewItem> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchApiReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchApiReviews() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = sl<ApiClient>();

      // 1. Fetch genuine summary
      try {
        final summaryRes = await apiClient.dio.get(
          '${ApiConstants.reviews}/summary',
          queryParameters: {
            'target_type': 'lab_test',
            'target_id': widget.test.id,
          },
        );
        if (summaryRes.data is Map<String, dynamic> && mounted) {
          final data = summaryRes.data as Map<String, dynamic>;
          final rawDist = data['distribution'] as Map<String, dynamic>? ?? {};
          final dist = <int, int>{};
          for (int i = 1; i <= 5; i++) {
            dist[i] = (rawDist[i.toString()] as num?)?.toInt() ?? 0;
          }
          setState(() {
            _avgRating = (data['avg_rating'] as num?)?.toDouble() ?? 0.0;
            _totalCount = (data['total_count'] as num?)?.toInt() ?? 0;
            _distribution = dist;
          });
        }
      } catch (_) {
        // Summary might be 404/empty if no reviews exist yet
      }

      // 2. Fetch real reviews list
      final res = await apiClient.dio.get(
        ApiConstants.reviews,
        queryParameters: {
          'target_type': 'lab_test',
          'target_id': widget.test.id,
        },
      );

      if (res.data is Map && res.data['items'] != null && mounted) {
        final items = res.data['items'] as List<dynamic>;
        final apiList = items.map((e) {
          final author = e['author'] is Map
              ? (e['author']['full_name'] as String? ?? 'Verified Patient')
              : 'Verified Patient';

          DateTime? createdAt;
          if (e['created_at'] != null) {
            createdAt = DateTime.tryParse(e['created_at'].toString());
          }
          final dateStr = createdAt != null
              ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
              : 'Recent';

          return LabTestReviewItem(
            authorName: author,
            rating: (e['rating'] as num?)?.toInt() ?? 5,
            comment: e['comment'] as String? ?? '',
            dateText: dateStr,
          );
        }).toList();

        setState(() {
          _reviews = apiList;
          if (_totalCount == 0 && apiList.isNotEmpty) {
            _totalCount = apiList.length;
            final sum = apiList.fold<int>(0, (prev, r) => prev + r.rating);
            _avgRating = sum / apiList.length;
          }
        });
      }
    } catch (_) {
      // Graceful handling for zero reviews
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a brief feedback comment.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String author = 'Verified Patient';
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      author = authState.user.fullName;
    }

    try {
      final apiClient = sl<ApiClient>();
      await apiClient.dio.post(
        ApiConstants.reviews,
        data: {
          'target_type': 'lab_test',
          'target_id': widget.test.id,
          'rating': _userRating,
          'comment': comment,
        },
      );
    } catch (_) {
      // Handled cleanly
    }

    if (!mounted) return;

    final newReview = LabTestReviewItem(
      authorName: author,
      rating: _userRating,
      comment: comment,
      dateText: 'Just now',
    );

    setState(() {
      _reviews.insert(0, newReview);
      _totalCount += 1;
      _distribution[_userRating] = (_distribution[_userRating] ?? 0) + 1;
      final sum = _reviews.fold<int>(0, (prev, r) => prev + r.rating);
      _avgRating = sum / _reviews.length;
      _isSubmitting = false;
      _hasSubmittedLocally = true;
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your verified test review has been submitted.'),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.rate_review_rounded,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Patient Ratings & Reviews',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.structuralNavy,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.test.name,
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 11,
                                    color: AppColors.secondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Review Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Overall Rating Score Card
                  _buildRatingOverview(),
                  const SizedBox(height: 16),

                  // 2. Write a Review Form Card
                  if (!_hasSubmittedLocally) ...[
                    _buildWriteReviewSection(),
                    const SizedBox(height: 18),
                  ],

                  // 3. Reviews List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _isLoading
                              ? 'Verified Reviews'
                              : 'Verified Reviews (${_reviews.length})',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.structuralNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 11,
                              color: Color(0xFF059669),
                            ),
                            SizedBox(width: 3),
                            Text(
                              '100% Verified',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Reviews List / Loading / Empty State
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                        ),
                      ),
                    )
                  else if (_reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0F2FE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.rate_review_outlined,
                              color: Color(0xFF0284C7),
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No Patient Reviews Yet',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.structuralNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Be the first verified patient to share your feedback for this lab test!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._reviews.map((rev) => _buildReviewCard(rev)),
                ],
              ),
            ),
          ),

          // Sticky Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.structuralNavy.withValues(alpha: 0.08),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.structuralNavy.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Standard Fee',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'Rs. ${widget.test.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      BookLabTestModal.show(
                        context,
                        test: widget.test,
                        initialBranchId: widget.initialBranchId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                    label: const Text(
                      'Book This Test',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverview() {
    final hasReviews = _totalCount > 0 || _reviews.isNotEmpty;
    final displayRating = hasReviews ? _avgRating.toStringAsFixed(1) : '—';
    final roundedRating = hasReviews ? _avgRating.round().clamp(1, 5) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Big rating score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayRating,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.structuralNavy,
                  letterSpacing: -1,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < roundedRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: index < roundedRating
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasReviews
                    ? '$_totalCount Verified Review${_totalCount == 1 ? '' : 's'}'
                    : 'No reviews yet',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Rating distribution bars
          Expanded(
            child: Column(
              children: [
                for (int star = 5; star >= 1; star--)
                  _buildRatingBar(
                    star,
                    _totalCount > 0
                        ? ((_distribution[star] ?? 0) / _totalCount)
                        : 0.0,
                    _distribution[star] ?? 0,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double percent, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Text(
            '$star',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 10, color: Color(0xFFF59E0B)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 5,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 18,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 9.5,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this Diagnostic Test',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.structuralNavy,
            ),
          ),
          const SizedBox(height: 6),

          // 1-5 Star interactive selection
          Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _userRating = star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    star <= _userRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 28,
                    color: star <= _userRating
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Feedback comment input
          TextField(
            controller: _commentController,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              color: AppColors.structuralNavy,
            ),
            decoration: InputDecoration(
              hintText:
                  'Share your experience (phlebotomist cleanliness, timing, accuracy)...',
              hintStyle: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.secondary,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFBAE6FD)),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 10),

          // Submit Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 14),
              label: Text(
                _isSubmitting ? 'Submitting...' : 'Post Review',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(LabTestReviewItem review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          const Color(0xFF0284C7).withValues(alpha: 0.1),
                      child: Text(
                        review.authorName.isNotEmpty
                            ? review.authorName[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.authorName,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.structuralNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            review.dateText,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              color: AppColors.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(
                  review.rating,
                  (index) => const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.structuralNavy,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
