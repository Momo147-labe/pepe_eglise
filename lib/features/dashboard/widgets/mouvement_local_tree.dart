import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/models/member_model.dart';

class MouvementLocalTree extends StatelessWidget {
  final List<MemberModel> members;
  final bool isLoading;

  const MouvementLocalTree({
    super.key,
    required this.members,
    this.isLoading = false,
  });

  static const String commissionLocaleName = 'Commission Locale';

  static const List<String> posteOrder = [
    'pasteur',
    'vice-president',
    'Le trésorier',
    'secretaire',
    'charger aux affaires sociales',
  ];

  static List<MemberModel> sortByPoste(List<MemberModel> members) {
    final sorted = List<MemberModel>.from(members);
    sorted.sort((a, b) {
      final idxA = posteOrder.indexOf(a.poste ?? '');
      final idxB = posteOrder.indexOf(b.poste ?? '');
      return (idxA == -1 ? 999 : idxA).compareTo(idxB == -1 ? 999 : idxB);
    });
    return sorted;
  }

  MemberModel? _memberForPoste(String poste) {
    try {
      return members.firstWhere((m) => m.poste == poste);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_rounded, color: AppColors.primaryOrange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Locale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    Text(
                      'Organigramme du mouvement local',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (members.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'Aucun membre de la Commission Locale',
                  style: TextStyle(color: context.subtitleColor),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 720) {
                  return _buildDesktopTree();
                }
                return _buildMobileTree();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopTree() {
    final pasteur = _memberForPoste('pasteur');
    final rowMembers = posteOrder
        .skip(1)
        .map(_memberForPoste)
        .whereType<MemberModel>()
        .toList();

    return Column(
      children: [
        if (pasteur != null) _TreeNode(member: pasteur, isLeader: true),
        if (pasteur != null && rowMembers.isNotEmpty) ...[
          _VerticalConnector(height: 24),
          _HorizontalConnector(),
          const SizedBox(height: 8),
        ],
        if (rowMembers.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < rowMembers.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _TreeNode(member: rowMembers[i])),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildMobileTree() {
    final sorted = sortByPoste(members);
    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++) ...[
          if (i > 0) _VerticalConnector(height: 16),
          _TreeNode(
            member: sorted[i],
            isLeader: sorted[i].poste == 'pasteur',
          ),
        ],
      ],
    );
  }
}

class _TreeNode extends StatelessWidget {
  final MemberModel member;
  final bool isLeader;

  const _TreeNode({required this.member, this.isLeader = false});

  @override
  Widget build(BuildContext context) {
    final radius = isLeader ? 48.0 : 36.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MemberAvatar(member: member, radius: radius),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatPoste(member.poste),
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          member.fullName,
          style: TextStyle(
            fontSize: isLeader ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatPoste(String? poste) {
    if (poste == null || poste.isEmpty) return 'Membre';
    if (poste == 'vice-president') return 'Vice-président';
    if (poste == 'charger aux affaires sociales') {
      return 'Chargé aux affaires sociales';
    }
    return poste[0].toUpperCase() + poste.substring(1);
  }
}

class _MemberAvatar extends StatelessWidget {
  final MemberModel member;
  final double radius;

  const _MemberAvatar({required this.member, required this.radius});

  @override
  Widget build(BuildContext context) {
    final imagePath = member.imagePath;
    final hasFile =
        imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.4),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.1),
        backgroundImage: hasFile ? FileImage(File(imagePath)) : null,
        child: hasFile
            ? null
            : Text(
                member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: radius * 0.55,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
      ),
    );
  }
}

class _VerticalConnector extends StatelessWidget {
  final double height;

  const _VerticalConnector({required this.height});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 2,
        height: height,
        color: context.borderColor,
      ),
    );
  }
}

class _HorizontalConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            width: constraints.maxWidth * 0.75,
            height: 2,
            color: context.borderColor,
          ),
        );
      },
    );
  }
}
