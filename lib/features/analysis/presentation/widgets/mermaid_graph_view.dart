import 'dart:convert';
import 'package:flutter/material.dart';

class MermaidGraphView extends StatefulWidget {
  final String mermaidCode;

  const MermaidGraphView({super.key, required this.mermaidCode});

  @override
  State<MermaidGraphView> createState() => _MermaidGraphViewState();
}

class _MermaidGraphViewState extends State<MermaidGraphView> {
  final TransformationController _transController = TransformationController();
  double _scale = 1.0;

  String _getMermaidInkUrl(String code) {
    // Encapsulation dans la structure JSON attendue par mermaid.ink
    final jsonSpec = jsonEncode({
      'code': code,
      'mermaid': {'theme': 'default'},
    });
    final base64Spec = base64UrlEncode(utf8.encode(jsonSpec));
    return 'https://mermaid.ink/svg/$base64Spec';
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale + 0.25).clamp(0.5, 4.0);
      _transController.value = Matrix4.identity()..scale(_scale);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale - 0.25).clamp(0.5, 4.0);
      _transController.value = Matrix4.identity()..scale(_scale);
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _transController.value = Matrix4.identity();
    });
  }

  @override
  void dispose() {
    _transController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getMermaidInkUrl(widget.mermaidCode);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grille d'arrière-plan technique
          Positioned.fill(
            child: CustomPaint(
              painter: _GridBackgroundPainter(),
            ),
          ),

          // Zone Interactive (Zoom & Pan)
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transController,
              minScale: 0.3,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(500),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      final expected = loadingProgress.expectedTotalBytes;
                      final current = loadingProgress.cumulativeBytesLoaded;
                      final percent = expected != null ? (current / expected) : null;

                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: percent,
                              color: const Color(0xFF0F172A),
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Rendu vectoriel du diagramme...',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.broken_image_rounded, size: 36, color: Color(0xFF94A3B8)),
                              const SizedBox(height: 12),
                              const Text(
                                'Aperçu vectoriel non disponible hors ligne.',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Consultez le "Schéma Relationnel" ou le "Code Mermaid" dans les onglets ci-dessus.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Boutons de contrôle de zoom flottants
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_in_rounded, size: 18),
                    onPressed: _zoomIn,
                    tooltip: 'Zoomer (+)',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out_rounded, size: 18),
                    onPressed: _zoomOut,
                    tooltip: 'Dézoomer (-)',
                    visualDensity: VisualDensity.compact,
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong_rounded, size: 18),
                    onPressed: _resetZoom,
                    tooltip: 'Réinitialiser le zoom (100%)',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
