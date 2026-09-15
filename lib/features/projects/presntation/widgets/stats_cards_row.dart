import 'package:flutter/material.dart';

class StatsCardsRow extends StatelessWidget {
  const StatsCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard('Projets analysés', '12', '+2 ce mois-ci', Icons.code),
        const SizedBox(width: 15),
        _buildStatCard(
          'Fichiers analysés',
          '8,452',
          '+1,231 ce mois-ci',
          Icons.folder,
        ),
        const SizedBox(width: 15),
        _buildStatCard(
          'Lignes de code',
          '312,104',
          '+45,231 ce mois-ci',
          Icons.layers,
        ),
        const SizedBox(width: 15),
        _buildStatCard(
          'Temps gagné',
          '58h',
          '+12h ce mois-ci',
          Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtext,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Icon(icon, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtext,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
