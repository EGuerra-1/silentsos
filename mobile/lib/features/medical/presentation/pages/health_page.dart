import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../providers/medical_provider.dart';
import '../widgets/medical_segment_bar.dart';
import '../widgets/medical_tab_shell.dart';
import 'diseases_tab.dart';
import 'medications_tab.dart';

/// Hub del modulo medico con pestanas Enfermedades | Medicamentos.
class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage> {
  int _selectedIndex = 0;
  bool _diseasesLoaded = false;
  bool _medicationsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTabData(0));
  }

  void _loadTabData(int index) {
    if (!mounted) return;

    if (index == 0 && !_diseasesLoaded) {
      _diseasesLoaded = true;
      ref.read(diseasesControllerProvider.notifier).load();
    } else if (index == 1 && !_medicationsLoaded) {
      _medicationsLoaded = true;
      ref.read(medicationsControllerProvider.notifier).load();
      ref.read(medicalDayControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      appBar: const CustomAppBar(title: AppStrings.healthTitle, showBack: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: MedicalTabShell(
              selectedIndex: _selectedIndex,
              onChanged: (int index) {
                setState(() => _selectedIndex = index);
                _loadTabData(index);
              },
              options: const <MedicalSegmentOption>[
                MedicalSegmentOption(
                  label: AppStrings.diseasesTab,
                  icon: Icons.coronavirus_outlined,
                ),
                MedicalSegmentOption(
                  label: AppStrings.medicationsTab,
                  icon: Icons.medication_outlined,
                ),
              ],
              subtitles: const <String>[
                AppStrings.diseasesSectionSubtitle,
                AppStrings.medicationsSectionSubtitle,
              ],
              children: const <Widget>[
                DiseasesTab(),
                MedicationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
