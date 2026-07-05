import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'medications_manage_tab.dart';
import 'medications_today_tab.dart';

/// Contenedor de medicamentos con sub-pestanas: Hoy | Tratamientos.
class MedicationsTab extends StatefulWidget {
  const MedicationsTab({super.key});

  @override
  State<MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends State<MedicationsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: context.text.labelLarge,
            tabs: const <Widget>[
              Tab(text: AppStrings.medicationsTodayTab),
              Tab(text: AppStrings.medicationsManageTab),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              MedicationsTodayTab(),
              MedicationsManageTab(),
            ],
          ),
        ),
      ],
    );
  }
}
