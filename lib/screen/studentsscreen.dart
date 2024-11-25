import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/student.dart';
import 'package:tp70/service/studentservice.dart';
import 'package:tp70/template/navbar.dart';

import '../template/dialog/studentdialog.dart';

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
    studentsFuture = getAllStudent(); // Charge tous les étudiants par défaut
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
                  child: Text(
                      classItem['nomClass']), // Affiche le nom de la classe
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
                      return Slidable(
                        key: Key((snapshot.data[index]['id']).toString()),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddStudentDialog(
                                        notifyParent: refreshStudents,
                                        student: Student(
                                            snapshot.data[index]['dateNais'],
                                            snapshot.data[index]['nom'],
                                            snapshot.data[index]['prenom'],
                                            snapshot.data[index]['id']),
                                      );
                                    });
                              },
                              backgroundColor: const Color(0xFF21B7CA),
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          dismissible: DismissiblePane(onDismissed: () async {
                            await deleteStudent(snapshot.data[index]['id']);
                            setState(() {
                              snapshot.data.removeAt(index);
                            });
                          }),
                          children: [Container()],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              margin: const EdgeInsets.only(bottom: 30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text("Nom et Prénom : "),
                                      Text(
                                        snapshot.data[index]['nom'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 2.0,
                                      ),
                                      Text(snapshot.data[index]['prenom']),
                                    ],
                                  ),
                                  Text(
                                    'Date de Naissance :${DateFormat("dd-MM-yyyy").format(
                                            DateTime.parse(snapshot.data[index]
                                                ['dateNais']))}',
                                  )
                                ],
                              ),
                            ),
                          ],
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
