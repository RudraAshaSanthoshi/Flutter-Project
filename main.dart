// EduDash - responsive e-learning dashboard (SDG 4: Quality Education)
import 'package:flutter/material.dart';

void main() => runApp(const EduDashApp());

class Course {
  Course(this.title, this.instructor, this.category, this.description,
      this.icon, this.color, this.lessons);

  final String title, instructor, category, description;
  final IconData icon;
  final Color color;
  final int lessons;
  int done = 0;
  bool enrolled = false;

  double get progress => done / lessons;
  bool get isComplete => done >= lessons;
}

class CourseStore extends ChangeNotifier {
  final courses = [
    Course('Programming with Dart', 'Dr. Meera Rao', 'Programming',
        'Learn Dart from scratch: variables, collections, OOP and async code.',
        Icons.code, Colors.indigo, 8),
    Course('Flutter UI Basics', 'Prof. Arjun Nair', 'Programming',
        'Build responsive mobile UIs with widgets, layouts and navigation.',
        Icons.phone_android, Colors.blue, 10),
    Course('Algebra Essentials', 'Ms. Kavya Iyer', 'Mathematics',
        'Equations, functions and graphs explained with everyday examples.',
        Icons.functions, Colors.orange, 6),
    Course('Statistics for Beginners', 'Dr. Sanjay Kumar', 'Mathematics',
        'Mean, variance, probability and how to read data responsibly.',
        Icons.stacked_line_chart, Colors.teal, 7),
    Course('Spoken English', 'Ms. Priya Menon', 'Languages',
        'Improve fluency, pronunciation and confidence for interviews.',
        Icons.record_voice_over, Colors.pink, 9),
    Course('Environmental Science', 'Dr. Ravi Teja', 'Science',
        'Ecosystems, climate change and sustainability in daily life.',
        Icons.eco, Colors.green, 5),
  ];

  List<String> get categories => ['All', ...{for (var c in courses) c.category}];
  List<Course> get enrolled => courses.where((c) => c.enrolled).toList();
  int get lessonsDone => courses.fold(0, (sum, c) => sum + c.done);
  int get finished => courses.where((c) => c.enrolled && c.isComplete).length;

  void toggleEnroll(Course c) {
    c.enrolled = !c.enrolled;
    if (!c.enrolled) c.done = 0;
    notifyListeners();
  }

  void completeLesson(Course c) {
    if (c.enrolled && !c.isComplete) {
      c.done++;
      notifyListeners();
    }
  }
}

class EduDashApp extends StatelessWidget {
  const EduDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduDash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark),
      home: const AppShell(),
    );
  }
}

class NavItem {
  const NavItem(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon, selectedIcon;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final store = CourseStore();
  int index = 0;

  static const items = [
    NavItem('Home', Icons.home_outlined, Icons.home),
    NavItem('Courses', Icons.menu_book_outlined, Icons.menu_book),
    NavItem('Progress', Icons.bar_chart_outlined, Icons.bar_chart),
    NavItem('Profile', Icons.person_outline, Icons.person),
  ];

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => ResponsiveScaffold(
        title: items[index].label,
        items: items,
        selectedIndex: index,
        onSelected: (i) => setState(() => index = i),
        // IndexedStack keeps the search text when switching tabs
        body: IndexedStack(index: index, children: [
          HomeScreen(store, onBrowse: () => setState(() => index = 1)),
          CoursesScreen(store),
          ProgressScreen(store),
          ProfileScreen(store),
        ]),
      ),
    );
  }
}

/// Side menu on tablets (>= 600 px), bottom bar on phones.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
  });

  final String title;
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;

      if (width >= 600) {
        final extended = width >= 1000;
        return Scaffold(
          appBar: AppBar(title: const Text('EduDash')),
          body: Row(children: [
            NavigationRail(
              extended: extended,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: extended ? null : NavigationRailLabelType.all,
              destinations: [
                for (final i in items)
                  NavigationRailDestination(
                    icon: Icon(i.icon),
                    selectedIcon: Icon(i.selectedIcon),
                    label: Text(i.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ]),
        );
      }

      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations: [
            for (final i in items)
              NavigationDestination(
                icon: Icon(i.icon),
                selectedIcon: Icon(i.selectedIcon),
                label: i.label,
              ),
          ],
        ),
      );
    });
  }
}

/// Centers content and keeps it from stretching on wide screens.
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard(this.icon, this.value, this.label, {super.key});
  final IconData icon;
  final String value, label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = scheme.onPrimaryContainer;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: text.headlineSmall?.copyWith(color: color)),
                Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: color)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard(this.course, {super.key, required this.onTap});
  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 80,
            width: double.infinity,
            color: course.color.withAlpha(40),
            child: Icon(course.icon, size: 44, color: course.color),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium),
              const SizedBox(height: 4),
              Text(course.instructor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall),
              const SizedBox(height: 10),
              if (course.enrolled)
                LinearProgressIndicator(value: course.progress)
              else
                Text('${course.lessons} lessons', style: text.labelMedium),
            ]),
          ),
        ]),
      ),
    );
  }
}

void openCourse(BuildContext context, CourseStore store, Course course) {
  Navigator.push(context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(store, course)));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen(this.store, {super.key, required this.onBrowse});
  final CourseStore store;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final active = store.enrolled.where((c) => !c.isComplete).toList();

    return SingleChildScrollView(
      child: PageContainer(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome back!', style: text.headlineSmall),
          const Text('Learn something new today.'),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 90,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            children: [
              StatCard(Icons.school, '${store.enrolled.length}', 'Enrolled'),
              StatCard(Icons.task_alt, '${store.lessonsDone}', 'Lessons done'),
              StatCard(Icons.emoji_events, '${store.finished}', 'Completed'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Continue learning', style: text.titleLarge),
          const SizedBox(height: 8),
          if (active.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Expanded(
                      child: Text('No active courses yet. Pick one to begin.')),
                  FilledButton(onPressed: onBrowse, child: const Text('Browse')),
                ]),
              ),
            )
          else
            for (final c in active)
              Card(
                child: ListTile(
                  leading: Icon(c.icon, color: c.color),
                  title: Text(c.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(value: c.progress),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openCourse(context, store, c),
                ),
              ),
        ]),
      ),
    );
  }
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen(this.store, {super.key});
  final CourseStore store;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String query = '';
  String category = 'All';

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final shown = store.courses.where((c) {
      final inCategory = category == 'All' || c.category == category;
      return inCategory && c.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return PageContainer(
      child: Column(children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search courses',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final cat in store.categories)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: cat == category,
                  onSelected: (_) => setState(() => category = cat),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: shown.isEmpty
              ? const Center(child: Text('No courses found'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (context, i) => CourseCard(shown[i],
                      onTap: () => openCourse(context, store, shown[i])),
                ),
        ),
      ]),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen(this.store, this.course, {super.key});
  final CourseStore store;
  final Course course;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(course.title)),
        body: SingleChildScrollView(
          child: PageContainer(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: course.color.withAlpha(40),
                  child: Icon(course.icon, size: 32, color: course.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title, style: text.titleLarge),
                        Text('${course.instructor} • ${course.category}'),
                      ]),
                ),
              ]),
              const SizedBox(height: 16),
              Text(course.description, style: text.bodyLarge),
              const SizedBox(height: 16),
              if (course.enrolled) ...[
                LinearProgressIndicator(value: course.progress),
                const SizedBox(height: 4),
                Text('${course.done} of ${course.lessons} lessons done'),
                const SizedBox(height: 16),
              ],
              Wrap(spacing: 12, runSpacing: 8, children: [
                FilledButton.icon(
                  onPressed: () {
                    store.toggleEnroll(course);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(course.enrolled
                          ? 'Enrolled in ${course.title}'
                          : 'Unenrolled from ${course.title}'),
                    ));
                  },
                  icon: Icon(
                      course.enrolled ? Icons.logout : Icons.add_circle_outline),
                  label: Text(course.enrolled ? 'Unenroll' : 'Enroll'),
                ),
                FilledButton.tonalIcon(
                  onPressed: course.enrolled && !course.isComplete
                      ? () => store.completeLesson(course)
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Complete next lesson'),
                ),
              ]),
              const SizedBox(height: 24),
              Text('Lessons', style: text.titleMedium),
              for (var i = 0; i < course.lessons; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    i < course.done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: i < course.done ? Colors.green : null,
                  ),
                  title: Text('Lesson ${i + 1}'),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen(this.store, {super.key});
  final CourseStore store;

  @override
  Widget build(BuildContext context) {
    final enrolled = store.enrolled;
    final text = Theme.of(context).textTheme;

    if (enrolled.isEmpty) {
      return const Center(child: Text('Enroll in a course to track progress'));
    }

    return PageContainer(
      child: ListView.separated(
        itemCount: enrolled.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final c = enrolled[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(c.icon, color: c.color),
                  const SizedBox(width: 12),
                  Expanded(child: Text(c.title, style: text.titleMedium)),
                  Text('${(c.progress * 100).round()}%'),
                ]),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: c.progress),
                const SizedBox(height: 6),
                Text(c.isComplete ? 'Course completed' : '${c.done}/${c.lessons} lessons',
                    style: text.bodySmall),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(this.store, {super.key});
  final CourseStore store;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.onSecondaryContainer;

    return SingleChildScrollView(
      child: PageContainer(
        child: Column(children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text('Learner', style: text.titleLarge),
          Text('${store.enrolled.length} courses • '
              '${store.lessonsDone} lessons completed'),
          const SizedBox(height: 24),
          Card(
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.public, color: color),
                  const SizedBox(width: 8),
                  Text('SDG 4: Quality Education',
                      style: text.titleMedium?.copyWith(color: color)),
                ]),
                const SizedBox(height: 8),
                Text(
                  'EduDash gives learners free, self-paced access to courses '
                  'on any phone or tablet, supporting inclusive and equitable '
                  'quality education and lifelong learning for all.',
                  style: TextStyle(color: color),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
