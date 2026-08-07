import 'package:flutter/material.dart';

/// Un nodo dell'albero delle skill di calisthenics.
class SkillNode {
  final String id;
  final String name;

  /// Criterio misurabile per lo sblocco (testo mostrato all'utente).
  final String criteria;

  /// Id dei nodi propedeutici (devono essere completati prima).
  final List<String> prereqs;

  /// Posizione relativa nel canvas (0..1).
  final double x;
  final double y;

  final IconData icon;

  /// Esercizio della libreria da cui derivare l'auto-progresso (opzionale).
  final String? exerciseId;

  /// Obiettivo in secondi (per hold) da cui calcolare la percentuale.
  final double? targetSec;

  /// Obiettivo in ripetizioni da cui calcolare la percentuale.
  final double? targetReps;

  /// Se true il progresso si basa sul totale accumulato (es. "30s totali"),
  /// altrimenti sul miglior singolo set.
  final bool cumulative;

  const SkillNode({
    required this.id,
    required this.name,
    required this.criteria,
    required this.prereqs,
    required this.x,
    required this.y,
    this.icon = Icons.self_improvement_rounded,
    this.exerciseId,
    this.targetSec,
    this.targetReps,
    this.cumulative = false,
  });

  bool get hasAutoTarget =>
      exerciseId != null && (targetSec != null || targetReps != null);
}

/// Colonne (x) per ciascun ramo di skill.
const double _xPlanche = 0.11;
const double _xFrontLever = 0.305;
const double _xHandstand = 0.5;
const double _xMuscleUp = 0.695;
const double _xFlag = 0.89;

/// Righe (y) per profondità (tier).
const double _t0 = 0.09;
const double _t1 = 0.34;
const double _t2 = 0.59;
const double _t3 = 0.84;

/// Definizione statica dell'albero delle skill.
const List<SkillNode> skillNodes = [
  // --- Planche ---
  SkillNode(
    id: 'planche_lean',
    name: 'Planche Lean',
    criteria: 'Accumula 30s totali di Planche Lean',
    prereqs: [],
    x: _xPlanche,
    y: _t0,
    icon: Icons.airline_seat_flat_rounded,
    exerciseId: 'pseudo-planche-hold',
    targetSec: 30,
    cumulative: true,
  ),
  SkillNode(
    id: 'tuck_planche',
    name: 'Tuck Planche',
    criteria: 'Tieni 10s di Tuck Planche',
    prereqs: ['planche_lean'],
    x: _xPlanche,
    y: _t1,
    icon: Icons.accessibility_new_rounded,
    exerciseId: 'tuck-planche',
    targetSec: 10,
  ),
  SkillNode(
    id: 'straddle_planche',
    name: 'Straddle Planche',
    criteria: 'Tieni 5s di Straddle Planche',
    prereqs: ['tuck_planche'],
    x: _xPlanche,
    y: _t2,
    icon: Icons.open_in_full_rounded,
    exerciseId: 'straddle-planche',
    targetSec: 5,
  ),
  SkillNode(
    id: 'full_planche',
    name: 'Full Planche',
    criteria: 'Tieni 3s di Full Planche',
    prereqs: ['straddle_planche'],
    x: _xPlanche,
    y: _t3,
    icon: Icons.star_rounded,
    exerciseId: 'planche',
    targetSec: 3,
  ),

  // --- Front Lever ---
  SkillNode(
    id: 'tuck_fl',
    name: 'Tuck Front Lever',
    criteria: 'Tieni 15s di Tuck Front Lever',
    prereqs: [],
    x: _xFrontLever,
    y: _t0,
    icon: Icons.horizontal_rule_rounded,
    exerciseId: 'tuck-front-lever',
    targetSec: 15,
  ),
  SkillNode(
    id: 'adv_tuck_fl',
    name: 'Adv. Tuck FL',
    criteria: 'Tieni 12s di Advanced Tuck FL',
    prereqs: ['tuck_fl'],
    x: _xFrontLever,
    y: _t1,
    icon: Icons.remove_rounded,
    exerciseId: 'plank-static',
    targetSec: 12,
  ),
  SkillNode(
    id: 'straddle_fl',
    name: 'Straddle FL',
    criteria: 'Tieni 8s di Straddle Front Lever',
    prereqs: ['adv_tuck_fl'],
    x: _xFrontLever,
    y: _t2,
    icon: Icons.open_in_full_rounded,
    exerciseId: 'front-lever-raise',
    targetReps: 8,
  ),
  SkillNode(
    id: 'full_fl',
    name: 'Full Front Lever',
    criteria: 'Tieni 5s di Full Front Lever',
    prereqs: ['straddle_fl'],
    x: _xFrontLever,
    y: _t3,
    icon: Icons.star_rounded,
    exerciseId: 'front-lever',
    targetSec: 5,
  ),

  // --- Handstand ---
  SkillNode(
    id: 'wall_hs',
    name: 'Wall Handstand',
    criteria: 'Tieni 60s di Wall Handstand',
    prereqs: [],
    x: _xHandstand,
    y: _t0,
    icon: Icons.vertical_align_top_rounded,
    exerciseId: 'wall-handstand',
    targetSec: 60,
  ),
  SkillNode(
    id: 'freestanding_hs',
    name: 'Handstand libero',
    criteria: 'Tieni 15s di Handstand libero',
    prereqs: ['wall_hs'],
    x: _xHandstand,
    y: _t1,
    icon: Icons.accessibility_rounded,
    exerciseId: 'handstand',
    targetSec: 15,
  ),
  SkillNode(
    id: 'hspu',
    name: 'Handstand Push-Up',
    criteria: 'Esegui 5 HSPU consecutive',
    prereqs: ['freestanding_hs'],
    x: _xHandstand,
    y: _t2,
    icon: Icons.star_rounded,
    exerciseId: 'hspu',
    targetReps: 5,
  ),

  // --- Muscle-Up ---
  SkillNode(
    id: 'pullups',
    name: 'Pull-Up x10',
    criteria: 'Esegui 10 Pull-Up strict',
    prereqs: [],
    x: _xMuscleUp,
    y: _t0,
    icon: Icons.download_rounded,
    exerciseId: 'pullup',
    targetReps: 10,
  ),
  SkillNode(
    id: 'explosive_pullups',
    name: 'Pull-Up esplosive',
    criteria: 'Pull-Up al petto x5',
    prereqs: ['pullups'],
    x: _xMuscleUp,
    y: _t1,
    icon: Icons.bolt_rounded,
    exerciseId: 'high-pullup',
    targetReps: 5,
  ),
  SkillNode(
    id: 'muscle_up',
    name: 'Muscle-Up',
    criteria: 'Esegui 1 Muscle-Up pulito',
    prereqs: ['explosive_pullups'],
    x: _xMuscleUp,
    y: _t2,
    icon: Icons.star_rounded,
    exerciseId: 'muscleup',
    targetReps: 1,
  ),

  // --- Human Flag ---
  SkillNode(
    id: 'support_hold',
    name: 'Support Hold',
    criteria: 'Tieni 20s di Flag Support',
    prereqs: [],
    x: _xFlag,
    y: _t0,
    icon: Icons.swap_horiz_rounded,
  ),
  SkillNode(
    id: 'flag_tuck',
    name: 'Tuck Flag',
    criteria: 'Tieni 8s di Tuck Human Flag',
    prereqs: ['support_hold'],
    x: _xFlag,
    y: _t1,
    icon: Icons.flag_outlined,
  ),
  SkillNode(
    id: 'adv_flag',
    name: 'Adv. Flag',
    criteria: 'Tieni 5s di Advanced Flag',
    prereqs: ['flag_tuck'],
    x: _xFlag,
    y: _t2,
    icon: Icons.flag_rounded,
  ),
  SkillNode(
    id: 'human_flag',
    name: 'Human Flag',
    criteria: 'Tieni 5s di Full Human Flag',
    prereqs: ['adv_flag'],
    x: _xFlag,
    y: _t3,
    icon: Icons.star_rounded,
    exerciseId: 'human-flag',
    targetSec: 5,
  ),
];

final Map<String, SkillNode> skillById = {for (final n in skillNodes) n.id: n};

/// Archi (propedeutica -> skill) derivati dai prerequisiti.
List<(String, String)> get skillEdges => [
  for (final n in skillNodes)
    for (final p in n.prereqs) (p, n.id),
];
