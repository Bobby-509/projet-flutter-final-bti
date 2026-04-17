import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/task_card.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';
import 'statistics_screen.dart';
import '../delegates/task_search_delegate.dart';

enum SortType {
  dateDesc,
  dateAsc,
  statutEnCours,
  statutTermine,
  statutEnRetard,
  categorieAZ,
  categorieZA,
}

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
  SortType currentSort = SortType.dateDesc;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await DatabaseService.instance.getTasks();
    setState(() {
      allTasks = data;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Task> filtered = allTasks.where((task) {
      final matchesSearch = searchQuery.isEmpty ||
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
      case SortType.dateDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.dateAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortType.statutEnCours:
        list.sort((a, b) {
          if (!a.isDone && b.isDone) return -1;
          if (a.isDone && !b.isDone) return 1;
          return 0;
        });
        break;
      case SortType.statutTermine:
        list.sort((a, b) {
          if (a.isDone && !b.isDone) return -1;
          if (!a.isDone && b.isDone) return 1;
          return 0;
        });
        break;
      case SortType.statutEnRetard:
        bool isLate(Task t) =>
            !t.isDone &&
                t.dueDate != null &&
                t.dueDate!.isBefore(DateTime.now());
        list.sort((a, b) {
          if (isLate(a) && !isLate(b)) return -1;
          if (!isLate(a) && isLate(b)) return 1;
          return 0;
        });
        break;
      case SortType.categorieAZ:
        list.sort((a, b) => a.category.compareTo(b.category));
        break;
      case SortType.categorieZA:
        list.sort((a, b) => b.category.compareTo(a.category));
        break;
    }
  }

  void _changeSort(SortType type) {
    currentSort = type;
    _applyFilters();
  }

  // ── Sort Bottom Sheet ──────────────────────────────────────────────────────

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Titre général
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'Trier les tâches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Section Date ──
                  _sectionHeader('Par date'),
                  _sortTile('Plus récente → ancienne', SortType.dateDesc,
                      setSheetState),
                  _sortTile('Plus ancienne → récente', SortType.dateAsc,
                      setSheetState),

                  const Divider(indent: 16, endIndent: 16),

                  // ── Section Statut ──
                  _sectionHeader('Par statut'),
                  _sortTile(
                      'En cours en premier', SortType.statutEnCours, setSheetState),
                  _sortTile(
                      'Terminées en premier', SortType.statutTermine, setSheetState),
                  _sortTile(
                      'En retard en premier', SortType.statutEnRetard, setSheetState),

                  const Divider(indent: 16, endIndent: 16),

                  // ── Section Catégorie ──
                  _sectionHeader('Par catégorie'),
                  _sortTile('A → Z', SortType.categorieAZ, setSheetState),
                  _sortTile('Z → A', SortType.categorieZA, setSheetState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sortTile(String label, SortType type, StateSetter setSheetState) {
    final isActive = currentSort == type;
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? Theme.of(context).primaryColor : null,
        ),
      ),
      leading: Icon(
        isActive ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        size: 20,
      ),
      onTap: () {
        setSheetState(() {}); // met à jour la radio dans le sheet
        _changeSort(type);
        Navigator.pop(context);
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

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
        builder: (_) => TaskFormScreen(),
      ),
    );

// ✅ ICI tu récupères le message
    if (result != null && result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
          // Icône tri avec badge si tri actif (non-default)
          IconButton(
            icon: Badge(
              isLabelVisible: currentSort != SortType.dateDesc,
              child: const Icon(Icons.sort),
            ),
            tooltip: 'Trier',
            onPressed: _openSortSheet,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'stats') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StatisticsScreen(tasks: allTasks),
                  ),
                );
              } else if (value == 'logout') {
                await _logout();
              }
            },
            itemBuilder: (_) => [
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
              ),
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
          ? const Center(child: Text('Aucune tâche pour l\'instant'))
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