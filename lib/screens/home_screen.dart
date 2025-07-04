import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notion_like_app/models/task.dart';
import 'package:notion_like_app/models/category.dart';
import 'package:notion_like_app/providers/task_provider.dart';
import 'package:notion_like_app/providers/category_provider.dart';
import 'package:notion_like_app/providers/theme_provider.dart';
import 'package:notion_like_app/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedPriority;
  bool? _showCompleted;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    List<Task> filteredTasks = taskProvider.getFilteredTasks(
      searchQuery: _searchQuery,
      categoryId: _selectedCategoryId,
      priority: _selectedPriority,
      isCompleted: _showCompleted,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notion-like Todo'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.currentTheme == ThemeData.light()
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'stats') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'stats',
                child: Text('Statistics'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('All Tasks'),
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                });
                Navigator.pop(context);
              },
            ),
            ...categoryProvider.categories.map((category) {
              return ListTile(
                leading: Icon(category.icon, color: category.color),
                title: Text(category.name),
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const Divider(),
            ListTile(
              title: const Text('Add New Category'),
              leading: const Icon(Icons.add),
              onTap: () {
                Navigator.pop(context);
                _showAddCategoryDialog(context, categoryProvider);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search tasks',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')), 
                      DropdownMenuItem(value: 0, child: Text('Low')),
                      DropdownMenuItem(value: 1, child: Text('Medium')),
                      DropdownMenuItem(value: 2, child: Text('High')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<bool?>(
                    value: _showCompleted,
                    decoration: const InputDecoration(
                      labelText: 'Show Completed',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: true, child: Text('Completed')),
                      DropdownMenuItem(value: false, child: Text('Pending')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _showCompleted = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text('No tasks found.'))
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final category = categoryProvider.categories.firstWhere(
                          (cat) => cat.id == task.categoryId,
                          orElse: () => Category(name: 'Unknown', icon: Icons.help, color: Colors.grey));
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              taskProvider.toggleTaskStatus(task);
                            },
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description),
                              Text('Category: ${category.name}'),
                              Text('Priority: ${task.priority == 0 ? 'Low' : task.priority == 1 ? 'Medium' : 'High'}'),
                              if (task.dueDate != null)
                                Text('Due: ${task.dueDate?.toLocal().toString().split(' ')[0]}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showAddTaskDialog(context, taskProvider, categoryProvider, task: task);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  taskProvider.deleteTask(task.id!);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, taskProvider, categoryProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider, CategoryProvider categoryProvider, {Task? task}) {
    final TextEditingController titleController = TextEditingController(text: task?.title ?? '');
    final TextEditingController descriptionController = TextEditingController(text: task?.description ?? '');
    int selectedPriority = task?.priority ?? 0;
    int selectedCategoryId = task?.categoryId ?? (categoryProvider.categories.isNotEmpty ? categoryProvider.categories.first.id! : 0);
    DateTime? selectedDueDate = task?.dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task == null ? 'Add New Task' : 'Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<int>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Low')),
                    DropdownMenuItem(value: 1, child: Text('Medium')),
                    DropdownMenuItem(value: 2, child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedPriority = value;
                    }
                  },
                ),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategoryId = value;
                    }
                  },
                ),
                ListTile(
                  title: Text(selectedDueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${selectedDueDate?.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDueDate) {
                      setState(() {
                        selectedDueDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  if (task == null) {
                    taskProvider.addTask(
                      Task(
                        title: titleController.text,
                        description: descriptionController.text,
                        createdAt: DateTime.now(),
                        priority: selectedPriority,
                        categoryId: selectedCategoryId,
                        dueDate: selectedDueDate,
                      ),
                    );
                  } else {
                    task.title = titleController.text;
                    task.description = descriptionController.text;
                    task.priority = selectedPriority;
                    task.categoryId = selectedCategoryId;
                    task.dueDate = selectedDueDate;
                    taskProvider.updateTask(task);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(task == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, CategoryProvider categoryProvider) {
    final TextEditingController categoryNameController = TextEditingController();
    IconData selectedIcon = Icons.folder;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryNameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              // Icon and Color picker can be added here for more advanced options
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  categoryProvider.addCategory(
                    Category(
                      name: categoryNameController.text,
                      icon: selectedIcon, // Default icon
                      color: selectedColor, // Default color
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}


