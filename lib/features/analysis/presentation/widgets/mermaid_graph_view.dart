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

  /// Génère l'URL d'image pour mermaid.ink
  /// Note : Utilisation de /img/ (PNG) au lieu de /svg/ car Image.network ne supporte pas le SVG natif.
  String _getMermaidInkUrl(String code) {
    final jsonSpec = jsonEncode({
      'code': code,
      'mermaid': {
        'theme': 'default',
        'themeVariables': {'fontFamily': 'Inter, sans-serif'},
      },
    });
    final base64Spec = base64UrlEncode(utf8.encode(jsonSpec));
    // Utilisation du format PNG haute définition
    return 'https://mermaid.ink/img/$base64Spec?bgColor=transparent';
  }

  void _zoom(double factor) {
    final Matrix4 currentMatrix = _transController.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    final double targetScale = (currentScale * factor).clamp(0.3, 5.0);
    final double scaleFactor = targetScale / currentScale;

    setState(() {
      _transController.value = currentMatrix.scaled(
        scaleFactor,
        scaleFactor,
        1.0,
      );
    });
  }

  void _resetZoom() {
    setState(() {
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
          // 1. Arrière-plan grille
          Positioned.fill(
            child: CustomPaint(painter: _GridBackgroundPainter()),
          ),

          // 2. Zone Interactive (Zoom & Pan)
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transController,
              minScale: 0.3,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(800),
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
                      final percent = expected != null
                          ? (current / expected)
                          : null;

                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: percent,
                              color: const Color(0xFF0F172A),
                              strokeWidth: 2.5,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Génération du rendu du diagramme...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
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
                              const Icon(
                                Icons
                                    .signal_wifi_connected_no_internet_4_rounded,
                                size: 38,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Aperçu du schéma indisponible',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Vérifiez votre connexion internet ou le volume du code Mermaid.\nUtilisez les onglets "Schéma Relationnel" ou "Code Mermaid".',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
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

          // 3. Boutons de contrôle de zoom
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
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: () => _zoom(1.25),
                    tooltip: 'Zoomer (+)',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    onPressed: () => _zoom(0.8),
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
                    icon: const Icon(
                      Icons.center_focus_strong_rounded,
                      size: 18,
                    ),
                    onPressed: _resetZoom,
                    tooltip: 'Réinitialiser la vue (100%)',
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
