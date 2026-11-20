import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';

const _apiBase = String.fromEnvironment(
  'NANOPREDICT_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

const _ink = Color(0xFF152B36);
const _muted = Color(0xFF61737B);
const _teal = Color(0xFF117C78);
const _line = Color(0xFFE1E8E9);
const _surface = Color(0xFFFFFFFF);
const _soft = Color(0xFFF2F6F6);

void main() => runApp(const SmartNanoFormulatorApp());

class SmartNanoFormulatorApp extends StatelessWidget {
  const SmartNanoFormulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _teal,
      brightness: Brightness.light,
      surface: _surface,
    );
    return MaterialApp(
      title: 'SmartNanoFormulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
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
          fillColor: const Color(0xFFFBFCFC),
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

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  int _activeFlow = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onDocs: () => _openUrl('$_apiBase/docs')),
            Expanded(
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final wide = bounds.maxWidth >= 980;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 32 : 18,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _IntroHeader(),
                            const SizedBox(height: 24),
                            _FlowPicker(
                              selected: _activeFlow,
                              onSelected: (value) =>
                                  setState(() => _activeFlow = value),
                            ),
                            const SizedBox(height: 20),
                            IndexedStack(
                              index: _activeFlow,
                              children: const [
                                FormulationFlow(),
                                ProcessFlow(),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const _ScopeFooter(),
                          ],
                        ),
                      ),
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onDocs});
  final VoidCallback onDocs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F3F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: _teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SmartNanoFormulator',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'EVIDENCE WORKSPACE',
                    style: TextStyle(
                      color: _muted,
                      letterSpacing: 1.15,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const _Pill(
                label: 'RESEARCH PROTOTYPE',
                color: Color(0xFFEDF5F3),
                textColor: _teal,
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Open API documentation',
                onPressed: onDocs,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroHeader extends StatelessWidget {
  const _IntroHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final compact = bounds.maxWidth < 700;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evidence first. Estimates in scope.',
              style: TextStyle(
                color: _ink,
                fontSize: 30,
                height: 1.12,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.9,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Screen formulation literature or assess a microfluidic liposome process against its documented cohort.',
              style: TextStyle(color: _muted, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(
                  label: 'CITED EVIDENCE',
                  color: Colors.white,
                  textColor: _muted,
                  icon: Icons.link_rounded,
                ),
                _Pill(
                  label: 'SCIENTIFIC ABSTENTION',
                  color: Colors.white,
                  textColor: _muted,
                  icon: Icons.pause_circle_outline_rounded,
                ),
                _Pill(
                  label: 'EUGSTER PROCESS SCOPE',
                  color: Colors.white,
                  textColor: _muted,
                  icon: Icons.tune_rounded,
                ),
              ],
            ),
          ],
        );
        if (compact) return content;
        return Row(
          children: [
            Expanded(child: content),
            const SizedBox(width: 30),
            const _StatusNote(),
          ],
        );
      },
    );
  }
}

class _StatusNote extends StatelessWidget {
  const _StatusNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 275,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4E7E4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 17, color: _teal),
              SizedBox(width: 8),
              Text(
                'HOW TO READ RESULTS',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                  color: _teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Model estimate, published observation, and your target stay separate.',
            style: TextStyle(fontSize: 13, height: 1.5, color: _ink),
          ),
        ],
      ),
    );
  }
}

class _FlowPicker extends StatelessWidget {
  const _FlowPicker({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: 0,
          icon: Icon(Icons.biotech_outlined),
          label: Text('Formulation evidence'),
        ),
        ButtonSegment(
          value: 1,
          icon: Icon(Icons.water_drop_outlined),
          label: Text('Microfluidic process'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onSelected(values.first),
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class FormulationFlow extends StatefulWidget {
  const FormulationFlow({super.key});

  @override
  State<FormulationFlow> createState() => _FormulationFlowState();
}

class _FormulationFlowState extends State<FormulationFlow> {
  final _formKey = GlobalKey<FormState>();
  final _drug = TextEditingController(text: 'celecoxib');
  final _drugForm = TextEditingController();
  final _route = TextEditingController(text: 'topical');
  final _tissue = TextEditingController(text: 'skin');
  final _assay = TextEditingController();
  final _hours = TextEditingController(text: '24');
  final _percent = TextEditingController(text: '65');
  final _mw = TextEditingController();
  final _logp = TextEditingController();
  final _pka = TextEditingController();
  final _solubility = TextEditingController();
  final _solubilityConditions = TextEditingController();
  final _stability = TextEditingController();
  final Set<String> _targets = {
    'carrier',
    'excipients',
    'entrapment',
    'release',
  };
  String? _carrier;
  bool _advanced = false;
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  static const _allTargets = [
    ('carrier', 'Carrier'),
    ('excipients', 'Excipients'),
    ('ratios', 'Ratios'),
    ('batches', 'Batches'),
    ('size', 'Size'),
    ('pdi', 'PDI'),
    ('zeta', 'Zeta'),
    ('entrapment', 'Entrapment'),
    ('release', 'Release'),
    ('tissue', 'Tissue'),
    ('stability', 'Stability'),
    ('bioavailability', 'Bioavailability'),
  ];

  @override
  void dispose() {
    for (final controller in [
      _drug,
      _drugForm,
      _route,
      _tissue,
      _assay,
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

  String? _percentValidator(String? value) {
    final error = _optionalNumber(value);
    if (error != null) return error;
    if (value == null || value.trim().isEmpty)
      return 'Enter a percentage target.';
    final parsed = double.parse(value.trim());
    if (parsed < 0 || parsed > 100) return 'Use a value from 0 to 100.';
    return null;
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    if (_targets.isEmpty) {
      setState(() => _error = 'Select at least one output to assess.');
      return;
    }
    final payload = <String, dynamic>{
      'drug': _drug.text.trim(),
      'route': _route.text.trim(),
      'tissue': _tissue.text.trim(),
      'targets': _allTargets
          .where((item) => _targets.contains(item.$1))
          .map((item) => item.$1)
          .toList(),
    };
    if (_drugForm.text.trim().isNotEmpty)
      payload['drug_form'] = _drugForm.text.trim();
    if (_assay.text.trim().isNotEmpty) payload['assay'] = _assay.text.trim();
    if (_carrier != null) payload['carrier'] = _carrier;
    if (_targets.contains('release')) {
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

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _postJson('/v1/formulation-assessments', payload);
      if (mounted) setState(() => _result = response);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.describe());
    } catch (error) {
      if (mounted)
        setState(
          () => _error =
              'Could not reach the assessment API. Check the connection and try again. $error',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final wide = bounds.maxWidth >= 980;
        final form = _formCard();
        final output = AssessmentPanel(
          result: _result,
          error: _error,
          loading: _loading,
          onRetry: _submit,
          emptyTitle: 'Your evidence review will appear here',
          emptyHint:
              'Enter the drug, route, tissue, and endpoints you want to screen.',
        );
        if (wide)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: form),
              const SizedBox(width: 18),
              Expanded(flex: 6, child: output),
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
              eyebrow: 'FORMULATION SCREEN',
              title: 'Define the research question',
              icon: Icons.biotech_outlined,
            ),
            const SizedBox(height: 20),
            _field(_drug, 'Drug', required: true, hint: 'e.g. celecoxib'),
            const SizedBox(height: 13),
            _field(
              _drugForm,
              'Drug form',
              hint: 'Optional · salt, hydrate, polymorph',
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _route,
                    'Administration route',
                    required: true,
                    hint: 'e.g. topical',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _tissue,
                    'Target tissue',
                    required: true,
                    hint: 'e.g. skin',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            DropdownButtonFormField<String?>(
              value: _carrier,
              decoration: const InputDecoration(
                labelText: 'Carrier filter',
                helperText:
                    'Leave as any carrier to search across the supplied corpus.',
              ),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Any carrier'),
                ),
                DropdownMenuItem<String?>(
                  value: 'liposome',
                  child: Text('Liposome'),
                ),
                DropdownMenuItem<String?>(
                  value: 'niosome',
                  child: Text('Niosome'),
                ),
                DropdownMenuItem<String?>(
                  value: 'transfersome',
                  child: Text('Transfersome'),
                ),
                DropdownMenuItem<String?>(
                  value: 'ethosome',
                  child: Text('Ethosome'),
                ),
                DropdownMenuItem<String?>(
                  value: 'phytosome',
                  child: Text('Phytosome'),
                ),
              ],
              onChanged: (value) => setState(() => _carrier = value),
            ),
            const SizedBox(height: 18),
            const _SectionLabel('OUTPUTS TO SCREEN'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _allTargets
                  .map(
                    (entry) => FilterChip(
                      label: Text(entry.$2),
                      selected: _targets.contains(entry.$1),
                      onSelected: (selected) => setState(() {
                        selected
                            ? _targets.add(entry.$1)
                            : _targets.remove(entry.$1);
                      }),
                      showCheckmark: true,
                      side: BorderSide(
                        color: _targets.contains(entry.$1)
                            ? const Color(0xFFADD7D2)
                            : _line,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFE7F4F1),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _targets.contains(entry.$1) ? _teal : _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (_targets.contains('release')) ...[
              const SizedBox(height: 15),
              const _SectionLabel('YOUR RELEASE TARGET'),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _percent,
                      'Target release',
                      suffix: '%',
                      validator: _percentValidator,
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _hours,
                      'At time',
                      suffix: 'hours',
                      validator: (value) {
                        final error = _optionalNumber(value, positive: true);
                        if (error != null) return error;
                        if (value == null || value.trim().isEmpty)
                          return 'Enter a time.';
                        return null;
                      },
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                'This is your design target. It is not a measured or predicted release value.',
                style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),
            _field(
              _assay,
              'Assay context',
              hint: 'Optional · specify method or medium',
            ),
            const SizedBox(height: 8),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                initiallyExpanded: _advanced,
                onExpansionChanged: (value) =>
                    setState(() => _advanced = value),
                title: const Text(
                  'Optional physicochemical descriptors',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text(
                  'Echoed as context · not used for numerical drug estimates',
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _mw,
                          'Molecular weight',
                          suffix: 'Da',
                          validator: (v) => _optionalNumber(v, positive: true),
                          keyboard: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          _logp,
                          'LogP',
                          validator: _optionalNumber,
                          keyboard: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          _pka,
                          'pKa',
                          validator: _optionalNumber,
                          keyboard: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _field(
                    _solubility,
                    'Solubility',
                    suffix: 'mg/mL',
                    validator: (v) => _optionalNumber(v, nonNegative: true),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _field(
                    _solubilityConditions,
                    'Solubility conditions',
                    hint: 'Optional · medium, pH, temperature',
                  ),
                  const SizedBox(height: 10),
                  _field(
                    _stability,
                    'Stability notes',
                    hint: 'Optional',
                    maxLines: 2,
                  ),
                ],
              ),
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.manage_search_rounded, size: 19),
                label: Text(
                  _loading ? 'Reviewing evidence…' : 'Run evidence screen',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
    bool required = false,
    String? hint,
    String? suffix,
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ),
      validator:
          validator ??
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
  const ProcessFlow({super.key});

  @override
  State<ProcessFlow> createState() => _ProcessFlowState();
}

class _ProcessFlowState extends State<ProcessFlow> {
  final _formKey = GlobalKey<FormState>();
  final _lipid = TextEditingController(text: 'DMPC');
  final _chip = TextEditingController(text: 'ZZ');
  final _cholesterol = TextEditingController(text: '40');
  final _peg = TextEditingController(text: '5');
  final _flow = TextEditingController(text: '8');
  final _ratio = TextEditingController(text: '1');
  final _assay = TextEditingController();
  final Set<String> _targets = {'size', 'pdi', 'formation'};
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

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
      setState(() => _error = 'Select at least one process output.');
      return;
    }
    if (double.parse(_cholesterol.text) + double.parse(_peg.text) > 100) {
      setState(
        () => _error =
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _postJson('/v1/process-assessments', payload);
      if (mounted) setState(() => _result = response);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.describe());
    } catch (error) {
      if (mounted)
        setState(
          () => _error =
              'Could not reach the assessment API. Check the connection and try again. $error',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final wide = bounds.maxWidth >= 980;
        final form = _formCard();
        final output = AssessmentPanel(
          result: _result,
          error: _error,
          loading: _loading,
          onRetry: _submit,
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
              Expanded(flex: 6, child: output),
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
              title: 'Set liposome process inputs',
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 11),
            const Text(
              'Model scope is limited to supported lipid and chip pairings and observed process ranges.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
            const SizedBox(height: 19),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _lipid,
                    'Primary lipid',
                    hint: 'e.g. DMPC',
                    required: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_chip, 'Chip', hint: 'e.g. ZZ', required: true),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _cholesterol,
                    'Cholesterol',
                    suffix: '%',
                    validator: (v) => _numberValidator(v, percentage: true),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _peg,
                    'PEG',
                    suffix: '%',
                    validator: (v) => _numberValidator(v, percentage: true),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
            Row(
              children: [
                Expanded(
                  child: _field(
                    _flow,
                    'Total flow rate',
                    suffix: 'mL/min',
                    validator: (v) => _numberValidator(v, positive: true),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _ratio,
                    'Aqueous : organic',
                    suffix: 'FRR',
                    validator: (v) => _numberValidator(v, positive: true),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
              children:
                  [
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
                                ? const Color(0xFFADD7D2)
                                : _line,
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFFE7F4F1),
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
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ),
      validator:
          validator ??
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
    required this.emptyTitle,
    required this.emptyHint,
  });
  final Map<String, dynamic>? result;
  final String? error;
  final bool loading;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
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
                key: const ValueKey('empty'),
                title: emptyTitle,
                hint: emptyHint,
              )
            : _ResultView(key: const ValueKey('result'), data: result!),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final results = Map<String, dynamic>.from(data['results'] as Map? ?? {});
    final request = Map<String, dynamic>.from(data['request'] as Map? ?? {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: _CardHeading(
                eyebrow: 'ASSESSMENT REPORT',
                title: 'Endpoint results',
                icon: Icons.fact_check_outlined,
              ),
            ),
            _Pill(
              label: 'API ${data['api_version'] ?? '—'}',
              color: const Color(0xFFF0F3F4),
              textColor: _muted,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SubmittedContext(request: request),
        const SizedBox(height: 16),
        for (final entry in results.entries) ...[
          _EndpointCard(
            name: entry.key,
            report: Map<String, dynamic>.from(entry.value as Map),
          ),
          const SizedBox(height: 11),
        ],
        const SizedBox(height: 5),
        Text(
          'Request ${data['request_id'] ?? '—'}',
          style: const TextStyle(fontSize: 10, color: _muted),
        ),
        const SizedBox(height: 5),
        Text(
          'Model ${data['model_release'] ?? '—'}  ·  Corpus ${data['corpus_release'] ?? '—'}',
          style: const TextStyle(fontSize: 10, color: _muted),
        ),
        const SizedBox(height: 9),
        Text(
          '${data['method'] ?? ''}',
          style: const TextStyle(fontSize: 11, color: _muted, height: 1.45),
        ),
      ],
    );
  }
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
          if (desired.isNotEmpty) ...[
            const SizedBox(height: 7),
            Row(
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
  const _EndpointCard({required this.name, required this.report});
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _titleCase(name),
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              _Pill(
                label: label,
                color: background,
                textColor: color,
                icon: icon,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${report['rationale'] ?? ''}',
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          _ModelReport(model: model, endpoint: name),
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 11),
            const Divider(height: 1, color: _line),
            const SizedBox(height: 10),
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
              style: const TextStyle(color: _muted, fontSize: 10, height: 1.4),
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
                    fontSize: 12,
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
            style: const TextStyle(color: _ink, fontSize: 11, height: 1.45),
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
            style: const TextStyle(color: _muted, fontSize: 10, height: 1.4),
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
  const _EmptyState({super.key, required this.title, required this.hint});
  final String title;
  final String hint;
  @override
  Widget build(BuildContext context) => _StateMessage(
    icon: Icons.notes_rounded,
    color: _teal,
    title: title,
    body: hint,
    footer: const _Pill(
      label: 'READY FOR INPUT',
      color: Color(0xFFEFF5F5),
      textColor: _teal,
    ),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 300,
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
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
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
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
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

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _line),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080B2531),
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
  });
  final String eyebrow;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4F2),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: _teal, size: 19),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: _teal,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w700,
                fontSize: 17,
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
      fontSize: 9,
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
            fontSize: 8.5,
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
      style: const TextStyle(color: _muted, fontSize: 10, height: 1.4),
    ),
  );
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
  if (Uri.tryParse(url)?.hasScheme ?? false)
    html.window.open(url, '_blank', 'noopener,noreferrer');
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
        _teal,
        const Color(0xFFE8F4F1),
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
