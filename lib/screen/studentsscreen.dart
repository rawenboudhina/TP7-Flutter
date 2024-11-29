import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../service/studentservice.dart';
import '../template/dialog/studentdialog.dart';
import '../template/navbar.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final double _currentFontSize = 0;
  String? selectedClass; // Classe sélectionnée
  List<dynamic> classes = []; // Liste des classes disponibles
  Future<List>? studentsFuture; // Future pour les étudiants

  @override
  void initState() {
    super.initState();
    fetchClasses(); // Charge les classes dès le début
    studentsFuture = fetchStudentsByClass(selectedClass); // Charge les étudiants par classe
    selectedClass = "3";
  }

  // Récupère les classes depuis le service
  void fetchClasses() async {
    classes = await getAllClasses();
    setState(() {});
  }

  // Rafraîchit la liste des étudiants en fonction de la classe sélectionnée
  void refreshStudents() {
    studentsFuture = fetchStudentsByClass(selectedClass);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar('Etudiant'),
      body: Column(
        children: [
          // Liste déroulante des classes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text("Sélectionnez une classe"),
              value: selectedClass,
              items: classes.map<DropdownMenuItem<String>>((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem['codClass'].toString(),
                  child: Text(classItem['nomClass']), // Affiche le nom de la classe
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClass = value;
                });
                refreshStudents(); // Rafraîchit les étudiants
              },
              isExpanded: true,
            ),
          ),

          // Liste des étudiants
          Expanded(
            child: FutureBuilder(
              future: studentsFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                            "${snapshot.data[index]['nom']} ${snapshot.data[index]['prenom']}"),
                        subtitle: Text(
                          "Date de Naissance: ${DateFormat("dd-MM-yyyy").format(DateTime.parse(snapshot.data[index]['dateNais']))}",
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("Aucun étudiant trouvé."));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddStudentDialog(
                  notifyParent: refreshStudents,
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
