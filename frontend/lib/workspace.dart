part of 'main.dart';

const _nav = Color(0xFF142B22);
const _navMuted = Color(0xFFB5C8BB);

enum _WorkspaceSection { overview, formulation, process }

extension on _WorkspaceSection {
  String get title => switch (this) {
        _WorkspaceSection.overview => 'Overview',
        _WorkspaceSection.formulation => 'Formulation design',
        _WorkspaceSection.process => 'Process assessment',
      };
  IconData get icon => switch (this) {
        _WorkspaceSection.overview => Icons.space_dashboard_outlined,
        _WorkspaceSection.formulation => Icons.biotech_outlined,
        _WorkspaceSection.process => Icons.hub_outlined,
      };
  String get description => switch (this) {
        _WorkspaceSection.overview =>
          'Evidence-guided nanopharmaceutical formulation design with clear, source-linked assessments.',
        _WorkspaceSection.formulation =>
          'Explore cited formulation candidates and endpoint evidence for your drug, route, tissue, and release goal.',
        _WorkspaceSection.process =>
          'Assess particle size, PDI, and formation for supported Eugster microfluidic liposome settings.',
      };
}

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final _scroll = ScrollController();
  _WorkspaceSection _section = _WorkspaceSection.overview;
  String? _example;
  int _formulationVersion = 0, _processVersion = 0;

  void _select(_WorkspaceSection section, {String? example}) {
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
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: _section.index,
              onDestinationSelected: (index) =>
                  _select(_WorkspaceSection.values[index]),
              height: 66,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFE6F0E6),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.biotech_outlined),
                  selectedIcon: Icon(Icons.biotech_rounded),
                  label: 'Formulation',
                ),
                NavigationDestination(
                  icon: Icon(Icons.water_drop_outlined),
                  selectedIcon: Icon(Icons.water_drop_rounded),
                  label: 'Process',
                ),
              ],
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop) SizedBox(width: 224, child: sidebar),
            Expanded(
              child: Container(
                color: const Color(0xFFF4F7F2),
                child: Column(
                  children: [
                    _ConsoleTop(section: _section),
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
                        icon: Icons.spa_outlined,
                        foreground: Colors.white,
                        background: Color(0xFF5F8663)),
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
                      selectedTileColor: const Color(0xFF294A37),
                      selectedColor: Colors.white,
                      iconColor: _navMuted,
                      textColor: _navMuted,
                      leading: Icon(section.icon, size: 19),
                      title: Text(section.title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      trailing: selected == section
                          ? const Icon(Icons.circle,
                              color: Color(0xFFB7D4AF), size: 7)
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
  const _ConsoleTop({required this.section});
  final _WorkspaceSection section;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: const BoxDecoration(
            color: _surface, border: Border(bottom: BorderSide(color: _line))),
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width >= 950 ? 28 : 14),
        child: Row(
          children: [
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
                  label: 'FORMULATION WORKSPACE',
                  color: Color(0xFFE6F0E6),
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
              ? 'NANOPREDICT LAB · FORMULATION DESIGN'
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
          const SizedBox(height: 22),
          const _OverviewSectionTitle(
            eyebrow: 'FORMULATION WORKSPACE',
            title: 'Choose where to begin',
            detail:
                'Open a design flow and review its results on the same page.',
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
              final examples = _ReferenceCases(onSelect: onSelect);
              const carriers = _CarrierLandscape();
              if (!wide) {
                return Column(
                  children: [
                    examples,
                    const SizedBox(height: 14),
                    carriers,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: examples),
                  const SizedBox(width: 14),
                  const Expanded(flex: 5, child: carriers),
                ],
              );
            },
          ),
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
                  'NANOPREDICT LAB  /  NANOPHARMACEUTICAL DESIGN',
                  style: TextStyle(
                    color: Color(0xFFDDEBDD),
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
                  color: Color(0xFFE2EEE1),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Design with cited formulation evidence and assess supported microfluidic liposome settings in one focused workspace.',
                style: TextStyle(
                  color: Color(0xFFD2E3D1),
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
                      foregroundColor: const Color(0xFF173226),
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
                colors: [Color(0xFF173226), Color(0xFF4A7B5B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x243A6948),
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _NanoOrbitGraphic(),
                      const SizedBox(height: 4),
                      copy,
                    ],
                  ),
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
    final bead = Paint()..color = const Color(0xFFB5D4AA);
    final bead2 = Paint()..color = const Color(0xFFE5EFDE);
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
          color: const Color(0xFF254735).withValues(alpha: .94),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withValues(alpha: .2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFB5D4AA), size: 15),
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
                        const TextStyle(color: Color(0xFFDDEBDD), fontSize: 9)),
              ],
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

class _LaunchCard extends StatelessWidget {
  const _LaunchCard(
      {required this.section, required this.tag, required this.onOpen});
  final _WorkspaceSection section;
  final String tag;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final process = section == _WorkspaceSection.process;
    final accent = process ? const Color(0xFF71856F) : const Color(0xFF34745A);
    final dark = process ? const Color(0xFF334B38) : const Color(0xFF173226);
    final tint = process ? const Color(0xFFEEF2E9) : const Color(0xFFE7F0E6);
    final summary = process
        ? 'Assess supported microfluidic liposome settings with cohort-scoped size and PDI estimates and a clearly marked formation score.'
        : 'Review cited carrier and excipient candidates alongside evidence for ratios, batches, and each requested outcome.';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D1B3527), blurRadius: 16, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 17),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [dark, accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: .24)),
                      ),
                      child: Icon(section.icon, color: Colors.white, size: 22),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_outward_rounded,
                        color: Colors.white.withValues(alpha: .8), size: 19),
                  ],
                ),
                const SizedBox(height: 13),
                Text(tag,
                    style: const TextStyle(
                        color: Color(0xFFDCEBDD),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8)),
                const SizedBox(height: 4),
                Text(
                  process
                      ? 'Microfluidic process assessment'
                      : 'Formulation evidence screening',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary,
                    style: const TextStyle(
                        color: _muted, fontSize: 12, height: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: process
                      ? [
                          _Pill(
                              label: 'SIZE + PDI',
                              color: tint,
                              textColor: dark,
                              icon: Icons.straighten_rounded),
                          _Pill(
                              label: 'FORMATION SCREEN',
                              color: tint,
                              textColor: dark,
                              icon: Icons.bubble_chart_outlined),
                        ]
                      : [
                          _Pill(
                              label: 'LITERATURE CITATIONS',
                              color: tint,
                              textColor: dark,
                              icon: Icons.menu_book_outlined),
                          _Pill(
                              label: 'ENDPOINT EVIDENCE',
                              color: tint,
                              textColor: dark,
                              icon: Icons.fact_check_outlined),
                        ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onOpen,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: Text(process
                        ? 'Open process assessment'
                        : 'Start evidence screening'),
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
