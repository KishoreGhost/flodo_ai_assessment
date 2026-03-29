import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

// ── Repository ────────────────────────────────────────────────────
final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository());

// ── Filters ───────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

// ── Main Tasks Notifier ───────────────────────────────────────────
class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final q = ref.watch(searchQueryProvider);
    return ref
        .read(taskRepositoryProvider)
        .getTasks(q: q.isEmpty ? null : q);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> createTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    TaskStatus status = TaskStatus.todo,
    int? blockedById,
  }) async {
    final task = await ref.read(taskRepositoryProvider).createTask(
          title: title,
          description: description,
          dueDate: dueDate,
          status: status,
          blockedById: blockedById,
        );
    final currentTasks = state.value;
    if (currentTasks != null) {
      state = AsyncData([...currentTasks, task]);
    }
  }

  Future<void> updateTask(int id, Map<String, dynamic> updates) async {
    final updated =
        await ref.read(taskRepositoryProvider).updateTask(id, updates);
    final currentTasks = state.value;
    if (currentTasks != null) {
      state = AsyncData(
          currentTasks.map((t) => t.id == id ? updated : t).toList());
    }
  }

  Future<void> deleteTask(int id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
    final currentTasks = state.value;
    if (currentTasks != null) {
      state = AsyncData(currentTasks.where((t) => t.id != id).toList());
    }
  }

  Future<void> reorderTasks(List<Task> reordered) async {
    // Optimistic update
    state = AsyncData(reordered);
    // Persist positions
    final items = reordered
        .asMap()
        .entries
        .map((e) => {'id': e.value.id, 'position': e.key})
        .toList();
    await ref.read(taskRepositoryProvider).reorderTasks(items);
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

// ── Filtered view (status filter applied locally) ─────────────────
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final filter = ref.watch(statusFilterProvider);
  return tasksAsync.whenData((tasks) {
    if (filter == null) return tasks;
    return tasks.where((t) => t.status == filter).toList();
  });
});
