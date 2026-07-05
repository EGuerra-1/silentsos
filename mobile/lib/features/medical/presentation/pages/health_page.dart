import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_page_shell.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'diseases_tab.dart';
import 'medications_tab.dart';

/// Hub del modulo medico con pestanas Enfermedades | Medicamentos.
class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
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

    return AppPageShell(
      appBar: const CustomAppBar(title: AppStrings.healthTitle, showBack: false),
      child: Column(
        children: <Widget>[
          const SizedBox(height: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.45),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: context.text.labelLarge,
              tabs: const <Widget>[
                Tab(text: AppStrings.diseasesTab),
                Tab(text: AppStrings.medicationsTab),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
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
