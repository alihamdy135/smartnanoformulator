part of 'main.dart';

const _nav = Color(0xFF111C33);
const _navMuted = Color(0xFFAAB7D1);

enum _WorkspaceSection { overview, formulation, process }

extension on _WorkspaceSection {
  String get title => switch (this) {
        _WorkspaceSection.overview => 'Overview',
        _WorkspaceSection.formulation => 'Formulation evidence',
        _WorkspaceSection.process => 'Microfluidic process',
      };
  IconData get icon => switch (this) {
        _WorkspaceSection.overview => Icons.space_dashboard_outlined,
        _WorkspaceSection.formulation => Icons.biotech_outlined,
        _WorkspaceSection.process => Icons.hub_outlined,
      };
  String get description => switch (this) {
        _WorkspaceSection.overview =>
          'Evaluate formulation evidence and benchmark microfluidic liposome processes in one workspace.',
        _WorkspaceSection.formulation =>
          'Build a drug delivery brief and review cited evidence, model scope, and unresolved outcomes.',
        _WorkspaceSection.process =>
          'Check formation, particle size, and PDI for settings covered by the Eugster cohort.',
      };
}

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();
  _WorkspaceSection _section = _WorkspaceSection.overview;
  String? _example;
  int _formulationVersion = 0, _processVersion = 0;

  void _select(_WorkspaceSection section, {String? example}) {
    if (_scaffold.currentState?.isDrawerOpen ?? false) {
      _scaffold.currentState?.closeDrawer();
    }
    if (section == _section && example == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _section = section;
      if (example != null && section == _WorkspaceSection.formulation) {
        _example = example;
        _formulationVersion++;
      }
      if (example != null && section == _WorkspaceSection.process) {
        _processVersion++;
      }
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 950;
    final sidebar = _Navigation(
      selected: _section,
      onSelect: _select,
    );
    return Scaffold(
      key: _scaffold,
      drawer: desktop ? null : Drawer(backgroundColor: _nav, child: sidebar),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop) SizedBox(width: 224, child: sidebar),
            Expanded(
              child: Column(
                children: [
                  _ConsoleTop(
                    section: _section,
                    onMenu: desktop
                        ? null
                        : () => _scaffold.currentState?.openDrawer(),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _scroll,
                      child: SingleChildScrollView(
                        controller: _scroll,
                        padding: EdgeInsets.all(desktop ? 28 : 16),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _WorkspaceHeading(section: _section),
                                const SizedBox(height: 22),
                                if (_section == _WorkspaceSection.overview)
                                  _Overview(onSelect: _select),
                                // Keep assessments mounted when navigating so inputs
                                // and completed reports are available on return.
                                Visibility(
                                  visible:
                                      _section == _WorkspaceSection.formulation,
                                  maintainState: true,
                                  child: FormulationFlow(
                                    key: ValueKey(_formulationVersion),
                                    initialExample: _example,
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      _section == _WorkspaceSection.process,
                                  maintainState: true,
                                  child: ProcessFlow(
                                    key: ValueKey(_processVersion),
                                    useExample: _processVersion > 0,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const _ScopeFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.selected, required this.onSelect});
  final _WorkspaceSection selected;
  final ValueChanged<_WorkspaceSection> onSelect;

  @override
  Widget build(BuildContext context) => Material(
        color: _nav,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(5, 4, 2, 26),
                child: Row(
                  children: [
                    _IconTile(
                        icon: Icons.blur_on_rounded,
                        foreground: Colors.white,
                        background: Color(0xFF335DE0)),
                    SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NanoPredict Lab',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          Text('RESEARCH WORKSPACE',
                              style: TextStyle(
                                  color: _navMuted,
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _NavLabel('WORKSPACE'),
              for (final section in _WorkspaceSection.values.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Semantics(
                    selected: selected == section,
                    child: ListTile(
                      onTap: () => onSelect(section),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      dense: true,
                      minVerticalPadding: 8,
                      horizontalTitleGap: 9,
                      minLeadingWidth: 20,
                      selected: selected == section,
                      selectedTileColor: const Color(0xFF263D72),
                      selectedColor: Colors.white,
                      iconColor: _navMuted,
                      textColor: _navMuted,
                      leading: Icon(section.icon, size: 19),
                      title: Text(section.title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      trailing: selected == section
                          ? const Icon(Icons.circle,
                              color: Color(0xFF91ADFF), size: 7)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _NavLabel extends StatelessWidget {
  const _NavLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 8),
        child: Text(text,
            style: const TextStyle(
                color: _navMuted,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800)),
      );
}

class _ConsoleTop extends StatelessWidget {
  const _ConsoleTop({required this.section, this.onMenu});
  final _WorkspaceSection section;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: const BoxDecoration(
            color: _surface, border: Border(bottom: BorderSide(color: _line))),
        padding: EdgeInsets.symmetric(horizontal: onMenu == null ? 28 : 9),
        child: Row(
          children: [
            if (onMenu != null)
              IconButton(
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: 'Open navigation'),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Text('Workspace',
                      style: TextStyle(color: _muted, fontSize: 13)),
                  const Icon(Icons.chevron_right, size: 15, color: _muted),
                  Text(section.title,
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            if (MediaQuery.sizeOf(context).width >= 440)
              const _Pill(
                  label: 'RESEARCH PROTOTYPE',
                  color: Color(0xFFEAF0FF),
                  textColor: _teal),
          ],
        ),
      );
}

class _WorkspaceHeading extends StatelessWidget {
  const _WorkspaceHeading({required this.section});
  final _WorkspaceSection section;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(section == _WorkspaceSection.overview
              ? 'RESEARCH CONSOLE'
              : 'NANOPREDICT LAB WORKSPACE'),
          const SizedBox(height: 7),
          Semantics(
            header: true,
            child: Text(
              section == _WorkspaceSection.overview
                  ? 'Research overview'
                  : section.title,
              style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).width >= 950 ? 37 : 29,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -1,
                  height: 1.1),
            ),
          ),
          const SizedBox(height: 8),
          Text(section.description,
              style: const TextStyle(color: _muted, fontSize: 14, height: 1.5)),
        ],
      );
}

class _IconTile extends StatelessWidget {
  const _IconTile(
      {required this.icon, required this.foreground, required this.background});
  final IconData icon;
  final Color foreground, background;

  @override
  Widget build(BuildContext context) => Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: foreground, size: 23),
      );
}

typedef _SectionSelect = void Function(_WorkspaceSection section,
    {String? example});

class _Overview extends StatelessWidget {
  const _Overview({required this.onSelect});
  final _SectionSelect onSelect;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('START AN ASSESSMENT'),
                const SizedBox(height: 6),
                const Text('Choose a workflow',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                _FieldGroup(
                  children: [
                    _LaunchCard(
                      section: _WorkspaceSection.formulation,
                      tag: 'LITERATURE SCREENING',
                      onOpen: () => onSelect(_WorkspaceSection.formulation),
                    ),
                    _LaunchCard(
                      section: _WorkspaceSection.process,
                      tag: 'EUGSTER COHORT',
                      onOpen: () => onSelect(_WorkspaceSection.process),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('REFERENCE CASES'),
                const SizedBox(height: 6),
                const Text('Explore a prepared example',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 13),
                _ExampleRow(
                  icon: Icons.science_outlined,
                  title: 'Topical celecoxib',
                  detail:
                      'Published Batch F entrapment and an unresolved release target',
                  onTap: () => onSelect(_WorkspaceSection.formulation,
                      example: 'celecoxib'),
                ),
                _ExampleRow(
                  icon: Icons.search_off_rounded,
                  title: 'Intranasal quercetin',
                  detail:
                      'A case with insufficient evidence for the requested endpoints',
                  onTap: () =>
                      onSelect(_WorkspaceSection.formulation, example: 'gap'),
                ),
                _ExampleRow(
                  icon: Icons.hub_outlined,
                  title: 'DMPC / ZZ process',
                  detail: 'A reference example within the Eugster cohort',
                  onTap: () =>
                      onSelect(_WorkspaceSection.process, example: 'process'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _EvidenceLandscape(),
        ],
      );
}

class _EvidenceLandscape extends StatelessWidget {
  const _EvidenceLandscape();

  @override
  Widget build(BuildContext context) => _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('DATA & VALIDATION SNAPSHOT'),
            const SizedBox(height: 6),
            const Text('What the prototype can support',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            const Text(
              'The full catalogue spans several carrier types; numerical validation is narrower and applies only to the screened Eugster microfluidic liposome cohort.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _ScopeMetric(value: '2,641', label: 'catalogue records'),
                _ScopeMetric(value: '5', label: 'carrier families'),
                _ScopeMetric(value: '928', label: 'screened Eugster runs'),
              ],
            ),
            const SizedBox(height: 16),
            const _MaeComparison(
              title: 'Particle size · grouped CV MAE',
              unit: 'nm',
              baseline: 46.35,
              model: 17.42,
              baselineText: '46.35',
              modelText: '17.42',
            ),
            const SizedBox(height: 15),
            const _MaeComparison(
              title: 'PDI · grouped CV MAE',
              unit: 'unitless',
              baseline: 0.0518,
              model: 0.0376,
              baselineText: '0.0518',
              modelText: '0.0376',
            ),
            const SizedBox(height: 9),
            const _InlineNote(
              text:
                  'Cohort-level retrospective errors are benchmarks, not uncertainty ranges for a new recipe. Drug-loaded models did not beat median baselines; the merged catalogue is not a live cross-carrier predictor.',
            ),
          ],
        ),
      );
}

class _ScopeMetric extends StatelessWidget {
  const _ScopeMetric({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 132),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: _teal, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    color: _muted, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _MaeComparison extends StatelessWidget {
  const _MaeComparison({
    required this.title,
    required this.unit,
    required this.baseline,
    required this.model,
    required this.baselineText,
    required this.modelText,
  });
  final String title, unit, baselineText, modelText;
  final double baseline, model;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _ink, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Row(
            children: [
              const _ChartLegend(
                  color: Color(0xFFB6C0D0), label: 'Median baseline'),
              const SizedBox(width: 12),
              const _ChartLegend(color: _teal, label: 'Fitted model'),
              const Spacer(),
              Text(unit, style: const TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 7),
          _BarLine(
              label: 'Baseline',
              value: baselineText,
              fill: 1,
              color: const Color(0xFFB6C0D0)),
          const SizedBox(height: 5),
          _BarLine(
              label: 'Model',
              value: modelText,
              fill: model / baseline,
              color: _teal),
        ],
      );
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});
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
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: _muted, fontSize: 9)),
        ],
      );
}

class _BarLine extends StatelessWidget {
  const _BarLine(
      {required this.label,
      required this.value,
      required this.fill,
      required this.color});
  final String label, value;
  final double fill;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
              width: 56,
              child: Text(label,
                  style: const TextStyle(color: _muted, fontSize: 10))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 8,
                backgroundColor: const Color(0xFFF0F2F6),
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: _ink, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      );
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard(
      {required this.section, required this.tag, required this.onOpen});
  final _WorkspaceSection section;
  final String tag;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final process = section == _WorkspaceSection.process;
    final accent = process ? _indigo : _teal;
    final tint = process ? const Color(0xFFF0EBFA) : const Color(0xFFEAF0FF);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconTile(icon: section.icon, foreground: accent, background: tint),
            const SizedBox(height: 11),
            _Pill(label: tag, color: tint, textColor: accent),
            const SizedBox(height: 8),
            Text(section.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 5),
            Text(section.description,
                style:
                    const TextStyle(color: _muted, fontSize: 13, height: 1.45)),
            const SizedBox(height: 11),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onOpen,
              child: Text(process
                  ? 'Open process assessment'
                  : 'Open evidence screening'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow(
      {required this.icon,
      required this.title,
      required this.detail,
      required this.onTap});
  final IconData icon;
  final String title, detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Divider(height: 1, color: _line),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            leading: Icon(icon, color: _teal, size: 21),
            title: Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text(detail,
                style: const TextStyle(color: _muted, fontSize: 13)),
            trailing:
                const Icon(Icons.arrow_forward_rounded, size: 18, color: _teal),
            onTap: onTap,
          ),
        ],
      );
}
