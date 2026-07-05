import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/medical_provider.dart';
import '../widgets/medical_segment_bar.dart';
import '../widgets/medical_tab_shell.dart';
import 'medications_manage_tab.dart';
import 'medications_today_tab.dart';

/// Contenedor de medicamentos: selector Hoy | Tratamientos + contenido.
class MedicationsTab extends ConsumerStatefulWidget {
  const MedicationsTab({super.key});

  @override
  ConsumerState<MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends ConsumerState<MedicationsTab> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final int pendingCount =
        ref.watch(medicalDayControllerProvider).valueOrNull?.pending.length ??
            0;

    return MedicalTabShell(
      selectedIndex: _selectedIndex,
      onChanged: (int index) => setState(() => _selectedIndex = index),
      options: <MedicalSegmentOption>[
        MedicalSegmentOption(
          label: AppStrings.medicationsTodayTab,
          icon: Icons.today_rounded,
          badgeCount: pendingCount,
        ),
        const MedicalSegmentOption(
          label: AppStrings.medicationsManageTab,
          icon: Icons.medical_information_outlined,
        ),
      ],
      subtitles: const <String>[
        AppStrings.medicationsTodaySubtitle,
        AppStrings.medicationsManageSubtitle,
      ],
      children: const <Widget>[
        MedicationsTodayTab(),
        MedicationsManageTab(),
      ],
    );
  }
}
