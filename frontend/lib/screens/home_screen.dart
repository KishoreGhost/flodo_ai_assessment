import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = q;
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  Future<void> _showForm({Task? task}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    final body = _Content(
      searchCtrl: _searchCtrl,
      onSearch: _onSearch,
      onClear: _clearSearch,
      onAdd: () => _showForm(),
      onEdit: (t) => _showForm(task: t),
      isWide: isWide,
      scaffoldKey: _scaffoldKey,
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
          backgroundColor: FlodoColors.sidebar, child: AppSidebar()),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: FlodoColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _Content extends ConsumerWidget {
  final TextEditingController searchCtrl;
  final void Function(String) onSearch;
  final VoidCallback onClear;
  final VoidCallback onAdd;
  final void Function(Task) onEdit;
  final bool isWide;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _Content({
    required this.searchCtrl,
    required this.onSearch,
    required this.onClear,
    required this.onAdd,
    required this.onEdit,
    required this.isWide,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTasksProvider);
    final allTasksAsync = ref.watch(tasksProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final allTasks = allTasksAsync.value ?? [];
    final hp = isWide ? 32.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── App Bar ───────────────────────────────────────────────
        Container(
          color: FlodoColors.background,
          padding: EdgeInsets.fromLTRB(
              hp, MediaQuery.of(context).padding.top + 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (!isWide)
                    GestureDetector(
                      onTap: () => scaffoldKey.currentState?.openDrawer(),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.menu_rounded,
                            color: FlodoColors.textPrimary, size: 22),
                      ),
                    ),
                  Expanded(
                    child: const Text(
                      'My Tasks',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: FlodoColors.textPrimary),
                    ),
                  ),
                  if (isWide)
                    FilledButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Task',
                          style: TextStyle(fontSize: 13)),
                      style: FilledButton.styleFrom(
                          backgroundColor: FlodoColors.accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10)),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              TextField(
                controller: searchCtrl,
                onChanged: onSearch,
                style: const TextStyle(
                    fontSize: 14, color: FlodoColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: const TextStyle(
                      color: FlodoColors.textMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: FlodoColors.textMuted, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: FlodoColors.textMuted),
                          onPressed: onClear)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              // Status filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip(ref, null, 'All', statusFilter == null),
                    ...TaskStatus.values.map(
                        (s) => _chip(ref, s, s.label, statusFilter == s)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Task list ─────────────────────────────────────────────
        Expanded(
          child: filtered.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: FlodoColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Could not connect to server',
                      style: const TextStyle(
                          color: FlodoColors.textSecondary, fontSize: 15)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(tasksProvider),
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
            data: (tasks) {
              if (tasks.isEmpty) {
                return _EmptyState(
                    searchQuery: searchQuery, statusFilter: statusFilter);
              }
              return ReorderableListView.builder(
                padding:
                    EdgeInsets.fromLTRB(hp, 8, hp, 100),
                itemCount: tasks.length,
                onReorder: (oldIdx, newIdx) {
                  if (newIdx > oldIdx) newIdx--;
                  final list = [...tasks];
                  final item = list.removeAt(oldIdx);
                  list.insert(newIdx, item);
                  ref.read(tasksProvider.notifier).reorderTasks(list);
                },
                proxyDecorator: (child, idx, anim) => Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  shadowColor: Colors.black26,
                  child: child,
                ),
                itemBuilder: (ctx, i) {
                  final task = tasks[i];
                  Task? blocker;
                  if (task.blockedById != null) {
                    try {
                      final found = allTasks
                          .firstWhere((t) => t.id == task.blockedById);
                      blocker = found;
                    } catch (_) {}
                  }
                  final isBlocked =
                      blocker != null && blocker.status != TaskStatus.done;

                  return TaskCard(
                    key: ValueKey(task.id),
                    task: task,
                    isBlocked: isBlocked,
                    blockingTaskTitle: blocker?.title,
                    searchQuery: searchQuery,
                    onTap: () => onEdit(task),
                    onDelete: () =>
                        ref.read(tasksProvider.notifier).deleteTask(task.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(WidgetRef ref, TaskStatus? status, String label, bool sel) {
    final color = status == null
        ? FlodoColors.accent
        : status == TaskStatus.todo
            ? FlodoColors.todo
            : status == TaskStatus.inProgress
                ? FlodoColors.inProgress
                : FlodoColors.done;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? Colors.white : FlodoColors.textSecondary)),
        selected: sel,
        onSelected: (_) =>
            ref.read(statusFilterProvider.notifier).state = status,
        selectedColor: color,
        backgroundColor: FlodoColors.surface,
        side: BorderSide(color: sel ? color : FlodoColors.border),
        showCheckmark: false,
        padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        labelPadding:
            const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String searchQuery;
  final TaskStatus? statusFilter;

  const _EmptyState({required this.searchQuery, this.statusFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded,
              size: 60,
              color: FlodoColors.textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? 'No tasks match "$searchQuery"'
                : statusFilter != null
                    ? 'No ${statusFilter!.label} tasks'
                    : 'No tasks yet',
            style: const TextStyle(
                color: FlodoColors.textSecondary, fontSize: 15),
          ),
          if (searchQuery.isEmpty && statusFilter == null) ...[
            const SizedBox(height: 6),
            const Text('Tap + to create your first task',
                style: TextStyle(
                    color: FlodoColors.textMuted, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
