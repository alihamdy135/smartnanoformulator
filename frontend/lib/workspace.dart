part of 'main.dart';

const _nav = Color(0xFF111C33);
const _navMuted = Color(0xFFAAB7D1);

enum _WorkspaceSection { overview, formulation, process }

extension on _WorkspaceSection {
  String get title => switch (this) {
        _WorkspaceSection.overview => 'Overview',
        _WorkspaceSection.formulation => 'Evidence-led designer',
        _WorkspaceSection.process => 'Process model',
      };
  IconData get icon => switch (this) {
        _WorkspaceSection.overview => Icons.space_dashboard_outlined,
        _WorkspaceSection.formulation => Icons.biotech_outlined,
        _WorkspaceSection.process => Icons.hub_outlined,
      };
  String get description => switch (this) {
        _WorkspaceSection.overview =>
          'Intelligent nanopharmaceutical formulation design, grounded in cited evidence and model scope.',
        _WorkspaceSection.formulation =>
          'Describe the drug profile, route, tissue, and release target. Review cited candidates and evidence gaps.',
        _WorkspaceSection.process =>
          'Use the fitted Eugster models for particle size and PDI within supported microfluidic liposome settings.',
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
              child: Container(
                color: const Color(0xFFF3F5FB),
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
                                  if (_section !=
                                      _WorkspaceSection.overview) ...[
                                    _WorkspaceHeading(section: _section),
                                    const SizedBox(height: 22),
                                  ],
                                  if (_section == _WorkspaceSection.overview)
                                    _Overview(onSelect: _select),
                                  // Keep assessments mounted when navigating so inputs
                                  // and completed reports are available on return.
                                  Visibility(
                                    visible: _section ==
                                        _WorkspaceSection.formulation,
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
                          Text('NANOVESICLE-AI DESIGNER',
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
              ? 'NANOPREDICT LAB · DESIGN STUDIO'
              : 'NANOVESICLE-AI WORKSPACE'),
          const SizedBox(height: 7),
          Semantics(
            header: true,
            child: Text(
              section == _WorkspaceSection.overview
                  ? 'NanoVesicle-AI'
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
          if (section == _WorkspaceSection.overview) ...[
            const SizedBox(height: 3),
            const Text('Intelligent Nanopharmaceutical Formulation Designer',
                style: TextStyle(
                    color: _teal, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
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
          _DashboardHero(
            onFormulation: () => onSelect(_WorkspaceSection.formulation),
            onProcess: () => onSelect(_WorkspaceSection.process),
          ),
          const SizedBox(height: 16),
          const _DashboardMetricGrid(),
          const SizedBox(height: 23),
          const _OverviewSectionTitle(
            eyebrow: 'DESIGN WORKFLOWS',
            title: 'Choose your assessment path',
            detail: 'Each path reports only what its evidence can support.',
          ),
          const SizedBox(height: 11),
          _FieldGroup(
            children: [
              _LaunchCard(
                section: _WorkspaceSection.formulation,
                tag: 'MODEL 01 · LITERATURE EVIDENCE',
                onOpen: () => onSelect(_WorkspaceSection.formulation),
              ),
              _LaunchCard(
                section: _WorkspaceSection.process,
                tag: 'MODEL 02 · EUGSTER PROCESS',
                onOpen: () => onSelect(_WorkspaceSection.process),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, bounds) {
              final wide = bounds.maxWidth >= 900;
              final benchmarks = const _EvidenceLandscape();
              final examples = _ReferenceCases(onSelect: onSelect);
              if (!wide) {
                return Column(
                  children: [
                    benchmarks,
                    const SizedBox(height: 14),
                    examples,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: benchmarks),
                  const SizedBox(width: 14),
                  Expanded(flex: 5, child: examples),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const _CarrierLandscape(),
        ],
      );
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.onFormulation, required this.onProcess});
  final VoidCallback onFormulation, onProcess;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, bounds) {
          final wide = bounds.maxWidth >= 720;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: .2)),
                ),
                child: const Text(
                  'NANOPREDICT LAB  /  RESEARCH DESIGN STUDIO',
                  style: TextStyle(
                    color: Color(0xFFDCE7FF),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.05,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'NanoVesicle-AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Intelligent Nanopharmaceutical Formulation Designer',
                style: TextStyle(
                  color: Color(0xFFE3EBFF),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Screen formulation evidence or assess supported microfluidic liposome settings in one focused workspace.',
                style: TextStyle(
                  color: Color(0xFFD0DBF5),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onFormulation,
                    icon: const Icon(Icons.biotech_outlined, size: 17),
                    label: const Text('Design formulation'),
                    style: FilledButton.styleFrom(
                      foregroundColor: const Color(0xFF19376E),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onProcess,
                    icon: const Icon(Icons.water_drop_outlined, size: 17),
                    label: const Text('Process model'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side:
                          BorderSide(color: Colors.white.withValues(alpha: .5)),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                    ),
                  ),
                ],
              ),
            ],
          );

          return Container(
            padding: EdgeInsets.all(wide ? 24 : 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF15264A), Color(0xFF315ED2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24315ED2),
                  blurRadius: 22,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: wide
                ? Row(
                    children: [
                      Expanded(flex: 7, child: copy),
                      const SizedBox(width: 20),
                      const Expanded(flex: 4, child: _NanoOrbitGraphic()),
                    ],
                  )
                : copy,
          );
        },
      );
}

class _NanoOrbitGraphic extends StatelessWidget {
  const _NanoOrbitGraphic();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 172,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const CustomPaint(
              size: Size(270, 158),
              painter: _NanoOrbitPainter(),
            ),
            Positioned(
              top: 13,
              right: 7,
              child: _OrbitLabel(
                  icon: Icons.menu_book_outlined,
                  label: 'EVIDENCE',
                  value: 'Curated sources'),
            ),
            Positioned(
              bottom: 9,
              left: 0,
              child: _OrbitLabel(
                  icon: Icons.auto_graph_rounded,
                  label: 'PROCESS',
                  value: 'Cohort models'),
            ),
            Positioned(
              right: 0,
              bottom: 18,
              child: _OrbitLabel(
                  icon: Icons.biotech_outlined,
                  label: 'DESIGN',
                  value: 'Formulation brief'),
            ),
          ],
        ),
      );
}

class _NanoOrbitPainter extends CustomPainter {
  const _NanoOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .5);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .32)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final bead = Paint()..color = const Color(0xFF9CE8E1);
    final bead2 = Paint()..color = const Color(0xFFD9E5FF);
    canvas.drawCircle(center, 42, line);
    canvas.drawCircle(center, 61, line);
    canvas.drawCircle(
        center, 26, Paint()..color = Colors.white.withValues(alpha: .12));
    canvas.drawCircle(center, 12, bead);
    for (var i = 0; i < 9; i++) {
      final angle = (i * 40 - 8) * 3.141592653589793 / 180;
      final radius = i.isEven ? 42.0 : 61.0;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, point, line);
      canvas.drawCircle(point, i % 3 == 0 ? 5 : 3.5, i.isEven ? bead : bead2);
    }
  }

  @override
  bool shouldRepaint(covariant _NanoOrbitPainter oldDelegate) => false;
}

class _OrbitLabel extends StatelessWidget {
  const _OrbitLabel(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF233F7D).withValues(alpha: .92),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withValues(alpha: .2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF9CE8E1), size: 15),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5)),
                Text(value,
                    style:
                        const TextStyle(color: Color(0xFFD8E3FF), fontSize: 9)),
              ],
            ),
          ],
        ),
      );
}

class _DashboardMetricGrid extends StatelessWidget {
  const _DashboardMetricGrid();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, bounds) {
          final columns = bounds.maxWidth >= 980
              ? 4
              : bounds.maxWidth >= 480
                  ? 2
                  : 1;
          return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 91,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _DashboardMetric(
                value: '2,641',
                label: 'FORMULATION RECORDS',
                caption: 'Catalogue coverage',
                icon: Icons.dataset_outlined,
                color: Color(0xFF315ED2),
                tint: Color(0xFFEAF0FF),
              ),
              _DashboardMetric(
                value: '5',
                label: 'CARRIER FAMILIES',
                caption: 'Across the catalogue',
                icon: Icons.bubble_chart_outlined,
                color: Color(0xFF168F8A),
                tint: Color(0xFFE7F7F5),
              ),
              _DashboardMetric(
                value: '928',
                label: 'SCREENED RUNS',
                caption: 'Eugster liposome cohort',
                icon: Icons.science_outlined,
                color: Color(0xFF7051B5),
                tint: Color(0xFFF1ECFB),
              ),
              _DashboardMetric(
                value: '3',
                label: 'PROCESS ENDPOINTS',
                caption: 'Released in current scope',
                icon: Icons.insights_outlined,
                color: Color(0xFFB2761E),
                tint: Color(0xFFFFF4E3),
              ),
            ],
          );
        },
      );
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.value,
    required this.label,
    required this.caption,
    required this.icon,
    required this.color,
    required this.tint,
  });
  final String value, label, caption;
  final IconData icon;
  final Color color, tint;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
                color: Color(0x080F2245), blurRadius: 12, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: TextStyle(
                          color: color,
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 8,
                          letterSpacing: .55,
                          fontWeight: FontWeight.w800)),
                  Text(caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _OverviewSectionTitle extends StatelessWidget {
  const _OverviewSectionTitle({
    required this.eyebrow,
    required this.title,
    required this.detail,
  });
  final String eyebrow, title, detail;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(eyebrow),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  color: _ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.35)),
          const SizedBox(height: 3),
          Text(detail,
              style: const TextStyle(color: _muted, fontSize: 11, height: 1.4)),
        ],
      );
}

class _ReferenceCases extends StatelessWidget {
  const _ReferenceCases({required this.onSelect});
  final _SectionSelect onSelect;

  @override
  Widget build(BuildContext context) => _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('REFERENCE CASES'),
            const SizedBox(height: 5),
            const Text('Open a prepared example',
                style: TextStyle(
                    color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _ExampleRow(
              icon: Icons.science_outlined,
              title: 'Topical celecoxib',
              detail: 'Batch F · observed 54.4% entrapment',
              onTap: () =>
                  onSelect(_WorkspaceSection.formulation, example: 'celecoxib'),
            ),
            _ExampleRow(
              icon: Icons.search_off_rounded,
              title: 'Intranasal quercetin',
              detail: 'Evidence-gap example',
              onTap: () =>
                  onSelect(_WorkspaceSection.formulation, example: 'gap'),
            ),
            _ExampleRow(
              icon: Icons.hub_outlined,
              title: 'DMPC / ZZ process',
              detail: 'Eugster cohort example',
              onTap: () =>
                  onSelect(_WorkspaceSection.process, example: 'process'),
            ),
          ],
        ),
      );
}

class _CarrierLandscape extends StatelessWidget {
  const _CarrierLandscape();

  @override
  Widget build(BuildContext context) => _CardShell(
        child: LayoutBuilder(
          builder: (context, bounds) {
            final wide = bounds.maxWidth >= 650;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('CARRIER LANDSCAPE'),
                const SizedBox(height: 5),
                const Text('Five families in the formulation catalogue',
                    style: TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                const _CarrierFamilyStrip(),
                const SizedBox(height: 7),
                const Text(
                  'Carrier presence in the catalogue does not mean each family has a validated predictive model.',
                  style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
                ),
              ],
            );
            const scope = _InlineNote(
              text:
                  'Numerical model support is limited to the Eugster microfluidic liposome cohort. Cross-carrier ranking and tissue-targeting predictions remain research work.',
            );
            if (!wide) return content;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 7, child: content),
                const SizedBox(width: 20),
                const Expanded(flex: 5, child: scope),
              ],
            );
          },
        ),
      );
}

class _EvidenceLandscape extends StatelessWidget {
  const _EvidenceLandscape();

  @override
  Widget build(BuildContext context) => _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('VALIDATION SNAPSHOT'),
                      SizedBox(height: 5),
                      Text('Grouped-CV benchmarks',
                          style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const _Pill(
                  label: 'EUGSTER COHORT',
                  color: Color(0xFFEAF0FF),
                  textColor: Color(0xFF315ED2),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Retrospective process-model error versus median baselines.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 14),
            const _MaeComparison(
              title: 'Particle size',
              unit: 'nm MAE',
              baseline: 46.35,
              model: 17.42,
              baselineText: '46.35',
              modelText: '17.42',
            ),
            const SizedBox(height: 13),
            const _MaeComparison(
              title: 'Polydispersity index',
              unit: 'PDI MAE',
              baseline: 0.0518,
              model: 0.0376,
              baselineText: '0.0518',
              modelText: '0.0376',
            ),
            const SizedBox(height: 12),
            const _InlineNote(
              text:
                  'Cohort benchmarks are not prediction intervals. Drug-loaded models did not beat median baselines, and the merged catalogue is not a live cross-carrier predictor.',
            ),
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
    final deepAccent =
        process ? const Color(0xFF3D2C78) : const Color(0xFF173C91);
    final inputSummary = process
        ? 'Primary lipid · chip · cholesterol · PEG · flow · FRR'
        : 'Drug ID + MW · LogP · pKa · solubility · stability · route · tissue · release target';
    final outputSummary = process
        ? 'Size · PDI · uncalibrated formation score'
        : 'Cited carrier/excipient candidates · evidence status for ratios, batches, and endpoints';
    final methodSummary = process
        ? 'Fitted cohort models · grouped-CV benchmarks'
        : 'TF-IDF source retrieval + rules · no generative RAG';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x080F2245), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [deepAccent, accent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: .24)),
                      ),
                      child: Icon(section.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tag,
                              style: const TextStyle(
                                  color: Color(0xFFDCE7FF),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .65)),
                          const SizedBox(height: 3),
                          Text(section.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_outward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(section.description,
                    style: const TextStyle(
                        color: Color(0xFFE4EBFF), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ModelFlowRow(
                    label: 'INPUT', text: inputSummary, color: accent),
                const SizedBox(height: 6),
                _ModelFlowRow(
                    label: 'OUTPUT', text: outputSummary, color: accent),
                const SizedBox(height: 6),
                _ModelFlowRow(
                    label: 'METHOD', text: methodSummary, color: accent),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                    ),
                    onPressed: onOpen,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: Text(process
                        ? 'Open process assessment'
                        : 'Open evidence screening'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelFlowRow extends StatelessWidget {
  const _ModelFlowRow({
    required this.label,
    required this.text,
    required this.color,
  });
  final String label, text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 47,
            child: Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 9,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: _ink, fontSize: 10, height: 1.4)),
          ),
        ],
      );
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
