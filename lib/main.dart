import 'package:flutter/material.dart';

void main() {
  runApp(const BacApp());
}

class BacApp extends StatelessWidget {
  const BacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBAC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const ProfileSelectionScreen(),
    );
  }
}

// Model pentru Profil
class Profile {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<Subject> subjects;

  const Profile({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.subjects,
  });
}

// Model pentru Materie
class Subject {
  final String title;
  final IconData icon;
  final Color color;

  const Subject({required this.title, required this.icon, required this.color});
}

// Datele aplicației
final List<Profile> appProfiles = [
  Profile(
    name: 'Mate-Info',
    description: 'Profil Real - Matematică M1',
    icon: Icons.computer,
    color: Colors.blue.shade700,
    subjects: [
      const Subject(title: 'Limba Română', icon: Icons.menu_book, color: Colors.blue),
      const Subject(title: 'Matematică (M1)', icon: Icons.functions, color: Colors.indigo),
      const Subject(title: 'Informatică', icon: Icons.code, color: Colors.teal),
      const Subject(title: 'Fizică', icon: Icons.electric_bolt, color: Colors.orange),
      const Subject(title: 'Chimie', icon: Icons.science, color: Colors.purple),
      const Subject(title: 'Biologie', icon: Icons.biotech, color: Colors.green),
    ],
  ),
  Profile(
    name: 'Științe ale Naturii',
    description: 'Profil Real - Matematică M2',
    icon: Icons.biotech,
    color: Colors.green.shade700,
    subjects: [
      const Subject(title: 'Limba Română', icon: Icons.menu_book, color: Colors.blue),
      const Subject(title: 'Matematică (M2)', icon: Icons.functions, color: Colors.indigo),
      const Subject(title: 'Biologie', icon: Icons.eco, color: Colors.green),
      const Subject(title: 'Chimie', icon: Icons.science, color: Colors.purple),
      const Subject(title: 'Fizică', icon: Icons.electric_bolt, color: Colors.orange),
      const Subject(title: 'Informatică', icon: Icons.code, color: Colors.teal),
    ],
  ),
  Profile(
    name: 'Filologie',
    description: 'Profil Uman - Proba E.c) Istorie',
    icon: Icons.history_edu,
    color: Colors.amber.shade800,
    subjects: [
      const Subject(title: 'Limba Română', icon: Icons.menu_book, color: Colors.blue),
      const Subject(title: 'Istorie', icon: Icons.gavel, color: Colors.amber),
      const Subject(title: 'Geografie', icon: Icons.public, color: Colors.brown),
      const Subject(title: 'Logică', icon: Icons.psychology, color: Colors.deepOrange),
      const Subject(title: 'Psihologie', icon: Icons.favorite, color: Colors.pink),
      const Subject(title: 'Sociologie', icon: Icons.groups, color: Colors.blueGrey),
    ],
  ),
  Profile(
    name: 'Științe Sociale',
    description: 'Profil Uman - Proba E.c) Istorie',
    icon: Icons.groups,
    color: Colors.deepPurple,
    subjects: [
      const Subject(title: 'Limba Română', icon: Icons.menu_book, color: Colors.blue),
      const Subject(title: 'Istorie', icon: Icons.gavel, color: Colors.amber),
      const Subject(title: 'Logică', icon: Icons.psychology, color: Colors.deepOrange),
      const Subject(title: 'Geografie', icon: Icons.public, color: Colors.brown),
      const Subject(title: 'Economie', icon: Icons.analytics, color: Colors.lightGreen),
    ],
  ),
];

// ECRAN 1: Selecție Profil
class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alege Profilul Tău', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: appProfiles.length,
        itemBuilder: (context, index) {
          final profile = appProfiles[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              leading: CircleAvatar(
                backgroundColor: profile.color.withOpacity(0.1),
                child: Icon(profile.icon, color: profile.color),
              ),
              title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(profile.description),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectListScreen(profile: profile),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ECRAN 2: Lista de Materii pentru Profilul ales
class SubjectListScreen extends StatelessWidget {
  final Profile profile;
  const SubjectListScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materii ${profile.name}'),
        backgroundColor: profile.color,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
        ),
        itemCount: profile.subjects.length,
        itemBuilder: (context, index) {
          final subject = profile.subjects[index];
          return InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deschidem subiectele la ${subject.title}')),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(subject.icon, size: 40, color: subject.color),
                  const SizedBox(height: 12),
                  Text(
                    subject.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}