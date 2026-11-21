part of 'main.dart';

const _nav = Color(0xFF111C33);
const _navMuted = Color(0xFFAAB7D1);

enum _WorkspaceSection { overview, formulation, process, guide }

extension on _WorkspaceSection {
  String get title => switch (this) {
        _WorkspaceSection.overview => 'Overview',
        _WorkspaceSection.formulation => 'Formulation evidence',
        _WorkspaceSection.process => 'Microfluidic process',
        _WorkspaceSection.guide => 'Result guide',
      };
  IconData get icon => switch (this) {
        _WorkspaceSection.overview => Icons.space_dashboard_outlined,
        _WorkspaceSection.formulation => Icons.biotech_outlined,
        _WorkspaceSection.process => Icons.hub_outlined,
        _WorkspaceSection.guide => Icons.menu_book_outlined,
      };
  String get description => switch (this) {
        _WorkspaceSection.overview =>
          'Evaluate formulation evidence and benchmark microfluidic liposome processes in one workspace.',
        _WorkspaceSection.formulation =>
          'Find relevant published batches and see which endpoints the evidence can support.',
        _WorkspaceSection.process =>
          'Check formation, particle size, and PDI for settings covered by the Eugster cohort.',
        _WorkspaceSection.guide =>
          'Understand each output and the limits of the underlying research.',
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
                                if (_section == _WorkspaceSection.guide)
                                  const _ResultGuide(),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 17),
                child: Divider(height: 1, color: Color(0xFF30405E)),
              ),
              const _NavLabel('REFERENCE'),
              ListTile(
                onTap: () => onSelect(_WorkspaceSection.guide),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                selected: selected == _WorkspaceSection.guide,
                selectedTileColor: const Color(0xFF263D72),
                selectedColor: Colors.white,
                iconColor: _navMuted,
                textColor: _navMuted,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                horizontalTitleGap: 9,
                minLeadingWidth: 20,
                leading: Icon(_WorkspaceSection.guide.icon, size: 19),
                title: const Text('Result guide',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              ListTile(
                onTap: () => _openUrl('$_apiBase/docs'),
                iconColor: _navMuted,
                textColor: _navMuted,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                horizontalTitleGap: 9,
                minLeadingWidth: 20,
                leading: const Icon(Icons.code_rounded, size: 19),
                trailing: const Icon(Icons.north_east_rounded, size: 13),
                title: const Text('API documentation',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
              : 'SMARTNANO WORKSPACE'),
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

class _ResultGuide extends StatelessWidget {
  const _ResultGuide();

  @override
  Widget build(BuildContext context) => _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reading an assessment',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            for (final (icon, title, description) in const [
              (
                Icons.query_stats_rounded,
                'Model estimate',
                'Numerical formation, size, and PDI estimates are available only within the Eugster process scope. Formation is an uncalibrated score. Historical errors are cohort benchmarks.'
              ),
              (
                Icons.menu_book_outlined,
                'Published observation',
                'A measurement from a specific study batch. Open endpoint details to see the source, citation, and evidence limitations.'
              ),
              (
                Icons.flag_outlined,
                'Your target',
                'A value you enter for the assessment. It stays separate from model estimates and published observations.'
              ),
              (
                Icons.warning_amber_rounded,
                'Unresolved or conflicting evidence',
                'The report explains when evidence is missing, estimates are withheld, or a comparison needs review.'
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconTile(
                        icon: icon,
                        foreground: _teal,
                        background: const Color(0xFFEAF0FF)),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(description,
                              style: const TextStyle(
                                  color: _muted, fontSize: 14, height: 1.45)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}
