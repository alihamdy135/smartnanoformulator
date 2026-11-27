part of 'main.dart';

part of 'main.dart';

enum _WorkspaceSection { formulation, process }

extension on _WorkspaceSection {
  String get title => switch (this) {
        _WorkspaceSection.formulation => 'Formulation screening',
        _WorkspaceSection.process => 'Process assessment',
      };
  String get description => switch (this) {
        _WorkspaceSection.formulation =>
          'Review cited formulation evidence for a drug, route, tissue, and release goal.',
        _WorkspaceSection.process =>
          'Assess supported microfluidic liposome settings with cohort-scoped estimates.',
      };
}

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final _scroll = ScrollController();
  _WorkspaceSection _section = _WorkspaceSection.formulation;

  void _select(_WorkspaceSection section) {
    if (section == _section) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _section = section);
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ConsoleTop(section: _section, onSelect: _select),
            Expanded(
              child: Scrollbar(
                controller: _scroll,
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: EdgeInsets.all(desktop ? 28 : 14),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1320),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _WorkspaceHeading(section: _section),
                          const SizedBox(height: 18),
                          Visibility(
                            visible: _section == _WorkspaceSection.formulation,
                            maintainState: true,
                            child: FormulationFlow(),
                          ),
                          Visibility(
                            visible: _section == _WorkspaceSection.process,
                            maintainState: true,
                            child: ProcessFlow(),
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
    );
  }
}

class _ConsoleTop extends StatelessWidget {
  const _ConsoleTop({required this.section, required this.onSelect});
  final _WorkspaceSection section;
  final ValueChanged<_WorkspaceSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 620;
    final selector = SegmentedButton<_WorkspaceSection>(
      segments: const [
        ButtonSegment(
          value: _WorkspaceSection.formulation,
          label: Text('Formulation'),
          icon: Icon(Icons.biotech_outlined),
        ),
        ButtonSegment(
          value: _WorkspaceSection.process,
          label: Text('Process'),
          icon: Icon(Icons.hub_outlined),
        ),
      ],
      selected: {section},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onSelect(selection.first),
    );

    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _IconTile(
          icon: Icons.spa_outlined,
          foreground: Colors.white,
          background: _teal,
        ),
        const SizedBox(width: 9),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NanoPredict Lab',
                style: TextStyle(
                    color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
            Text('FORMULATION WORKSPACE',
                style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: narrow ? 12 : 24,
        vertical: narrow ? 10 : 8,
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                brand,
                const SizedBox(height: 9),
                selector,
              ],
            )
          : Row(
              children: [
                brand,
                const Spacer(),
                selector,
              ],
            ),
    );
  }
}

class _WorkspaceHeading extends StatelessWidget {
  const _WorkspaceHeading({required this.section});
  final _WorkspaceSection section;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('NANOPREDICT LAB · DESIGN WORKSPACE'),
          const SizedBox(height: 7),
          Semantics(
            header: true,
            child: Text(
              section.title,
              style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).width >= 950 ? 34 : 27,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -1,
                  height: 1.1),
            ),
          ),
          const SizedBox(height: 8),
          Text(section.description,
              style: const TextStyle(color: _muted, fontSize: 14, height: 1.5)),
          const SizedBox(height: 14),
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
