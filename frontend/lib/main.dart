import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'workspace.dart';

const _apiBase = String.fromEnvironment(
  'NANOPREDICT_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

const _ink = Color(0xFF183329);
const _indigo = Color(0xFF71856F);
const _muted = Color(0xFF66776B);
const _teal = Color(0xFF34745A);
const _line = Color(0xFFDCE6DD);
const _surface = Color(0xFFFFFFFF);
const _soft = Color(0xFFF0F5F0);

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
              color: const Color(0xFFE7F0E6),
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
      (Icons.tune_rounded, 'Ratios'),
      (Icons.straighten_rounded, 'Size · PDI'),
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
                color: const Color(0xFFF1F6F0),
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

class _PropertyCoverage extends StatelessWidget {
  const _PropertyCoverage({required this.controllers});
  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(controllers),
        builder: (context, _) {
          final filled = controllers
              .where((controller) => controller.text.trim().isNotEmpty)
              .length;
          return Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F1),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 16, color: _teal),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text('DRUG PROFILE DETAILS',
                          style: TextStyle(
                              color: _ink,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ),
                    Text(
                        filled.toString() +
                            ' / ' +
                            controllers.length.toString() +
                            ' added',
                        style: const TextStyle(
                            color: _teal,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < controllers.length; i++) ...[
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: controllers[i].text.trim().isNotEmpty
                                ? _teal
                                : const Color(0xFFDCE6DD),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      if (i < controllers.length - 1) const SizedBox(width: 5),
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  'Context only in this release; these fields do not drive validated drug-specific predictions.',
                  style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
                ),
              ],
            ),
          );
        },
      );
}

class _CarrierFamilyStrip extends StatelessWidget {
  const _CarrierFamilyStrip();

  @override
  Widget build(BuildContext context) {
    const families = [
      'Liposome',
      'Niosome',
      'Transfersome',
      'Ethosome',
      'Phytosome'
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final family in families)
          _Pill(
            label: family,
            color: const Color(0xFFEEF4EC),
            textColor: const Color(0xFF3E5C43),
            icon: Icons.circle,
          ),
      ],
    );
  }
}

class _CompositionPreview extends StatelessWidget {
  const _CompositionPreview({
    required this.cholesterol,
    required this.peg,
  });
  final TextEditingController cholesterol, peg;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([cholesterol, peg]),
        builder: (context, _) {
          final cholesterolPct =
              (double.tryParse(cholesterol.text) ?? 0).clamp(0.0, 100.0);
          final pegPct = (double.tryParse(peg.text) ?? 0)
              .clamp(0.0, 100.0 - cholesterolPct);
          final remaining = 100 - cholesterolPct - pegPct;
          final combined = cholesterolPct + pegPct;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F9F4),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('COMPOSITION CHECK',
                          style: TextStyle(
                              color: _ink,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6)),
                    ),
                    Text(combined.toStringAsFixed(1) + '% specified',
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    height: 10,
                    child: CustomPaint(
                      painter: _CompositionPainter(
                        cholesterol: cholesterolPct / 100,
                        peg: pegPct / 100,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 12,
                  runSpacing: 5,
                  children: [
                    _CompositionLegend(
                      color: const Color(0xFF34745A),
                      label: 'Cholesterol ' +
                          cholesterolPct.toStringAsFixed(1) +
                          '%',
                    ),
                    _CompositionLegend(
                      color: const Color(0xFF9AAE78),
                      label: 'PEG ' + pegPct.toStringAsFixed(1) + '%',
                    ),
                    _CompositionLegend(
                      color: const Color(0xFFDCE6DD),
                      label: 'Remaining ' + remaining.toStringAsFixed(1) + '%',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Visual balance only. Confirm ingredient percentage basis against the source method.',
                  style: TextStyle(color: _muted, fontSize: 9, height: 1.35),
                ),
              ],
            ),
          );
        },
      );
}

class _CompositionPainter extends CustomPainter {
  const _CompositionPainter({required this.cholesterol, required this.peg});
  final double cholesterol, peg;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = const Color(0xFFDCE6DD);
    final cholesterolPaint = Paint()..color = const Color(0xFF34745A);
    final pegPaint = Paint()..color = const Color(0xFF9AAE78);
    canvas.drawRect(Offset.zero & size, base);
    final cholesterolWidth = size.width * cholesterol;
    final pegWidth = size.width * peg;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, cholesterolWidth, size.height), cholesterolPaint);
    canvas.drawRect(
        Rect.fromLTWH(cholesterolWidth, 0, pegWidth, size.height), pegPaint);
  }

  @override
  bool shouldRepaint(covariant _CompositionPainter oldDelegate) =>
      oldDelegate.cholesterol != cholesterol || oldDelegate.peg != peg;
}

class _CompositionLegend extends StatelessWidget {
  const _CompositionLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: _muted, fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      );
}

class _ProcessOutputPreview extends StatelessWidget {
  const _ProcessOutputPreview();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'SIZE',
        'cohort estimate · nm',
        Icons.straighten_rounded,
        Color(0xFF34745A)
      ),
      (
        'PDI',
        'cohort estimate · unitless',
        Icons.blur_on_rounded,
        Color(0xFF8FA276)
      ),
      (
        'FORMATION',
        'uncalibrated score',
        Icons.bubble_chart_outlined,
        Color(0xFFB2761E)
      ),
      ('ENTRAPMENT', 'not modeled here', Icons.science_outlined, _muted),
    ];
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final (label, unit, icon, color) in items)
          Container(
            constraints: const BoxConstraints(minWidth: 106),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800)),
                    Text(unit,
                        style: const TextStyle(color: _muted, fontSize: 9)),
                  ],
                ),
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
        scaffoldBackgroundColor: const Color(0xFFF4F7F2),
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
          fillColor: const Color(0xFFFAFCF9),
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
    'size',
    'pdi',
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
    switch (example) {
      case 'gap':
        _drug.text = 'quercetin';
        _route.text = 'intranasal';
        _tissue.text = 'brain';
        _hours.clear();
        _percent.clear();
      case 'oral-quercetin':
        _drug.text = 'quercetin';
        _route.text = 'oral';
        _tissue.text = 'systemic absorption';
        _hours.clear();
        _percent.clear();
      case 'caffeine':
        _drug.text = 'caffeine';
        _route.text = 'topical';
        _tissue.text = 'skin';
        _hours.clear();
        _percent.clear();
      default:
        _drug.text = 'celecoxib';
        _route.text = 'topical';
        _tissue.text = 'skin';
        _hours.text = '24';
        _percent.text = '65';
    }
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
      ('mw_da', _mw),
      ('logp', _logp),
      ('pka', _pka),
      ('solubility_mg_ml', _solubility),
    ]) {
      if (entry.$2.text.trim().isNotEmpty) {
        descriptors[entry.$1] = double.parse(entry.$2.text.trim());
      }
    }
    if (_solubilityConditions.text.trim().isNotEmpty) {
      descriptors['solubility_conditions'] = _solubilityConditions.text.trim();
    }
    if (_stability.text.trim().isNotEmpty) {
      descriptors['stability_notes'] = _stability.text.trim();
    }
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
              eyebrow: 'NANOVESICLE-AI · EVIDENCE SCREENING',
              title: 'Build a formulation brief',
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
                    value: 'celecoxib',
                    child: Text('Celecoxib · topical study'),
                  ),
                  PopupMenuItem(
                    value: 'oral-quercetin',
                    child: Text('Quercetin · oral absorption'),
                  ),
                  PopupMenuItem(
                    value: 'caffeine',
                    child: Text('Caffeine · topical analogue'),
                  ),
                  PopupMenuItem(
                    value: 'gap',
                    child: Text('Quercetin · intranasal evidence gap'),
                  ),
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
            const SizedBox(height: 8),
            const _GuideCallout(
              title: 'What changes this report?',
              body:
                  'Drug name, route, and target tissue are required and control which sources can match. Changing them can change the citations and endpoint status. MW, LogP, pKa, solubility, and stability are saved as context only in this release. A release goal is shown separately; it does not change retrieval or become a prediction.',
              accent: _teal,
            ),
            const SizedBox(height: 13),
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
                    hint: 'e.g. 381.4',
                    validator: (v) => _optionalNumber(v, positive: true),
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
                _field(_logp, 'LogP',
                    hint: 'e.g. 3.5',
                    validator: _optionalNumber,
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
                _field(_pka, 'pKa',
                    hint: 'e.g. 11.1',
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
                    hint: 'e.g. 0.02',
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
            const SizedBox(height: 9),
            _PropertyCoverage(
              controllers: [_mw, _logp, _pka, _solubility, _stability],
            ),
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
                    required: true, hint: 'e.g. topical, oral, intranasal'),
                _field(_tissue, 'Target organ or tissue',
                    required: true, hint: 'e.g. skin, lung, brain'),
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
                    hint: 'e.g. 65',
                    validator: _percentValidator,
                    keyboard:
                        const TextInputType.numberWithOptions(decimal: true)),
                _field(_hours, 'At time',
                    suffix: 'hours',
                    hint: 'e.g. 24',
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
            const _SectionLabel('CARRIER FAMILIES IN THE CATALOGUE'),
            const SizedBox(height: 7),
            const _CarrierFamilyStrip(),
            const SizedBox(height: 11),
            const _InlineNote(
              text:
                  'Current drug-specific numeric models are withheld after study-held-out validation. Literature retrieval can surface cited candidates; it does not generate or validate new ratios or batches. Use the separate Eugster workflow for in-scope microfluidic liposome estimates.',
            ),
            const SizedBox(height: 8),
            const _ReferenceLibrary(),
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
    if (double.parse(_cholesterol.text) + double.parse(_peg.text) > 100) {
      setState(
        () => _formError =
            'Cholesterol and PEG percentages cannot add up to more than 100%.',
      );
      return;
    }
    final payload = <String, dynamic>{
      'targets': ['size', 'pdi', 'formation'],
      'candidate': {
        'primary_lipid': _lipid.text.trim(),
        'chip': _chip.text.trim(),
        'cholesterol_pct': double.parse(_cholesterol.text),
        'peg_pct': double.parse(_peg.text),
        'tfr_ml_min': double.parse(_flow.text),
        'aqueous_to_organic_frr': double.parse(_ratio.text),
      },
    };
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
              eyebrow: 'NANOVESICLE-AI · MICROFLUIDIC PROCESS',
              title: 'Eugster process model',
              icon: Icons.water_drop_outlined,
              accent: _indigo,
            ),
            const SizedBox(height: 11),
            const Text(
              'Model scope is limited to supported lipid and chip pairings and observed process ranges.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
            const SizedBox(height: 9),
            const _GuideCallout(
              title: 'What changes these results?',
              body:
                  'All six process settings are model inputs. Change the lipid/chip pair, composition, total flow, or aqueous-to-organic ratio to assess a different setting. The app only releases numbers for pairings and value ranges represented in the Eugster cohort; other settings are marked out of scope.',
              accent: _indigo,
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
            const _InlineNote(
              text:
                  'The example pre-fills DMPC/ZZ, 40% cholesterol, 5% PEG, 8 mL/min total flow, and FRR 1. Submit it to see the cohort assessment.',
            ),
            const SizedBox(height: 9),
            const _InputSectionHeading(
              number: '01',
              title: 'Vesicle recipe',
              subtitle:
                  'Primary lipid, chip geometry, and supporting components.',
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 9),
            _CompositionPreview(
              cholesterol: _cholesterol,
              peg: _peg,
            ),
            const SizedBox(height: 18),
            const _InputSectionHeading(
              number: '02',
              title: 'Microfluidic process settings',
              subtitle:
                  'Enter total flow rate and aqueous-to-organic flow ratio.',
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 18),
            const _InputSectionHeading(
              number: '03',
              title: 'Model output',
              subtitle:
                  'All supported process endpoints are assessed together.',
            ),
            const SizedBox(height: 10),
            const _ProcessOutputPreview(),
            const SizedBox(height: 9),
            const Text(
              'Zeta potential and entrapment efficiency are outside this process model; screen published formulation evidence in the other workflow. Formation is an uncalibrated score, not a probability.',
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

class _GuideCallout extends StatelessWidget {
  const _GuideCallout({
    required this.title,
    required this.body,
    required this.accent,
  });

  final String title, body;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.tips_and_updates_outlined, color: accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ReferenceLibrary extends StatelessWidget {
  const _ReferenceLibrary();

  static const _references = <(String, String, String)>[
    (
      'USP–NF General Chapter 1154 · Liposome Drug Products',
      'Pharmacopeial product-characterization guidance.',
      'https://doi.org/10.31003/USPNF_M17435_02_01',
    ),
    (
      'Drug Delivery through Liposomes · book chapter',
      'Background on liposome structure and drug association.',
      'https://doi.org/10.5772/intechopen.97727',
    ),
    (
      'Eugster et al. (2024) · microfluidic liposomes',
      'Source cohort for the process model; it does not validate drug loading or tissue delivery.',
      'https://doi.org/10.1016/j.jconrel.2024.10.065',
    ),
    (
      'Bragagni et al. (2012) · topical celecoxib',
      'Comparative study; Batch F reports 54.4% entrapment for that published ethosome.',
      'https://doi.org/10.3109/10717544.2012.724472',
    ),
    (
      'Shahiwala et al. (2023) · donepezil niosomes',
      'Drug- and carrier-specific experimental formulation study.',
      'https://doi.org/10.1208/s12249-023-02547-2',
    ),
    (
      'Ascenso et al. (2015) · skin-delivery vesicles',
      'Transfersome/ethosome experiments with caffeine and vitamin E model actives.',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC4583114/',
    ),
    (
      'Riva et al. (2019) · oral quercetin phytosome',
      'Oral absorption evidence; not a tissue-targeting or release prediction.',
      'https://doi.org/10.1007/s13318-018-0517-3',
    ),
    (
      'Yanes et al. (2025) · release-data methods',
      'Release assay context; values from incompatible assays are not interchangeable.',
      'https://doi.org/10.1016/j.ijpx.2025.100393',
    ),
    (
      'FDA (2018) · Liposome Drug Products guidance',
      'Regulatory context for characterization, manufacturing, and pharmacokinetics.',
      'https://www.fda.gov/regulatory-information/search-fda-guidance-documents/liposome-drug-products-chemistry-manufacturing-and-controls-human-pharmacokinetics-and',
    ),
  ];

  @override
  Widget build(BuildContext context) => ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: EdgeInsets.zero,
        leading: const Icon(Icons.menu_book_outlined, color: _teal),
        title: const Text(
          'Curated references · 9 sources',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        subtitle: const Text(
          'Open the papers and guidance behind this evidence library.',
          style: TextStyle(color: _muted, fontSize: 11),
        ),
        children: [
          for (final reference in _references)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 8, right: 4),
              title: Text(
                reference.$1,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                reference.$2,
                style: const TextStyle(fontSize: 10, height: 1.35),
              ),
              trailing: const Icon(Icons.open_in_new_rounded, size: 16),
              onTap: () => _openUrl(reference.$3),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 2, 8, 10),
            child: Text(
              'A source can be useful context without directly matching your drug, route, tissue, or requested endpoint. Check each result card for its applicability and limitations.',
              style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
            ),
          ),
        ],
      );
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
        .where((item) => item['decision'] == 'model_estimate')
        .length;
    final candidates = reports
        .where((item) => item['decision'] == 'literature_candidate')
        .length;
    final conflicts = reports
        .where((item) => item['decision'] == 'conflicting_evidence')
        .length;
    final unresolved = results.length - estimates - candidates - conflicts;

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
              explanation:
                  'An endpoint with a released model value. Read its units and scope on the result card.',
              icon: Icons.auto_graph_rounded,
              color: _teal,
              fill: const Color(0xFFEAF5F2),
            ),
            _BriefMetric(
              count: candidates,
              label: 'Literature candidates',
              explanation:
                  'A cited study matches the requested drug and route. Its measurements belong to that published experiment, not a new batch.',
              icon: Icons.menu_book_outlined,
              color: const Color(0xFF3A5DAA),
              fill: const Color(0xFFE7F0E6),
            ),
            _BriefMetric(
              count: unresolved,
              label: 'Unresolved',
              explanation:
                  'No direct candidate or released model value answers this endpoint. Background-only, insufficient, and unsupported results are included.',
              icon: Icons.help_outline_rounded,
              color: _muted,
              fill: const Color(0xFFF0F2F6),
            ),
            _BriefMetric(
              count: conflicts,
              label: 'Conflicts to review',
              explanation:
                  'A comparable independent measurement and model result disagree under the release comparison rule. Review the study conditions.',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFF9A5D1B),
              fill: const Color(0xFFFFF2DE),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'The four counts are separate endpoint states. They describe this report, not confidence.',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
        ExpansionTile(
          leading: const Icon(Icons.help_outline_rounded, color: _muted),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 12, right: 4, bottom: 8),
          title: const Text(
            'What do these four counts mean?',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          children: [
            for (final item in const <(String, String, IconData)>[
              (
                'Model estimates',
                'The model released a value for this endpoint. The card shows units, scope, and limits.',
                Icons.auto_graph_rounded,
              ),
              (
                'Literature candidates',
                'A cited study matches the requested drug and route. Its measurements describe the published experiment, not your proposed batch.',
                Icons.menu_book_outlined,
              ),
              (
                'Unresolved',
                'There is no direct candidate or released model value. This includes background-only, insufficient-evidence, and unsupported results.',
                Icons.help_outline_rounded,
              ),
              (
                'Conflicts to review',
                'Comparable model and independent study values disagree under the release review rule. Check the conditions; the flag does not decide which value is correct.',
                Icons.warning_amber_rounded,
              ),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$3, size: 16, color: _muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 17),
        for (final group in const <(String, List<String>)>[
          ('CARRIER & EXCIPIENT EVIDENCE', ['carrier', 'excipients']),
          ('RATIO EVIDENCE', ['ratios']),
          (
            'PARTICLE AND LOADING OUTCOMES',
            ['size', 'pdi', 'entrapment']
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
            onPressed: () => _downloadFormulationPdf(context, data),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download PDF report'),
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
    required this.explanation,
    required this.icon,
    required this.color,
    required this.fill,
  });
  final int count;
  final String label, explanation;
  final IconData icon;
  final Color color, fill;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: explanation,
        child: Container(
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

const _pdfForest = PdfColor(0.082, 0.239, 0.188);
const _pdfSage = PdfColor(0.902, 0.933, 0.898);
const _pdfPaper = PdfColor(0.965, 0.976, 0.957);
const _pdfInk = PdfColor(0.141, 0.208, 0.176);
const _pdfMuted = PdfColor(0.365, 0.427, 0.392);
const _pdfLine = PdfColor(0.835, 0.878, 0.839);

Future<void> _downloadFormulationPdf(
  BuildContext context,
  Map<String, dynamic> data,
) async {
  try {
    final request = Map<String, dynamic>.from(data['request'] as Map? ?? {});
    final results = Map<String, dynamic>.from(data['results'] as Map? ?? {});
    final descriptors =
        Map<String, dynamic>.from(request['descriptors'] as Map? ?? {});
    final release =
        Map<String, dynamic>.from(request['desired_release'] as Map? ?? {});
    final requestId = (data['request_id'] ?? 'report').toString();
    final pdf = pw.Document();

    final requestRows = <List<String>>[
      ['Drug', _pdfSafe(request['drug'])],
      if (_pdfHas(request['drug_form']))
        ['Drug form', _pdfSafe(request['drug_form'])],
      ['Administration route', _pdfSafe(request['route'])],
      ['Target organ or tissue', _pdfSafe(request['tissue'])],
      if (_pdfHas(descriptors['mw_da']))
        ['Molecular weight', '${_pdfSafe(descriptors['mw_da'])} Da'],
      if (_pdfHas(descriptors['logp'])) ['LogP', _pdfSafe(descriptors['logp'])],
      if (_pdfHas(descriptors['pka'])) ['pKa', _pdfSafe(descriptors['pka'])],
      if (_pdfHas(descriptors['solubility_mg_ml']))
        [
          'Solubility',
          '${_pdfSafe(descriptors['solubility_mg_ml'])} mg/mL'
              '${_pdfHas(descriptors['solubility_conditions']) ? ' (${_pdfSafe(descriptors['solubility_conditions'])})' : ''}',
        ],
      if (_pdfHas(descriptors['stability_notes']))
        ['Stability notes', _pdfSafe(descriptors['stability_notes'])],
      if (release.isNotEmpty)
        [
          'User release target',
          '${_pdfSafe(release['percent'])}% at ${_pdfSafe(release['hours'])} hours (user goal, not a prediction)',
        ],
      if (request['targets'] is List)
        ['Requested endpoints', (request['targets'] as List).map(_pdfSafe).join(', ')],
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 42, 38, 42),
        header: (page) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _pdfLine, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('NANOPREDICT LAB  /  NANOVESICLE-AI',
                  style: pw.TextStyle(
                      color: _pdfForest,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text('FORMULATION EVIDENCE REPORT',
                  style: const pw.TextStyle(color: _pdfMuted, fontSize: 7.5)),
            ],
          ),
        ),
        footer: (page) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _pdfLine, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Research use | Request ${_pdfSafe(requestId)}',
                  style: const pw.TextStyle(color: _pdfMuted, fontSize: 7)),
              pw.Text('Page ${page.pageNumber} of ${page.pagesCount}',
                  style: const pw.TextStyle(color: _pdfMuted, fontSize: 7)),
            ],
          ),
        ),
        build: (page) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: _pdfForest,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Evidence-led formulation brief',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(
                    'A cited evidence assessment for ${_pdfSafe(request['drug'])}',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          _pdfSectionTitle('Submitted design context'),
          _pdfKeyValueTable(requestRows),
          pw.SizedBox(height: 15),
          _pdfSectionTitle('Endpoint-by-endpoint assessment'),
          pw.Text(
              'Each endpoint retains its decision, model status, rationale, and applicable evidence. A published measurement belongs to the cited study batch; it is not a prediction for a new formulation.',
              style: const pw.TextStyle(color: _pdfMuted, fontSize: 9, lineSpacing: 2)),
          pw.SizedBox(height: 9),
          for (final entry in results.entries)
            _pdfEndpointCard(entry.key, Map<String, dynamic>.from(entry.value as Map)),
          pw.SizedBox(height: 12),
          _pdfSectionTitle('Method and scientific scope'),
          pw.Text(
              _pdfSafe(data['method'] ?? 'Evidence retrieval and rule-based adjudication.'),
              style: const pw.TextStyle(color: _pdfInk, fontSize: 9, lineSpacing: 2)),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: _pdfPaper,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(7)),
            ),
            child: pw.Text(
                'Research use. Current drug-specific numerical predictions, cross-carrier rankings, excipient-ratio optimization, and generated batches are not validated in this release. Evidence relevance is not a calibrated confidence score. Historical validation errors are cohort benchmarks, not individual prediction intervals.',
                style: const pw.TextStyle(color: _pdfMuted, fontSize: 8.5, lineSpacing: 2)),
          ),
          pw.SizedBox(height: 12),
          _pdfSectionTitle('Release metadata'),
          pw.Text(
              'Request ID: ${_pdfSafe(requestId)}  |  API: ${_pdfSafe(data['api_version'])}  |  Model: ${_pdfSafe(data['model_release'])}  |  Evidence corpus: ${_pdfSafe(data['corpus_release'])}',
              style: const pw.TextStyle(color: _pdfMuted, fontSize: 8)),
        ],
      ),
    );

    final bytes = await pdf.save();
    final objectUrl = html.Url.createObjectUrlFromBlob(
      html.Blob([bytes], 'application/pdf'),
    );
    final safeRequestId = requestId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    html.AnchorElement(href: objectUrl)
      ..download =
          'nanopredict-lab-formulation-${safeRequestId.isEmpty ? 'report' : safeRequestId}.pdf'
      ..click();
    Future<void>.delayed(
        const Duration(seconds: 2), () => html.Url.revokeObjectUrl(objectUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF report generated. Your download is starting.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the PDF report. Please try again.')),
      );
    }
  }
}

pw.Widget _pdfSectionTitle(String title) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Text(title,
          style: pw.TextStyle(
              color: _pdfForest, fontSize: 12, fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _pdfKeyValueTable(List<List<String>> rows) => pw.Table(
      border: pw.TableBorder.all(color: _pdfLine, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.31),
        1: pw.FlexColumnWidth(0.69),
      },
      children: [
        for (var i = 0; i < rows.length; i++)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: i.isEven ? _pdfPaper : PdfColors.white),
            children: [
              _pdfTableCell(rows[i][0], bold: true),
              _pdfTableCell(rows[i][1]),
            ],
          ),
      ],
    );

pw.Widget _pdfTableCell(String value, {bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(value,
          style: pw.TextStyle(
              color: bold ? _pdfForest : _pdfInk,
              fontSize: 8.5,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );

pw.Widget _pdfEndpointCard(String name, Map<String, dynamic> report) {
  final model = Map<String, dynamic>.from(report['model'] as Map? ?? {});
  final evidence = report['evidence'] is List
      ? (report['evidence'] as List).whereType<Map>().toList()
      : const <Map>[];
  final decision = _pdfDecisionLabel(report['decision']);
  final modelValue = model['value'];
  final benchmark = model['benchmark'] is List
      ? (model['benchmark'] as List).whereType<Map>().toList()
      : const <Map>[];

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 9),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      border: pw.Border.all(color: _pdfLine, width: 0.7),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(_pdfHumanize(name),
                  style: pw.TextStyle(
                      color: _pdfForest,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: const pw.BoxDecoration(
                color: _pdfSage,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(decision,
                  style: pw.TextStyle(
                      color: _pdfForest,
                      fontSize: 7.5,
                      fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text(_pdfSafe(report['rationale']),
            style: const pw.TextStyle(color: _pdfInk, fontSize: 8.5, lineSpacing: 1.5)),
        pw.SizedBox(height: 5),
        if (modelValue != null)
          pw.Text(
              'Model estimate: ${_pdfSafe(modelValue)} ${_pdfSafe(model['unit'])}',
              style: pw.TextStyle(
                  color: _pdfForest,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold))
        else ...[
          pw.Text('Model status: ${_pdfHumanize(_pdfSafe(model['status']))}',
              style: pw.TextStyle(
                  color: _pdfForest,
                  fontSize: 8.2,
                  fontWeight: pw.FontWeight.bold)),
          if (_pdfHas(model['reason']))
            pw.Text(_pdfSafe(model['reason']),
                style: const pw.TextStyle(color: _pdfMuted, fontSize: 8, lineSpacing: 1.5)),
        ],
        if (_pdfHas(model['support']))
          pw.Text('Support: ${_pdfSafe(model['support'])}',
              style: const pw.TextStyle(color: _pdfMuted, fontSize: 8)),
        if (_pdfHas(model['grouped_cv_mae']))
          pw.Text(
              'Grouped-CV MAE: ${_pdfSafe(model['grouped_cv_mae'])} ${_pdfSafe(model['unit'])}; cohort benchmark, not an individual prediction interval.',
              style: const pw.TextStyle(color: _pdfMuted, fontSize: 8)),
        if (_pdfHas(model['limitation']))
          pw.Text(_pdfSafe(model['limitation']),
              style: const pw.TextStyle(color: _pdfMuted, fontSize: 8, lineSpacing: 1.5)),
        if (benchmark.isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Text('Validation benchmarks (not predictions)',
              style: pw.TextStyle(
                  color: _pdfForest,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold)),
          for (final row in benchmark)
            pw.Text(
                '${_pdfHumanize(_pdfSafe(row['grouping']))}: MAE ${_pdfSafe(row['mae'])} vs median ${_pdfSafe(row['median_mae'])}; n=${_pdfSafe(row['n'])}',
                style: const pw.TextStyle(color: _pdfMuted, fontSize: 7.5)),
        ],
        if (evidence.isNotEmpty) ...[
          pw.SizedBox(height: 7),
          pw.Text('Cited evidence',
              style: pw.TextStyle(
                  color: _pdfForest,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold)),
          for (final source in evidence)
            _pdfEvidenceCard(name, Map<String, dynamic>.from(source)),
        ] else
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5),
            child: pw.Text('No applicable source was returned for this endpoint.',
                style: const pw.TextStyle(color: _pdfMuted, fontSize: 8)),
          ),
      ],
    ),
  );
}

pw.Widget _pdfEvidenceCard(String endpoint, Map<String, dynamic> source) {
  final title = _pdfSafe(source['title']);
  final url = _pdfSafe(source['url']);
  final measurements =
      Map<String, dynamic>.from(source['measurements'] as Map? ?? {});
  final measurement =
      Map<String, dynamic>.from(measurements[endpoint] as Map? ?? {});
  final locator = _pdfSafe(source['locator']);
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(top: 5),
    padding: const pw.EdgeInsets.all(7),
    decoration: const pw.BoxDecoration(
      color: _pdfPaper,
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                color: _pdfInk, fontSize: 8, fontWeight: pw.FontWeight.bold)),
        if (url.startsWith('http'))
          pw.UrlLink(
            destination: url,
            child: pw.Text(url,
                style: const pw.TextStyle(color: _pdfForest, fontSize: 7.5)),
          ),
        pw.Text(
            'Source: ${_pdfHumanize(_pdfSafe(source['kind']))} | Applicability: ${_pdfHumanize(_pdfSafe(source['applicability']))}',
            style: const pw.TextStyle(color: _pdfMuted, fontSize: 7.3)),
        if (_pdfHas(source['text']))
          pw.Text(_pdfSafe(source['text']),
              style: const pw.TextStyle(color: _pdfInk, fontSize: 7.8, lineSpacing: 1.2)),
        if (measurement.isNotEmpty)
          pw.Text(
              'Published observation: ${_pdfSafe(measurement['value'])} ${_pdfSafe(measurement['unit'])}${locator.isEmpty ? '' : ' | $locator'}',
              style: pw.TextStyle(
                  color: _pdfForest,
                  fontSize: 7.8,
                  fontWeight: pw.FontWeight.bold)),
        if (locator.isNotEmpty && measurement.isEmpty)
          pw.Text('Citation locator: $locator',
              style: const pw.TextStyle(color: _pdfMuted, fontSize: 7.3)),
        if (_pdfHas(source['limitation']))
          pw.Text('Limitation: ${_pdfSafe(source['limitation'])}',
              style: const pw.TextStyle(color: _pdfMuted, fontSize: 7.3, lineSpacing: 1.2)),
      ],
    ),
  );
}

bool _pdfHas(dynamic value) => value != null && value.toString().trim().isNotEmpty;

String _pdfSafe(dynamic value) {
  if (value == null) return 'not provided';
  return value
      .toString()
      .replaceAll('\u2013', '-')
      .replaceAll('\u2014', '-')
      .replaceAll('\u2212', '-')
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('\u201c', '"')
      .replaceAll('\u201d', '"')
      .replaceAll('\u2022', '-')
      .replaceAll('\u00b5', 'micro')
      .replaceAll('\u00d7', 'x');
}

String _pdfHumanize(String value) {
  if (value.isEmpty) return 'Assessment report';
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _pdfDecisionLabel(dynamic value) => switch (value) {
      'model_estimate' => 'MODEL ESTIMATE',
      'literature_candidate' => 'LITERATURE CANDIDATE',
      'conflicting_evidence' => 'REVIEW CONFLICT',
      'background_only' => 'BACKGROUND ONLY',
      _ => _pdfHumanize(_pdfSafe(value)).toUpperCase(),
    };

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
                'For research use. Evidence relevance is not a calibrated confidence score. Drug-loaded estimates, cross-carrier rankings, ratio optimization, and tissue delivery predictions are not available in this release.',
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
