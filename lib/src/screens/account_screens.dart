import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../widgets/common.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _name = 'Andrei Popescu';
  String _school = 'Colegiul Național "Gheorghe Lazăr"';
  String _selectedProfile = 'Mate-Info';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Profil', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.blue, AppColors.indigo], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 44),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(CupertinoIcons.pencil, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(_name, style: AppText.titleStyle),
                const SizedBox(height: 4),
                Text(_school, style: AppText.subheadStyle, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                IOSSection(
                  header: 'Informații personale',
                  children: [
                    _EditableCell(label: 'Nume', value: _name, onChanged: (v) => setState(() => _name = v)),
                    _EditableCell(label: 'Școală', value: _school, onChanged: (v) => setState(() => _school = v)),
                  ],
                ),
                IOSSection(
                  header: 'Profil BAC',
                  children: [
                    for (final profile in appProfiles)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            AppIconBadge(icon: profile.icon, color: profile.accentColor),
                            const SizedBox(width: 14),
                            Expanded(child: Text(profile.name, style: AppText.bodyStyle)),
                            if (_selectedProfile == profile.name)
                              const Icon(CupertinoIcons.checkmark_alt, color: AppColors.blue, size: 20),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableCell extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _EditableCell({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: AppText.subheadStyle)),
          Expanded(
            child: Text(value, style: AppText.bodyStyle, overflow: TextOverflow.ellipsis),
          ),
          const Icon(CupertinoIcons.pencil, color: AppColors.blue, size: 16),
        ],
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Subiecte rezolvate', '14', AppColors.blue),
      ('Timp total studiu', '28h 15m', AppColors.indigo),
      ('Medie generală', '7.85', AppColors.green),
      ('Streak curent', '5 zile', AppColors.orange),
    ];

    const subjects = [
      ('Limba Română', 0.72, AppColors.blue),
      ('Matematică (M1)', 0.58, AppColors.indigo),
      ('Informatică', 0.85, AppColors.teal),
      ('Fizică', 0.40, AppColors.orange),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Progres', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      for (final stat in stats)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(stat.$1, style: AppText.captionStyle),
                              Text(stat.$2, style: TextStyle(fontFamily: '.SF Pro Display', fontSize: 24, fontWeight: FontWeight.w700, color: stat.$3, letterSpacing: -0.5)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                IOSSection(
                  header: 'Progres pe materii',
                  children: [
                    for (final s in subjects)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(s.$1, style: AppText.bodyStyle),
                                Text('${(s.$2 * 100).toInt()}%', style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 14, fontWeight: FontWeight.w600, color: s.$3)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: s.$2,
                                minHeight: 6,
                                backgroundColor: AppColors.background,
                                valueColor: AlwaysStoppedAnimation<Color>(s.$3),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _history = [
    ('Matematică (M1)', '2025 · Sesiunea Iunie', '2h 58m', '8.5', AppColors.indigo),
    ('Limba Română', '2024 · Simulare Națională', '3h 00m', '7.0', AppColors.blue),
    ('Informatică', '2024 · Sesiunea Iunie', '1h 45m', '9.2', AppColors.teal),
    ('Fizică', '2023 · Sesiunea Aug/Sept', '2h 30m', '6.5', AppColors.orange),
    ('Matematică (M1)', '2023 · Simulare Națională', '3h 00m', '7.8', AppColors.indigo),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Istoric', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                IOSSection(
                  header: 'Sesiuni recente',
                  children: [
                    for (final h in _history)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(width: 4, height: 44, decoration: BoxDecoration(color: h.$5, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h.$1, style: AppText.bodyStyle),
                                  const SizedBox(height: 2),
                                  Text(h.$2, style: AppText.subheadStyle),
                                  const SizedBox(height: 2),
                                  Text('Durata: ${h.$3}', style: AppText.captionStyle),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _gradeColor(double.parse(h.$4)).withAlpha(31),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                h.$4,
                                style: TextStyle(fontFamily: '.SF Pro Display', fontSize: 17, fontWeight: FontWeight.w700, color: _gradeColor(double.parse(h.$4))),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _gradeColor(double g) {
    if (g >= 8.5) return AppColors.green;
    if (g >= 5.0) return AppColors.orange;
    return AppColors.red;
  }
}

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _dailyReminder = true;
  bool _examAlerts = true;
  bool _streakReminder = false;
  bool _gradeUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Notificări', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                IOSSection(
                  header: 'Alerte studiu',
                  children: [
                    _SwitchCell(icon: CupertinoIcons.bell_fill, color: AppColors.red, label: 'Reamintire zilnică', value: _dailyReminder, onChanged: (v) => setState(() => _dailyReminder = v)),
                    _SwitchCell(icon: CupertinoIcons.flame_fill, color: AppColors.orange, label: 'Streak zilnic', value: _streakReminder, onChanged: (v) => setState(() => _streakReminder = v)),
                  ],
                ),
                IOSSection(
                  header: 'Examen',
                  footer: 'Vei fi notificat cu 7 zile înainte de sesiune.',
                  children: [
                    _SwitchCell(icon: CupertinoIcons.calendar_badge_plus, color: AppColors.blue, label: 'Date sesiuni BAC', value: _examAlerts, onChanged: (v) => setState(() => _examAlerts = v)),
                    _SwitchCell(icon: CupertinoIcons.chart_bar_fill, color: AppColors.green, label: 'Actualizări note', value: _gradeUpdates, onChanged: (v) => setState(() => _gradeUpdates = v)),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCell({required this.icon, required this.color, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          AppIconBadge(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppText.bodyStyle)),
          CupertinoSwitch(value: value, onChanged: onChanged, activeTrackColor: AppColors.blue),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _haptics = true;
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Setări', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                IOSSection(
                  header: 'Aspect',
                  children: [
                    _SwitchCell(icon: CupertinoIcons.moon_fill, color: AppColors.indigo, label: 'Mod întunecat', value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
                    _SwitchCell(icon: CupertinoIcons.circle_grid_hex_fill, color: AppColors.orange, label: 'Feedback haptic', value: _haptics, onChanged: (v) => setState(() => _haptics = v)),
                  ],
                ),
                IOSSection(
                  header: 'Date',
                  children: [
                    _SwitchCell(icon: CupertinoIcons.cloud_fill, color: AppColors.teal, label: 'Salvare automată', value: _autoSave, onChanged: (v) => setState(() => _autoSave = v)),
                    IOSCell(
                      leading: const AppIconBadge(icon: CupertinoIcons.arrow_down_circle_fill, color: AppColors.blue),
                      title: 'Exportă datele mele',
                      subtitle: 'Descarcă toate subiectele și notele',
                      onTap: () {},
                    ),
                    IOSCell(
                      leading: const AppIconBadge(icon: CupertinoIcons.trash_fill, color: AppColors.red),
                      title: 'Șterge tot istoricul',
                      subtitle: 'Acțiune ireversibilă',
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text('Șterge istoricul?'),
                            content: const Text('Toate sesiunile și notele vor fi șterse permanent.'),
                            actions: [
                              CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: const Text('Anulează')),
                              CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Navigator.pop(context), child: const Text('Șterge')),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.separator,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: AppColors.blue),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(20, 0, 16, 14),
              title: Text('Despre', style: AppText.largeTitleStyle),
              expandedTitleScale: 1.0,
              collapseMode: CollapseMode.none,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.blue, AppColors.indigo], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: AppColors.blue.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(CupertinoIcons.book_fill, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 14),
                const Text('EduBAC', style: TextStyle(fontFamily: '.SF Pro Display', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.label, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                const Text('Versiunea 1.0.0', style: AppText.subheadStyle),
                const SizedBox(height: 32),
                IOSSection(
                  header: 'Aplicație',
                  children: [
                    IOSCell(leading: const AppIconBadge(icon: CupertinoIcons.doc_text, color: AppColors.blue), title: 'Termeni și condiții', onTap: () {}),
                    IOSCell(leading: const AppIconBadge(icon: CupertinoIcons.lock_shield_fill, color: AppColors.green), title: 'Politica de confidențialitate', onTap: () {}),
                    IOSCell(leading: const AppIconBadge(icon: CupertinoIcons.star_fill, color: AppColors.orange), title: 'Evaluează pe App Store', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 40),
                Text('Creat cu drag pentru elevii din România.', style: AppText.captionStyle.copyWith(color: AppColors.tertiaryLabel)),
                const SizedBox(height: 8),
                Text('© 2025 EduBAC', style: AppText.captionStyle.copyWith(color: AppColors.tertiaryLabel)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


