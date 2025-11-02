import 'package:flutter/material.dart';

void main() {
  runApp(const StudentRecordSystemApp());
}

class StudentRecordSystemApp extends StatelessWidget {
  const StudentRecordSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Record System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const StudentRecordPage(),
    );
  }
}

class Student {
  Student({required this.name, required this.age, required this.course});

  final String name;
  final int age;
  final String course;
}

class StudentRecordPage extends StatefulWidget {
  const StudentRecordPage({super.key});

  @override
  State<StudentRecordPage> createState() => _StudentRecordPageState();
}

class _StudentRecordPageState extends State<StudentRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _courseController = TextEditingController();
  final _searchController = TextEditingController();
  final List<Student> _students = <Student>[];

  int? _selectedIndex;
  String _searchQuery = '';

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) {
      return List<Student>.from(_students);
    }
    final query = _searchQuery.toLowerCase();
    return _students
        .where((student) => student.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _courseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addStudent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final student = Student(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      course: _courseController.text.trim(),
    );
    setState(() {
      _students.add(student);
      _sortStudents();
      _clearSelection();
    });
    _showMessage('Student added');
  }

  void _updateStudent() {
    if (_selectedIndex == null) {
      _showMessage('Select a student to update');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final updatedStudent = Student(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      course: _courseController.text.trim(),
    );
    final currentIndex = _selectedIndex!;
    setState(() {
      _students[currentIndex] = updatedStudent;
      _sortStudents();
      _selectedIndex = _students.indexWhere(
        (student) => student == updatedStudent,
      );
    });
    _showMessage('Student updated');
  }

  void _deleteStudent() {
    if (_selectedIndex == null) {
      _showMessage('Select a student to delete');
      return;
    }
    setState(() {
      _students.removeAt(_selectedIndex!);
      _clearSelection();
    });
    _showMessage('Student deleted');
  }

  void _selectStudent(Student student) {
    final index = _students.indexOf(student);
    if (index == -1) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      _nameController.text = student.name;
      _ageController.text = student.age.toString();
      _courseController.text = student.course;
    });
  }

  void _clearSelection() {
    _selectedIndex = null;
    _nameController.clear();
    _ageController.clear();
    _courseController.clear();
    FocusScope.of(context).unfocus();
  }

  void _sortStudents() {
    _students.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStudents;
    return Scaffold(
      appBar: AppBar(title: const Text('Student Record System')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Students (${_students.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an age';
                      }
                      final age = int.tryParse(value.trim());
                      if (age == null || age <= 0) {
                        return 'Age must be a positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _courseController,
                    decoration: const InputDecoration(labelText: 'Course'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a course';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addStudent,
                    child: const Text('Add'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateStudent,
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteStudent,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No students found'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final student = filtered[index];
                        final originalIndex = _students.indexOf(student);
                        final isSelected = _selectedIndex == originalIndex;
                        return ListTile(
                          title: Text(student.name),
                          subtitle: Text(
                            'Age: ${student.age} | Course: ${student.course}',
                          ),
                          selected: isSelected,
                          onTap: () => _selectStudent(student),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
