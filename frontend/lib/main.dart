import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';

part 'workspace.dart';

const _apiBase = String.fromEnvironment(
  'NANOPREDICT_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

const _ink = Color(0xFF142039);
const _indigo = Color(0xFF6240B3);
const _muted = Color(0xFF52617A);
const _teal = Color(0xFF2756D5);
const _line = Color(0xFFDCE3EF);
const _surface = Color(0xFFFFFFFF);
const _soft = Color(0xFFF0F4FA);

void main() => runApp(const NanoPredictLabApp());

class _InputSectionHeading extends StatelessWidget {
  const _InputSectionHeading({
    required this.number,
    required this.title,
    required this.subtitle,
  });
  final String number, title, subtitle;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(number,
                style: const TextStyle(
                    color: _teal, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: _muted, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      );
}

class _TargetPreview extends StatelessWidget {
  const _TargetPreview({required this.percent, required this.hours});
  final double? percent, hours;

  @override
  Widget build(BuildContext context) {
    final entered = percent != null && hours != null;
    final value = entered ? (percent! / 100).clamp(0.0, 1.0) : 0.0;
    final targetText = entered
        ? 'YOUR TARGET  ' +
            percent!.toStringAsFixed(percent! % 1 == 0 ? 0 : 1) +
            '% at ' +
            hours!.toStringAsFixed(hours! % 1 == 0 ? 0 : 1) +
            ' h'
        : 'YOUR TARGET  Add a percent and time to set a target point';
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFF0E1BB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 16, color: Color(0xFF946915)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(targetText,
                    style: const TextStyle(
                        color: Color(0xFF795D22),
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: const Color(0xFFEFE5CE),
              color: const Color(0xFFB17A1C),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
              'User-entered design goal · not a prediction or observation',
              style: TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _OutputPreview extends StatelessWidget {
  const _OutputPreview();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.bubble_chart_outlined, 'Carrier & excipients'),
      (Icons.tune_rounded, 'Ratios & batches'),
      (Icons.straighten_rounded, 'Size · PDI · zeta'),
      (Icons.science_outlined, 'Entrapment & release'),
    ];
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final (icon, label) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFF4F7FC),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _line)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: _teal),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}

class NanoPredictLabApp extends StatelessWidget {
  const NanoPredictLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _teal,
      brightness: Brightness.light,
      surface: _surface,
    );
    return MaterialApp(
      title: 'NanoPredict Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1F4F9),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
          headlineSmall: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleLarge: TextStyle(color: _ink, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: _ink, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: _ink, height: 1.5),
          bodyMedium: TextStyle(color: _muted, height: 1.45),
          labelLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAFBFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          labelStyle: const TextStyle(color: _muted),
          hintStyle: TextStyle(color: _muted.withValues(alpha: 0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _teal, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB84943)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB84943), width: 1.5),
          ),
        ),
      ),
      home: const WorkspacePage(),
    );
  }
}

class FormulationFlow extends StatefulWidget {
  const FormulationFlow({super.key, this.initialExample});
  final String? initialExample;

  @override
  State<FormulationFlow> createState() => _FormulationFlowState();
}

class _FormulationFlowState extends State<FormulationFlow> {
  final _formKey = GlobalKey<FormState>();
  final _resultsKey = GlobalKey();
  final _drug = TextEditingController();
  final _route = TextEditingController();
  final _tissue = TextEditingController();
  final _hours = TextEditingController();
  final _percent = TextEditingController();
  final _mw = TextEditingController();
  final _logp = TextEditingController();
  final _pka = TextEditingController();
  final _solubility = TextEditingController();
  final _solubilityConditions = TextEditingController();
  final _stability = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _formError;
  Map<String, dynamic>? _result;

  static const _allTargets = [
    'carrier',
    'excipients',
    'ratios',
    'batches',
    'size',
    'pdi',
    'zeta',
    'entrapment',
    'release',
  ];

  @override
  void initState() {
    super.initState();
    final example = widget.initialExample;
    if (example != null) _applyExample(example);
  }

  void _loadExample(String example) {
    _formKey.currentState!.reset();
    setState(() => _applyExample(example));
  }

  void _applyExample(String example) {
    final gap = example == 'gap';
    for (final controller in [
      _mw,
      _logp,
      _pka,
      _solubility,
      _solubilityConditions,
      _stability,
    ]) {
      controller.clear();
    }
    _drug.text = gap ? 'quercetin' : 'celecoxib';
    _route.text = gap ? 'intranasal' : 'topical';
    _tissue.text = gap ? 'brain' : 'skin';
    _hours.text = gap ? '' : '24';
    _percent.text = gap ? '' : '65';
    _result = null;
    _error = null;
    _formError = null;
  }

  @override
  void dispose() {
    for (final controller in [
      _drug,
      _route,
      _tissue,
      _hours,
      _percent,
      _mw,
      _logp,
      _pka,
      _solubility,
      _solubilityConditions,
      _stability,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _optionalNumber(
    String? value, {
    bool positive = false,
    bool nonNegative = false,
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || !parsed.isFinite) return 'Enter a finite number.';
    if (positive && parsed <= 0) return 'Must be greater than zero.';
    if (nonNegative && parsed < 0) return 'Must be zero or greater.';
    return null;
  }

  bool get _hasReleaseTarget =>
      _hours.text.trim().isNotEmpty || _percent.text.trim().isNotEmpty;

  String? _percentValidator(String? value) {
    if (!_hasReleaseTarget) return null;
    final error = _optionalNumber(value);
    if (error != null) return error;
    if (value == null || value.trim().isEmpty)
      return 'Enter a percentage target.';
    final parsed = double.parse(value.trim());
    if (parsed < 0 || parsed > 100) return 'Use a value from 0 to 100.';
    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final payload = <String, dynamic>{
      'drug': _drug.text.trim(),
      'route': _route.text.trim(),
      'tissue': _tissue.text.trim(),
      'targets': _allTargets,
    };
    if (_hasReleaseTarget) {
      payload['desired_release'] = {
        'hours': double.parse(_hours.text),
        'percent': double.parse(_percent.text),
      };
    }
    final descriptors = <String, dynamic>{};
    for (final entry in [
      ('mw_da', _mw, true),
      ('logp', _logp, false),
      ('pka', _pka, false),
      ('solubility_mg_ml', _solubility, true),
    ]) {
      if (entry.$2.text.trim().isNotEmpty)
        descriptors[entry.$1] = double.parse(entry.$2.text.trim());
    }
    if (_solubilityConditions.text.trim().isNotEmpty)
      descriptors['solubility_conditions'] = _solubilityConditions.text.trim();
    if (_stability.text.trim().isNotEmpty)
      descriptors['stability_notes'] = _stability.text.trim();
    if (descriptors.isNotEmpty) payload['descriptors'] = descriptors;

    FocusManager.instance.primaryFocus?.unfocus();
    _revealReport(_resultsKey);
    setState(() {
      _loading = true;
      _error = null;
      _formError = null;
    });
    try {
      final response = await _postJson('/v1/formulation-assessments', payload);
      if (mounted) setState(() => _result = response);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.describe());
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Could not reach the assessment API. Check your connection and try again.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final wide = bounds.maxWidth >= 810;
        final form = _formCard();
        final output = AssessmentPanel(
          key: _resultsKey,
          result: _result,
          error: _error,
          loading: _loading,
          onRetry: _submit,
          accent: _teal,
          emptyTitle: 'Your evidence review will appear here',
          emptyHint:
              'Enter the drug profile, route, tissue, and optional release target to build an evidence-led brief.',
          formulation: true,
        );
        if (wide)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: form),
              const SizedBox(width: 18),
              Expanded(flex: 7, child: output),
            ],
          );
        return Column(children: [form, const SizedBox(height: 16), output]);
      },
    );
  }

  Widget _formCard() {
    return _CardShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeading(
              eyebrow: 'FORMULATION DESIGN BRIEF',
              title: 'Describe the delivery need',
              icon: Icons.biotech_outlined,
            ),
            const SizedBox(height: 7),
            const Text(
              'A focused brief is screened against the current literature and model evidence.',
              style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                enabled: !_loading,
                onSelected: _loadExample,
                tooltip: 'Load a reference case',
                itemBuilder: (context) => const [
                  PopupMenuItem(
                      value: 'celecoxib', child: Text('Topical celecoxib')),
                  PopupMenuItem(
                      value: 'gap', child: Text('Intranasal quercetin')),
                ],
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science_outlined, color: _teal, size: 17),
                      SizedBox(width: 6),
                      Text('Try a reference case',
                          style: TextStyle(
                              color: _teal,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                      Icon(Icons.expand_more_rounded, color: _teal, size: 17),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            const _InputSectionHeading(
              number: '01',
              title: 'Drug profile',
              subtitle:
                  'Add known physicochemical properties; unknown values can stay blank.',
            ),
            const SizedBox(height: 10),
            _field(_drug, 'Drug name or identifier',
                required: true, hint: 'e.g. celecoxib'),
            const SizedBox(height: 10),
            _FieldGroup(
              children: [
                _field(_mw, 'Molecular weight',
                    suffix: 'Da',
                    validator: (v) => _optionalNumber(v, positive: true),
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
                _field(_logp, 'LogP',
                    validator: _optionalNumber,
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
                _field(_pka, 'pKa',
                    validator: _optionalNumber,
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
              ],
            ),
            const SizedBox(height: 10),
            _FieldGroup(
              children: [
                _field(_solubility, 'Solubility',
                    suffix: 'mg/mL',
                    validator: (v) => _optionalNumber(v, nonNegative: true),
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
                _field(_solubilityConditions, 'Solubility conditions',
                    hint: 'Optional · solvent, pH, temperature'),
              ],
            ),
            const SizedBox(height: 10),
            _field(_stability, 'Stability notes',
                hint: 'Optional · known sensitivity or storage conditions',
                maxLines: 2),
            const SizedBox(height: 18),
            const _InputSectionHeading(
              number: '02',
              title: 'Delivery context',
              subtitle:
                  'Tell us where and how the formulation should be administered.',
            ),
            const SizedBox(height: 10),
            _FieldGroup(
              children: [
                _field(_route, 'Route of administration',
                    required: true, hint: 'e.g. topical'),
                _field(_tissue, 'Target organ or tissue',
                    required: true, hint: 'e.g. skin'),
              ],
            ),
            const SizedBox(height: 18),
            const _InputSectionHeading(
              number: '03',
              title: 'Desired release profile',
              subtitle:
                  'Optional target point; it is never treated as a measured or predicted value.',
            ),
            const SizedBox(height: 10),
            _FieldGroup(
              children: [
                _field(_percent, 'Target released',
                    suffix: '%',
                    onChanged: (_) => setState(() {}),
                    validator: _percentValidator,
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
                _field(_hours, 'At time',
                    suffix: 'hours',
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (!_hasReleaseTarget) return null;
                      final error = _optionalNumber(value, positive: true);
                      if (error != null) return error;
                      if (value == null || value.trim().isEmpty)
                        return 'Enter a time.';
                      return null;
                    },
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
              ],
            ),
            const SizedBox(height: 9),
            _TargetPreview(
              percent: double.tryParse(_percent.text),
              hours: double.tryParse(_hours.text),
            ),
            const SizedBox(height: 18),
            const _InputSectionHeading(
              number: '04',
              title: 'What the evidence screen returns',
              subtitle:
                  'A fixed report keeps every requested outcome visible, including gaps.',
            ),
            const SizedBox(height: 10),
            const _OutputPreview(),
            const SizedBox(height: 11),
            const _InlineNote(
              text:
                  'Current drug-specific numeric models are withheld after study-held-out validation. Literature retrieval can surface cited candidates; it does not generate or validate new ratios or batches. Use the separate Eugster workflow for in-scope microfluidic liposome estimates.',
            ),
            if (_formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_formError!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.manage_search_rounded, size: 19),
                label: Text(_loading
                    ? 'Reviewing evidence…'
                    : 'Build formulation brief'),
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 49),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    String? hint,
    String? suffix,
    void Function(String)? onChanged,
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: keyboard == null && maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      keyboardType: keyboard,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ),
      validator: validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty))
              return 'This field is required.';
            if (value != null &&
                value.length > (label == 'Stability notes' ? 500 : 200))
              return 'Text is too long.';
            return null;
          },
    );
  }
}

class ProcessFlow extends StatefulWidget {
  const ProcessFlow({super.key, this.useExample = false});
  final bool useExample;

  @override
  State<ProcessFlow> createState() => _ProcessFlowState();
}

class _ProcessFlowState extends State<ProcessFlow> {
  final _formKey = GlobalKey<FormState>();
  final _resultsKey = GlobalKey();
  final _lipid = TextEditingController();
  final _chip = TextEditingController();
  final _cholesterol = TextEditingController();
  final _peg = TextEditingController();
  final _flow = TextEditingController();
  final _ratio = TextEditingController();
  final _assay = TextEditingController();
  final Set<String> _targets = {'size', 'pdi', 'formation'};
  bool _loading = false;
  String? _error;
  String? _formError;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    if (widget.useExample) _applyExample();
  }

  void _loadExample() {
    _formKey.currentState!.reset();
    setState(_applyExample);
  }

  void _applyExample() {
    _lipid.text = 'DMPC';
    _chip.text = 'ZZ';
    _cholesterol.text = '40';
    _peg.text = '5';
    _flow.text = '8';
    _ratio.text = '1';
    _assay.clear();
    _targets
      ..clear()
      ..addAll(['size', 'pdi', 'formation']);
    _result = null;
    _error = null;
    _formError = null;
  }

  @override
  void dispose() {
    for (final controller in [
      _lipid,
      _chip,
      _cholesterol,
      _peg,
      _flow,
      _ratio,
      _assay,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _numberValidator(
    String? value, {
    bool positive = false,
    bool percentage = false,
  }) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || !parsed.isFinite) return 'Enter a finite number.';
    if (positive && parsed <= 0) return 'Must be greater than zero.';
    if (percentage && (parsed < 0 || parsed > 100))
      return 'Use a value from 0 to 100.';
    return null;
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    if (_targets.isEmpty) {
      setState(() => _formError = 'Select at least one process output.');
      return;
    }
    if (double.parse(_cholesterol.text) + double.parse(_peg.text) > 100) {
      setState(
        () => _formError =
            'Cholesterol and PEG percentages cannot add up to more than 100%.',
      );
      return;
    }
    final payload = <String, dynamic>{
      'targets': ['size', 'pdi', 'formation'].where(_targets.contains).toList(),
      'candidate': {
        'primary_lipid': _lipid.text.trim(),
        'chip': _chip.text.trim(),
        'cholesterol_pct': double.parse(_cholesterol.text),
        'peg_pct': double.parse(_peg.text),
        'tfr_ml_min': double.parse(_flow.text),
        'aqueous_to_organic_frr': double.parse(_ratio.text),
      },
    };
    if (_assay.text.trim().isNotEmpty) payload['assay'] = _assay.text.trim();
    FocusManager.instance.primaryFocus?.unfocus();
    _revealReport(_resultsKey);
    setState(() {
      _loading = true;
      _error = null;
      _formError = null;
    });
    try {
      final response = await _postJson('/v1/process-assessments', payload);
      if (mounted) setState(() => _result = response);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.describe());
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Could not reach the assessment API. Check your connection and try again.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final wide = bounds.maxWidth >= 810;
        final form = _formCard();
        final output = AssessmentPanel(
          key: _resultsKey,
          result: _result,
          error: _error,
          loading: _loading,
          onRetry: _submit,
          accent: _indigo,
          emptyTitle: 'Process benchmarks will appear here',
          emptyHint:
              'Use a liposome recipe and settings covered by the Eugster cohort.',
        );
        if (wide)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: form),
              const SizedBox(width: 18),
              Expanded(flex: 7, child: output),
            ],
          );
        return Column(children: [form, const SizedBox(height: 16), output]);
      },
    );
  }

  Widget _formCard() {
    return _CardShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeading(
              eyebrow: 'EUGSTER MICROFLUIDIC COHORT',
              title: 'Process inputs',
              icon: Icons.water_drop_outlined,
              accent: _indigo,
            ),
            const SizedBox(height: 11),
            const Text(
              'Model scope is limited to supported lipid and chip pairings and observed process ranges.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: _indigo),
                onPressed: _loading ? null : _loadExample,
                label: const Text('Load cohort example'),
                icon: const Icon(Icons.science_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 9),
            _FieldGroup(
              children: [
                _field(
                  _lipid,
                  'Primary lipid',
                  hint: 'e.g. DMPC',
                  required: true,
                ),
                _field(_chip, 'Chip', hint: 'e.g. ZZ', required: true),
              ],
            ),
            const SizedBox(height: 13),
            _FieldGroup(
              children: [
                _field(
                  _cholesterol,
                  'Cholesterol',
                  suffix: '%',
                  validator: (v) => _numberValidator(v, percentage: true),
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _field(
                  _peg,
                  'PEG',
                  suffix: '%',
                  validator: (v) => _numberValidator(v, percentage: true),
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Cholesterol + PEG must not exceed 100%.',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
            const SizedBox(height: 13),
            _FieldGroup(
              children: [
                _field(
                  _flow,
                  'Total flow rate',
                  suffix: 'mL/min',
                  validator: (v) => _numberValidator(v, positive: true),
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _field(
                  _ratio,
                  'Aqueous : organic',
                  suffix: 'FRR',
                  validator: (v) => _numberValidator(v, positive: true),
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const _SectionLabel('OUTPUTS'),
            const SizedBox(height: 7),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ('size', 'Particle size · nm'),
                ('pdi', 'PDI · unitless'),
                ('formation', 'Formation score'),
              ]
                  .map(
                    (item) => FilterChip(
                      label: Text(item.$2),
                      selected: _targets.contains(item.$1),
                      onSelected: (selected) => setState(() {
                        selected
                            ? _targets.add(item.$1)
                            : _targets.remove(item.$1);
                      }),
                      side: BorderSide(
                        color: _targets.contains(item.$1)
                            ? const Color(0xFFD6C9F0)
                            : _line,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFF0EBFA),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _targets.contains(item.$1) ? _teal : _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 13),
            _field(
              _assay,
              'Assay context',
              hint: 'Optional · for comparison checks',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF0E2C4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Color(0xFF946915),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Size and PDI are conditional on a passing formation score. Historical errors describe the cohort; they are not prediction intervals.',
                      style: TextStyle(
                        color: Color(0xFF715B30),
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            if (_formError != null)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _formError!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.query_stats_rounded, size: 19),
                label: Text(
                  _loading ? 'Assessing process…' : 'Assess process settings',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    String? suffix,
    bool required = false,
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ),
      validator: validator ??
          (value) => required && (value == null || value.trim().isEmpty)
              ? 'This field is required.'
              : null,
    );
  }
}

class AssessmentPanel extends StatelessWidget {
  const AssessmentPanel({
    super.key,
    required this.result,
    required this.error,
    required this.loading,
    required this.onRetry,
    required this.accent,
    required this.emptyTitle,
    required this.emptyHint,
    this.formulation = false,
  });
  final Map<String, dynamic>? result;
  final String? error;
  final bool loading;
  final VoidCallback onRetry;
  final Color accent;
  final String emptyTitle;
  final String emptyHint;
  final bool formulation;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Semantics(
        liveRegion: true,
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          child: loading
              ? const _LoadingState(key: ValueKey('loading'))
              : error != null
                  ? _ErrorState(
                      key: const ValueKey('error'),
                      error: error!,
                      onRetry: onRetry,
                    )
                  : result == null
                      ? _EmptyState(
                          accent: accent,
                          key: const ValueKey('empty'),
                          title: emptyTitle,
                          hint: emptyHint,
                        )
                      : formulation
                          ? _FormulationResultView(
                              key: const ValueKey('formulation-result'),
                              data: result!,
                            )
                          : _ResultView(
                              key: const ValueKey('result'), data: result!),
        ),
      ),
    );
  }
}

class _FormulationResultView extends StatelessWidget {
  const _FormulationResultView({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final results = Map<String, dynamic>.from(data['results'] as Map? ?? {});
    final request = Map<String, dynamic>.from(data['request'] as Map? ?? {});
    final reports = results.values.whereType<Map>();
    final estimates = reports
        .where((item) => (item['model'] as Map?)?['value'] != null)
        .length;
    final candidates = reports
        .where((item) => item['decision'] == 'literature_candidate')
        .length;
    final conflicts = reports
        .where((item) => item['decision'] == 'conflicting_evidence')
        .length;
    final unresolved = results.length - estimates - candidates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _CardHeading(
          eyebrow: 'EVIDENCE-LED FORMULATION BRIEF',
          title: 'Assessment output',
          icon: Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 13),
        _SubmittedContext(request: request),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BriefMetric(
              count: estimates,
              label: 'Model estimates',
              icon: Icons.auto_graph_rounded,
              color: _teal,
              fill: const Color(0xFFEAF5F2),
            ),
            _BriefMetric(
              count: candidates,
              label: 'Literature candidates',
              icon: Icons.menu_book_outlined,
              color: const Color(0xFF3A5DAA),
              fill: const Color(0xFFEAF0FF),
            ),
            _BriefMetric(
              count: unresolved,
              label: 'Unresolved',
              icon: Icons.help_outline_rounded,
              color: _muted,
              fill: const Color(0xFFF0F2F6),
            ),
            _BriefMetric(
              count: conflicts,
              label: 'Conflicts to review',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFF9A5D1B),
              fill: const Color(0xFFFFF2DE),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Counts describe this report only; they are not confidence scores.',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
        const SizedBox(height: 17),
        for (final group in const <(String, List<String>)>[
          ('CARRIER & EXCIPIENT EVIDENCE', ['carrier', 'excipients']),
          ('RATIOS & PROPOSED BATCHES', ['ratios', 'batches']),
          (
            'PARTICLE AND LOADING OUTCOMES',
            ['size', 'pdi', 'zeta', 'entrapment']
          ),
          ('RELEASE PROFILE', ['release']),
        ]) ...[
          if (group.$2.any(results.containsKey)) ...[
            _SectionLabel(group.$1),
            const SizedBox(height: 7),
            for (final name in group.$2)
              if (results.containsKey(name)) ...[
                _EndpointCard(
                  key: ValueKey(
                      (data['request_id'] ?? '').toString() + ':' + name),
                  name: name,
                  report: Map<String, dynamic>.from(results[name] as Map),
                ),
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 6),
          ],
        ],
        const _InlineNote(
          text:
              'Serving method: TF-IDF ranking over a small curated literature corpus with rule-based adjudication; no generative RAG model is connected. The 2,641-record catalogue is not loaded as a validated cross-carrier predictor. Drug-specific numerical predictions, ratios, and generated batches remain withheld pending stronger validation.',
        ),
        const SizedBox(height: 7),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _downloadAssessment(data),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download evidence report'),
          ),
        ),
        ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: EdgeInsets.zero,
          title: const Text('Release metadata',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          children: [
            SelectableText(
              'Request: ' +
                  (data['request_id'] ?? '—').toString() +
                  '\nAPI: ' +
                  (data['api_version'] ?? '—').toString() +
                  '\nModel: ' +
                  (data['model_release'] ?? '—').toString() +
                  '\nCorpus: ' +
                  (data['corpus_release'] ?? '—').toString(),
              style: const TextStyle(color: _muted, fontSize: 11, height: 1.5),
            ),
            const SizedBox(height: 5),
            Text((data['method'] ?? '').toString(),
                style:
                    const TextStyle(color: _muted, fontSize: 11, height: 1.45)),
          ],
        ),
      ],
    );
  }
}

class _BriefMetric extends StatelessWidget {
  const _BriefMetric({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    required this.fill,
  });
  final int count;
  final String label;
  final IconData icon;
  final Color color, fill;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 132),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.12))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 7),
            Text(count.toString(),
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _ResultView extends StatelessWidget {
  const _ResultView({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final results = Map<String, dynamic>.from(data['results'] as Map? ?? {});
    final request = Map<String, dynamic>.from(data['request'] as Map? ?? {});
    final ready = results.values
        .whereType<Map>()
        .where(
          (result) => ['model_estimate', 'literature_candidate']
              .contains(result['decision']),
        )
        .length;
    final conflicts = results.values
        .whereType<Map>()
        .where(
          (result) => result['decision'] == 'conflicting_evidence',
        )
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _CardHeading(
          eyebrow: 'ASSESSMENT REPORT',
          title: 'Results overview',
          icon: Icons.fact_check_outlined,
        ),
        const SizedBox(height: 14),
        _SubmittedContext(request: request),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill(
                label: '${results.length} endpoints',
                color: _soft,
                textColor: _ink,
                icon: Icons.checklist_rounded),
            _Pill(
                label: '$ready supported',
                color: const Color(0xFFE6F5ED),
                textColor: const Color(0xFF166446),
                icon: Icons.check_circle_outline),
            _Pill(
                label: '${results.length - ready - conflicts} unresolved',
                color: _soft,
                textColor: _muted,
                icon: Icons.help_outline),
            if (conflicts > 0)
              _Pill(
                  label: '$conflicts to review',
                  color: const Color(0xFFFFF2DE),
                  textColor: const Color(0xFF9A5D1B),
                  icon: Icons.warning_amber),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel('ENDPOINTS'),
        const SizedBox(height: 7),
        for (final entry in results.entries) ...[
          _EndpointCard(
            key: ValueKey('${data['request_id']}:${entry.key}'),
            name: entry.key,
            report: Map<String, dynamic>.from(entry.value as Map),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _downloadAssessment(data),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download report (JSON)'),
          ),
        ),
        const SizedBox(height: 6),
        ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: const Text('Run metadata',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          children: [
            SelectableText(
              'Request: ${data['request_id'] ?? '—'}\nAPI: ${data['api_version'] ?? '—'}\nModel: ${data['model_release'] ?? '—'}\nCorpus: ${data['corpus_release'] ?? '—'}',
              style: const TextStyle(fontSize: 12, color: _muted, height: 1.5),
            ),
            const SizedBox(height: 6),
            Text('${data['method'] ?? ''}',
                style:
                    const TextStyle(color: _muted, fontSize: 12, height: 1.45)),
          ],
        ),
      ],
    );
  }
}

void _downloadAssessment(Map<String, dynamic> data) {
  final bytes = const JsonEncoder.withIndent('  ').convert(data);
  final url = html.Url.createObjectUrlFromBlob(
    html.Blob([bytes], 'application/json'),
  );
  final request = '${data['request_id'] ?? 'report'}'
      .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
  html.AnchorElement(href: url)
    ..download = 'nanopredict-lab-${request.isEmpty ? 'report' : request}.json'
    ..click();
  Future<void>.delayed(
      const Duration(seconds: 1), () => html.Url.revokeObjectUrl(url));
}

class _SubmittedContext extends StatelessWidget {
  const _SubmittedContext({required this.request});
  final Map<String, dynamic> request;

  @override
  Widget build(BuildContext context) {
    final desired = Map<String, dynamic>.from(
      request['desired_release'] as Map? ?? {},
    );
    final candidate = Map<String, dynamic>.from(
      request['candidate'] as Map? ?? {},
    );
    final descriptors = Map<String, dynamic>.from(
      request['descriptors'] as Map? ?? {},
    );
    final label = candidate.isNotEmpty
        ? '${candidate['primary_lipid']} · ${candidate['chip']}  |  ${candidate['cholesterol_pct']}% cholesterol, ${candidate['peg_pct']}% PEG  |  ${candidate['tfr_ml_min']} mL/min, FRR ${candidate['aqueous_to_organic_frr']}'
        : '${request['drug'] ?? '—'} · ${request['route'] ?? '—'} · ${request['tissue'] ?? '—'}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('SUBMITTED CONTEXT'),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (descriptors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final entry in descriptors.entries)
                  _Pill(
                    label: entry.key == 'mw_da'
                        ? 'MW ' + entry.value.toString() + ' Da'
                        : entry.key == 'solubility_mg_ml'
                            ? 'Solubility ' + entry.value.toString() + ' mg/mL'
                            : entry.key == 'solubility_conditions'
                                ? 'Solubility context: ' +
                                    entry.value.toString()
                                : entry.key == 'stability_notes'
                                    ? 'Stability: ' + entry.value.toString()
                                    : entry.key + ' ' + entry.value.toString(),
                    color: Colors.white,
                    textColor: _muted,
                  ),
              ],
            ),
          ],
          if (desired.isNotEmpty) ...[
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFF946915),
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  'YOUR TARGET  ${desired['percent']}% at ${desired['hours']} h',
                  style: const TextStyle(
                    color: Color(0xFF795D22),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '· entered value',
                  style: TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({super.key, required this.name, required this.report});
  final String name;
  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final decision = '${report['decision'] ?? 'insufficient_evidence'}';
    final model = Map<String, dynamic>.from(report['model'] as Map? ?? {});
    final evidence = (report['evidence'] as List? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final (label, color, background, icon) = _decisionAppearance(decision);
    final value = model['value'];
    final observations = <String>[];
    for (final item in evidence) {
      // Only matched study measurements are promoted to the overview.
      if (item['applicability'] != 'matched_drug_and_route') continue;
      final measurements = item['measurements'];
      final metric = measurements is Map ? measurements[name] : null;
      if (metric is Map && metric['value'] != null) {
        observations.add(
            '${metric['value']}${metric['unit'] == '%' ? '' : ' '}${metric['unit'] ?? ''}');
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.fromLTRB(13, 6, 9, 6),
        childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          name == 'pdi' ? 'PDI' : _titleCase(name),
          style: const TextStyle(
              color: _ink, fontSize: 15, fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Wrap(
            spacing: 7,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Pill(
                  label: label,
                  color: background,
                  textColor: color,
                  icon: icon),
              if (value != null)
                Text(
                  'Model: $value ${model['unit'] ?? ''}',
                  style: const TextStyle(
                      color: _ink, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              if (observations.isNotEmpty)
                Text(
                  'Published: ${observations.toSet().join(' · ')}',
                  style: const TextStyle(
                      color: Color(0xFF176446),
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
            ],
          ),
        ),
        children: [
          const Divider(color: _line),
          Text(
            '${report['rationale'] ?? ''}',
            style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          _ModelReport(model: model, endpoint: name),
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 12),
            const _SectionLabel('LITERATURE REPORT'),
            const SizedBox(height: 8),
            for (final item in evidence)
              _EvidenceCard(item: item, endpoint: name),
          ] else if (decision != 'model_estimate') ...[
            const SizedBox(height: 10),
            const _InlineNote(
              text:
                  'No applicable source was retrieved for this endpoint in the current curated corpus.',
            ),
          ],
        ],
      ),
    );
  }
}

class _ModelReport extends StatelessWidget {
  const _ModelReport({required this.model, required this.endpoint});
  final Map<String, dynamic> model;
  final String endpoint;

  @override
  Widget build(BuildContext context) {
    final status = '${model['status'] ?? 'unsupported_endpoint'}';
    final value = model['value'];
    final unit = model['unit'] ?? '';
    final reason = model['reason'];
    final limitation = model['limitation'];
    final accent = status == 'process_estimate'
        ? _teal
        : (status == 'out_of_scope' ? const Color(0xFF946915) : _muted);
    final fill = status == 'process_estimate'
        ? const Color(0xFFF0F8F6)
        : const Color(0xFFF7F8F8);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, size: 15, color: _teal),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'MODEL REPORT',
                  style: TextStyle(
                    color: _teal,
                    letterSpacing: 0.8,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _humanStatus(status),
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (value != null) ...[
            const SizedBox(height: 6),
            Text(
              '$value $unit',
              style: const TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            if (endpoint == 'formation')
              const Text(
                'Uncalibrated formation score',
                style: TextStyle(color: _muted, fontSize: 11),
              ),
            if (model['support'] != null)
              Text(
                'Support: ${model['support']}',
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
          ],
          if (reason != null) ...[
            const SizedBox(height: 5),
            Text(
              '$reason',
              style: const TextStyle(color: _muted, fontSize: 11, height: 1.45),
            ),
          ],
          if (model['formation_score'] != null && endpoint != 'formation') ...[
            const SizedBox(height: 6),
            Text(
              'Formation screen: ${model['formation_score']} · uncalibrated score',
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (model['grouped_cv_mae'] != null) ...[
            const SizedBox(height: 6),
            Text(
              'Cohort benchmark: grouped-CV MAE ${model['grouped_cv_mae']} $unit',
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (model['grouped_cv_absolute_error_p90'] != null)
              Text(
                '90th percentile absolute error ${model['grouped_cv_absolute_error_p90']} $unit · cohort summary, not an individual interval',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
          ],
          if (model['benchmark'] is List) ...[
            const SizedBox(height: 7),
            const Text(
              'HELD-OUT COHORT BENCHMARKS',
              style: TextStyle(
                color: _muted,
                letterSpacing: 0.65,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            for (final row in (model['benchmark'] as List).whereType<Map>())
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '${row['grouping']}: MAE ${row['mae']} vs median ${row['median_mae']} · n=${row['n']}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            const Text(
              'These retrospective validation summaries do not quantify uncertainty for a new formulation.',
              style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
            ),
          ],
          if (model['missing'] is List && (model['missing'] as List).isNotEmpty)
            Text(
              'Missing inputs: ${(model['missing'] as List).join(', ')}',
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          if (limitation != null) ...[
            const SizedBox(height: 5),
            Text(
              '$limitation',
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
          ],
          if (status == 'unsupported_endpoint')
            const _InlineNote(
              text:
                  'No validated numerical estimator is released for this endpoint.',
            ),
        ],
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.item, required this.endpoint});
  final Map<String, dynamic> item;
  final String endpoint;

  @override
  Widget build(BuildContext context) {
    final measurements = Map<String, dynamic>.from(
      item['measurements'] as Map? ?? {},
    );
    final measured = Map<String, dynamic>.from(
      measurements[endpoint] as Map? ?? {},
    );
    final applicability =
        '${item['applicability'] ?? 'background_or_analogue'}';
    final matched = applicability == 'matched_drug_and_route';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${item['title'] ?? 'Source'}',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                matched ? Icons.verified_outlined : Icons.info_outline_rounded,
                size: 15,
                color: matched ? _teal : _muted,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${item['kind'] ?? 'source'} · ${matched ? 'matched drug and route' : 'background or analogue'}',
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item['locator'] != null)
            Text(
              'Locator: ${item['locator']}',
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          const SizedBox(height: 6),
          Text(
            '${item['text'] ?? ''}',
            style: const TextStyle(color: _ink, fontSize: 13, height: 1.5),
          ),
          if (measured.isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5F5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined, size: 14, color: _teal),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'PUBLISHED OBSERVATION  ${measured['value']} ${measured['unit']}',
                      style: const TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Text(
                    'study batch',
                    style: TextStyle(color: _muted, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'Limitation: ${item['limitation'] ?? 'Not stated'}',
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 2),
          Text(
            'Independence: ${item['independence'] ?? 'training_overlap_unverified'}',
            style: const TextStyle(color: _muted, fontSize: 9),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openUrl('${item['url']}'),
              icon: const Icon(Icons.open_in_new_rounded, size: 14),
              label: const Text('Open citation'),
              style: TextButton.styleFrom(
                foregroundColor: _teal,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key, required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _StateMessage(
        icon: Icons.cloud_off_outlined,
        color: const Color(0xFFB84943),
        title: 'Assessment request failed',
        body: error,
        footer: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {super.key,
      required this.title,
      required this.hint,
      required this.accent});
  final Color accent;
  final String title;
  final String hint;
  @override
  Widget build(BuildContext context) => _StateMessage(
        icon: Icons.fact_check_outlined,
        color: accent,
        title: title,
        body: hint,
        footer: const _Pill(
          label: 'AWAITING SUBMISSION',
          color: Color(0xFFEFF5F5),
          textColor: _teal,
        ),
      );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 235,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _teal, strokeWidth: 2.5),
              SizedBox(height: 16),
              Text(
                'Assessing model scope and evidence…',
                style: TextStyle(color: _muted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.footer,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final Widget footer;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 235),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: _muted, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 13),
                footer,
              ],
            ),
          ),
        ),
      );
}

class _ScopeFooter extends StatelessWidget {
  const _ScopeFooter();
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_outlined, color: _muted, size: 17),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Research use. Evidence relevance is not calibrated confidence. Drug-loaded estimates, cross-carrier rankings, ratio optimization, and tissue delivery predictions are not released by this prototype.',
                style: TextStyle(color: _muted, fontSize: 11, height: 1.45),
              ),
            ),
          ],
        ),
      );
}

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, bounds) {
          final columns = bounds.maxWidth >= (children.length == 3 ? 460 : 320);
          if (columns) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [for (final child in children) Expanded(child: child)],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: children,
          );
        },
      );
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F2245),
              blurRadius: 18,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.eyebrow,
    required this.title,
    required this.icon,
    this.accent = _teal,
  });
  final String eyebrow;
  final String title;
  final IconData icon;
  final Color accent;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: accent,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                letterSpacing: 0.25,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
}

class _InlineNote extends StatelessWidget {
  const _InlineNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          text,
          style: const TextStyle(color: _muted, fontSize: 12, height: 1.45),
        ),
      );
}

void _revealReport(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final report = key.currentContext;
    if (report == null || !TickerMode.of(report)) return;
    Scrollable.ensureVisible(
      report,
      alignment: .05,
      duration: MediaQuery.disableAnimationsOf(report)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  });
}

class ApiException implements Exception {
  ApiException(this.body, this.status);
  final Map<String, dynamic> body;
  final int status;

  String describe() {
    final parts = <String>[
      '${body['message'] ?? 'The API rejected this request.'} (HTTP $status)',
    ];
    final fields = (body['fields'] as List? ?? []).whereType<Map>();
    for (final field in fields) {
      final path = '${field['path'] ?? 'input'}';
      final message = '${field['message'] ?? 'Invalid value.'}';
      parts.add('$path: $message');
    }
    return parts.join('\n');
  }
}

Future<Map<String, dynamic>> _postJson(
  String path,
  Map<String, dynamic> payload,
) async {
  final base = _apiBase.replaceFirst(RegExp(r'/+$'), '');
  final response = await html.HttpRequest.request(
    '$base$path',
    method: 'POST',
    sendData: jsonEncode(payload),
    requestHeaders: const {'Content-Type': 'application/json'},
  );
  Map<String, dynamic> decoded = {};
  try {
    final parsed = jsonDecode(response.responseText ?? '{}');
    if (parsed is Map) decoded = Map<String, dynamic>.from(parsed);
  } catch (_) {}
  final status = response.status ?? 0;
  if (status < 200 || status >= 300) throw ApiException(decoded, status);
  return decoded;
}

void _openUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
    html.window.open(url, '_blank', 'noopener,noreferrer');
  }
}

String _titleCase(String input) =>
    input.isEmpty ? input : '${input[0].toUpperCase()}${input.substring(1)}';

String _humanStatus(String status) => switch (status) {
      'process_estimate' => 'ESTIMATE',
      'withheld' => 'WITHHELD',
      'unsupported_endpoint' => 'UNSUPPORTED',
      'out_of_scope' => 'OUT OF SCOPE',
      'missing_inputs' => 'INPUTS NEEDED',
      'invalid_inputs' => 'INVALID INPUTS',
      _ => _titleCase(status.replaceAll('_', ' ')),
    };

(String, Color, Color, IconData) _decisionAppearance(String decision) =>
    switch (decision) {
      'model_estimate' => (
          'MODEL ESTIMATE',
          const Color(0xFF166446),
          const Color(0xFFE6F5ED),
          Icons.auto_graph_rounded,
        ),
      'literature_candidate' => (
          'LITERATURE CANDIDATE',
          const Color(0xFF2F6981),
          const Color(0xFFEAF3F7),
          Icons.menu_book_outlined,
        ),
      'conflicting_evidence' => (
          'REVIEW CONFLICT',
          const Color(0xFF9A5D1B),
          const Color(0xFFFFF2DE),
          Icons.compare_arrows_rounded,
        ),
      'background_only' => (
          'BACKGROUND ONLY',
          const Color(0xFF6A5C9B),
          const Color(0xFFF0EDFA),
          Icons.info_outline_rounded,
        ),
      _ => (
          'INSUFFICIENT EVIDENCE',
          _muted,
          const Color(0xFFF0F3F4),
          Icons.help_outline_rounded,
        ),
    };
