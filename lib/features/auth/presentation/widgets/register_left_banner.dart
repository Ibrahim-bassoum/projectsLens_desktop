import 'package:flutter/material.dart';

class RegisterLeftBanner extends StatelessWidget {
  const RegisterLeftBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ProjectLens',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Text(
            'Analysez. Comprenez.\nGénérez.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ProjectLens est la plateforme intelligente qui analyse vos projets logiciels et génère une documentation complète grâce à l\'intelligence artificielle.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          _buildFeatureRow(
            Icons.code,
            'Analyse de code',
            'Détectez les technologies, l\'architecture et la structure de votre projet.',
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(
            Icons.description_outlined,
            'Documentation automatique',
            'Générez un README, une documentation API, des diagrammes et bien plus.',
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(
            Icons.chat_bubble_outline,
            'Assistant IA',
            'Posez vos questions et obtenez des réponses précises sur votre code.',
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Icon(Icons.security, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Sécurisé',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              const SizedBox(width: 24),
              Icon(Icons.bolt, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Rapide',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              const SizedBox(width: 24),
              Icon(Icons.cloud_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Accessible partout',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
