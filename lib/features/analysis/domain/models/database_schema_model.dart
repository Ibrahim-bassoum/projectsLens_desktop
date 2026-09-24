class DatabaseAttribute {
  final String name;
  final String type;
  final bool isPrimaryKey;
  final bool isForeignKey;
  final String? comment;

  const DatabaseAttribute({
    required this.name,
    required this.type,
    this.isPrimaryKey = false,
    this.isForeignKey = false,
    this.comment,
  });
}

class DatabaseRelationship {
  final String fromEntity;
  final String toEntity;
  final String cardinality;
  final String label;

  const DatabaseRelationship({
    required this.fromEntity,
    required this.toEntity,
    required this.cardinality,
    required this.label,
  });

  String get formattedCardinality {
    if (cardinality.contains('||--o{') || cardinality.contains('|o--o{')) {
      return '1 à plusieurs (1:N)';
    } else if (cardinality.contains('}o--o{') || cardinality.contains('}|--|{')) {
      return 'plusieurs à plusieurs (N:N)';
    } else if (cardinality.contains('||--||') || cardinality.contains('|o--||')) {
      return '1 à 1 (1:1)';
    }
    return cardinality;
  }
}

class DatabaseEntity {
  final String name;
  final List<DatabaseAttribute> attributes;
  final List<DatabaseRelationship> relationships;

  const DatabaseEntity({
    required this.name,
    required this.attributes,
    this.relationships = const [],
  });

  int get pkCount => attributes.where((a) => a.isPrimaryKey).length;
  int get fkCount => attributes.where((a) => a.isForeignKey).length;
}

class DatabaseSchema {
  final String rawMermaid;
  final List<DatabaseEntity> entities;
  final List<DatabaseRelationship> relationships;

  const DatabaseSchema({
    required this.rawMermaid,
    required this.entities,
    required this.relationships,
  });

  int get totalTables => entities.length;
  int get totalAttributes =>
      entities.fold(0, (sum, entity) => sum + entity.attributes.length);
  int get totalRelationships => relationships.length;

  /// Parse un bloc de texte Mermaid erDiagram pour extraire les entités et relations
  factory DatabaseSchema.fromMermaid(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```mermaid')) {
      cleaned = cleaned.substring('```mermaid'.length);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    final lines = cleaned.split('\n');
    final Map<String, List<DatabaseAttribute>> entityAttrs = {};
    final List<DatabaseRelationship> parsedRelationships = [];

    String? currentEntity;
    final List<DatabaseAttribute> currentAttrs = [];

    final relationRegex = RegExp(
      r'^\s*([A-Za-z0-9_]+)\s+([\|\}][o\|]--[o\|][\|\{]|[\|\}]--[\|\{])\s+([A-Za-z0-9_]+)\s*:\s*"?([^"\n]+)"?',
    );

    for (var line in lines) {
      final trimmed = line.trim();

      // Ignorer entête, commentaires et lignes vides
      if (trimmed.isEmpty ||
          trimmed.startsWith('erDiagram') ||
          trimmed.startsWith('%%')) {
        continue;
      }

      // 1. Détection de relation (ex: USERS ||--o{ ORDERS : places)
      final relMatch = relationRegex.firstMatch(trimmed);
      if (relMatch != null) {
        parsedRelationships.add(
          DatabaseRelationship(
            fromEntity: relMatch.group(1)!,
            cardinality: relMatch.group(2)!,
            toEntity: relMatch.group(3)!,
            label: relMatch.group(4)!.trim(),
          ),
        );
        continue;
      }

      // 2. Début de bloc entité (ex: USERS {)
      if (trimmed.endsWith('{')) {
        final entityName = trimmed.replaceAll('{', '').trim();
        if (entityName.isNotEmpty) {
          currentEntity = entityName;
          currentAttrs.clear();
        }
        continue;
      }

      // 3. Fin de bloc entité
      if (trimmed == '}') {
        if (currentEntity != null) {
          entityAttrs[currentEntity] = List.from(currentAttrs);
          currentEntity = null;
          currentAttrs.clear();
        }
        continue;
      }

      // 4. Ligne d'attribut dans un bloc entité (ex: string email ou int id PK)
      if (currentEntity != null) {
        final tokens = trimmed.split(RegExp(r'\s+'));
        if (tokens.length >= 2) {
          final type = tokens[0];
          final name = tokens[1];
          final flags = tokens.sublist(2).map((e) => e.toUpperCase()).toSet();

          currentAttrs.add(
            DatabaseAttribute(
              name: name,
              type: type,
              isPrimaryKey: flags.contains('PK'),
              isForeignKey: flags.contains('FK'),
              comment: tokens.length > 3 ? tokens.sublist(3).join(' ') : null,
            ),
          );
        }
      }
    }

    // Si le bloc n'était pas formellement fermé par '}'
    if (currentEntity != null && currentAttrs.isNotEmpty) {
      entityAttrs[currentEntity] = List.from(currentAttrs);
    }

    // Regrouper les relations par entité
    final List<DatabaseEntity> entityList = [];
    for (var entry in entityAttrs.entries) {
      final entityRelations = parsedRelationships
          .where((r) => r.fromEntity == entry.key || r.toEntity == entry.key)
          .toList();

      entityList.add(
        DatabaseEntity(
          name: entry.key,
          attributes: entry.value,
          relationships: entityRelations,
        ),
      );
    }

    return DatabaseSchema(
      rawMermaid: cleaned,
      entities: entityList,
      relationships: parsedRelationships,
    );
  }
}
