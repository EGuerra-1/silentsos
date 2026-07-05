import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../models/disease_catalog_model.dart';
import '../../utils/medical_formatters.dart';

/// Selector buscable del catalogo global de enfermedades.
class DiseaseCatalogPicker extends StatelessWidget {
  const DiseaseCatalogPicker({
    super.key,
    required this.catalog,
    required this.selectedId,
    required this.onChanged,
    this.validator,
  });

  final List<DiseaseCatalogModel> catalog;
  final String? selectedId;
  final ValueChanged<DiseaseCatalogModel> onChanged;
  final String? Function(String?)? validator;

  DiseaseCatalogModel? get _selected {
    if (selectedId == null) return null;
    for (final DiseaseCatalogModel item in catalog) {
      if (item.id == selectedId) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final DiseaseCatalogModel? selected = _selected;

    return LabeledField(
      label: AppStrings.diseaseCatalogLabel,
      child: FormField<String>(
        key: ValueKey<String?>(selectedId),
        initialValue: selectedId,
        validator: validator,
        builder: (FormFieldState<String> field) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openPicker(context, field),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: AppStrings.diseaseCatalogHint,
                errorText: field.errorText,
                suffixIcon: const Icon(Icons.expand_more_rounded),
              ),
              child: Text(
                selected?.name ?? AppStrings.diseaseCatalogHint,
                style: selected == null
                    ? context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      )
                    : context.text.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openPicker(
    BuildContext context,
    FormFieldState<String> field,
  ) async {
    final DiseaseCatalogModel? picked =
        await showModalBottomSheet<DiseaseCatalogModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return _DiseaseCatalogSheet(catalog: catalog);
      },
    );

    if (picked != null) {
      field.didChange(picked.id);
      onChanged(picked);
    }
  }
}

/// Contenido del bottom sheet con busqueda y lista scrolleable.
class _DiseaseCatalogSheet extends StatefulWidget {
  const _DiseaseCatalogSheet({required this.catalog});

  final List<DiseaseCatalogModel> catalog;

  @override
  State<_DiseaseCatalogSheet> createState() => _DiseaseCatalogSheetState();
}

class _DiseaseCatalogSheetState extends State<_DiseaseCatalogSheet> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DiseaseCatalogModel> get _filtered {
    final String normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return widget.catalog;

    return widget.catalog
        .where(
          (DiseaseCatalogModel item) =>
              item.name.toLowerCase().contains(normalized) ||
              item.classification.toLowerCase().contains(normalized),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final double sheetHeight =
        (MediaQuery.sizeOf(context).height * 0.72) - bottomInset;
    final List<DiseaseCatalogModel> filtered = _filtered;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: SizedBox(
        height: sheetHeight.clamp(280, 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              AppStrings.diseaseCatalogLabel,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              hint: 'Buscar enfermedad...',
              controller: _searchCtrl,
              prefixIcon: const Icon(Icons.search_rounded),
              textInputAction: TextInputAction.search,
              onChanged: (String value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron enfermedades.',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final DiseaseCatalogModel item = filtered[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(item.classification),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de fecha con selector nativo.
class MedicalDateField extends StatelessWidget {
  const MedicalDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final DateTime now = DateTime.now();
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: DateTime(1900),
            lastDate: now,
          );
          onChanged(picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.calendar_today_outlined),
          ),
          child: Text(MedicalFormatters.displayDate(value)),
        ),
      ),
    );
  }
}
