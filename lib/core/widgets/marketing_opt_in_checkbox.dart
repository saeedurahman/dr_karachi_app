import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// Reusable WhatsApp marketing consent checkbox component.
/// Mirrors the website's healthcare-grade UI with voluntary/non-blocking consent,
/// English & Urdu copy, official WhatsApp branding, and accessible tap targeting.
class MarketingOptInCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final EdgeInsetsGeometry? margin;

  const MarketingOptInCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.margin,
  });

  static const String _whatsappSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="#25D366">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && onChanged != null;

    return Container(
      margin: margin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? const Color(0xFF6EE7B7)
                : AppColors.structuralNavy.withValues(alpha: 0.12),
            width: value ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: value
                  ? const Color(0xFF10B981).withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isInteractive ? () => onChanged!(!value) : null,
            child: Opacity(
              opacity: enabled ? 1.0 : 0.6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox control
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: value,
                          onChanged: isInteractive ? (val) => onChanged!(val ?? false) : null,
                          activeColor: const Color(0xFF059669),
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF94A3B8),
                            width: 1.5,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Copy area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: SvgPicture.string(
                                  _whatsappSvg,
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      height: 1.35,
                                      color: AppColors.structuralNavy,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'I agree to receive offers and updates on WhatsApp. ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Reply STOP anytime to unsubscribe.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'میں واٹس ایپ پر آفرز اور اپ ڈیٹس وصول کرنے پر رضامند ہوں۔',
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                height: 1.4,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
