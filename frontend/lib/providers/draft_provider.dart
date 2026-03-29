import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskDraft {
  final String title;
  final String description;

  const TaskDraft({this.title = '', this.description = ''});
}

class DraftNotifier extends Notifier<TaskDraft> {
  static const _titleKey = 'draft_title';
  static const _descKey = 'draft_description';

  @override
  TaskDraft build() {
    // Fire-and-forget async load; updates state when prefs are ready
    SharedPreferences.getInstance().then((prefs) {
      final t = prefs.getString(_titleKey) ?? '';
      final d = prefs.getString(_descKey) ?? '';
      if (t.isNotEmpty || d.isNotEmpty) {
        state = TaskDraft(title: t, description: d);
      }
    });
    return const TaskDraft();
  }

  Future<void> setTitle(String title) async {
    state = TaskDraft(title: title, description: state.description);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_titleKey, title);
  }

  Future<void> setDescription(String desc) async {
    state = TaskDraft(title: state.title, description: desc);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_descKey, desc);
  }

  Future<void> clear() async {
    state = const TaskDraft();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_titleKey);
    await prefs.remove(_descKey);
  }
}

final draftProvider =
    NotifierProvider<DraftNotifier, TaskDraft>(DraftNotifier.new);
