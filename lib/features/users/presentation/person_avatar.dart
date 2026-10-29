import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/domain/explorer_models.dart';

/// Initial in a teal circle for known users, a person icon in grey for anonymous ones.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, this.size = 40});

  final Person person;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: person.isIdentified ? scheme.primary : colors.fill,
      foregroundColor: person.isIdentified ? scheme.onPrimary : colors.muted,
      child: person.isIdentified
          ? Text(person.distinctId.characters.first.toUpperCase(),
              style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700))
          : Icon(Icons.person_outline, size: size * 0.55),
    );
  }
}
