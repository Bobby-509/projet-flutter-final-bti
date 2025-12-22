import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/task_card.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';
import 'statistics_screen.dart';
import '../delegates/task_search_delegate.dart';

enum SortType { date, statut, categorie }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> allTasks = [];
  List<Task> tasks = [];

  String searchQuery = '';
  String selectedCategory = 'Toutes';
  SortType currentSort = SortType.date;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await DatabaseService.instance.getTasks();
    setState(() {
      allTasks = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Task> filtered = allTasks.where((task) {
      final matchesSearch =
      task.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'Toutes' || task.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    _sortTasks(filtered);

    setState(() {
      tasks = filtered;
    });
  }

  void _sortTasks(List<Task> list) {
    switch (currentSort) {
      case SortType.date:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.statut:
        list.sort((a, b) => a.isDone ? 1 : -1);
        break;
      case SortType.categorie:
        list.sort((a, b) => a.category.compareTo(b.category));
        break;
    }
  }

  Future<void> _confirmDelete(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteTask(task.id!);
      _loadTasks();
    }
  }

  void _toggleDone(Task task) async {
    task.isDone = !task.isDone;
    await DatabaseService.instance.updateTask(task);
    _loadTasks();
  }

  Future<void> _openForm([Task? task]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );


    if (result == true) {
      _loadTasks();
    }
  }


  void _openSearch() async {
    final result = await showSearch<String>(
      context: context,
      delegate: TaskSearchDelegate(allTasks),
    );

    if (result != null) {
      searchQuery = result;
      _applyFilters();
    }
  }

  void _changeSort(SortType type) {
    setState(() {
      currentSort = type;
      _applyFilters();
    });
  }
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<String>(
          onSelected: (_) {},
          itemBuilder: (_) => [],
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mes Tâches'),
              SizedBox(width: 4),
              //Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'date':
                  _changeSort(SortType.date);
                  break;

                case 'statut':
                  _changeSort(SortType.statut);
                  break;

                case 'categorie':
                  _changeSort(SortType.categorie);
                  break;

                case 'stats':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatisticsScreen(tasks: allTasks),
                    ),
                  );
                  break;

                case 'logout':
                  await _logout();
                  break;
              }
            },

            // onSelected: (value) {
            //   if (value == 'date') _changeSort(SortType.date);
            //   if (value == 'statut') _changeSort(SortType.statut);
            //   if (value == 'categorie') _changeSort(SortType.categorie);
            //   if (value == 'stats') {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => StatisticsScreen(tasks: allTasks),
            //       ),
            //     );
            //   }
            // },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'date',
                child: Text('Trier par date'),
              ),
              const PopupMenuItem(
                value: 'statut',
                child: Text('Trier par statut'),
              ),
              const PopupMenuItem(
                value: 'categorie',
                child: Text('Trier par catégorie'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'stats',
                child: Text('Statistiques'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
              )
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: ['Toutes', 'Travail', 'Personnel', 'Urgent']
                  .map(
                    (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ),
              )
                  .toList(),
              onChanged: (value) {
                selectedCategory = value!;
                _applyFilters();
              },
            ),
          ),
        ),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Aucune tâche pour l’instant'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onToggle: () => _toggleDone(task),
            onEdit: () => _openForm(task),
            onDelete: () => _confirmDelete(task),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
