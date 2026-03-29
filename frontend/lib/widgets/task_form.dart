import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/draft_provider.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormSheet({super.key, this.task});

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  DateTime? _dueDate;
  TaskStatus _status = TaskStatus.todo;
  int? _blockedById;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _titleCtrl = TextEditingController(text: t.title);
      _descCtrl = TextEditingController(text: t.description);
      _dueDate = t.dueDate;
      _status = t.status;
      _blockedById = t.blockedById;
    } else {
      final draft = ref.read(draftProvider);
      _titleCtrl = TextEditingController(text: draft.title);
      _descCtrl = TextEditingController(text: draft.description);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updates = <String, dynamic>{
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'status': _status.value,
          'blocked_by_id': _blockedById,
          if (_dueDate != null) 'due_date': _dueDate,
        };
        await ref
            .read(tasksProvider.notifier)
            .updateTask(widget.task!.id, updates);
      } else {
        await ref.read(tasksProvider.notifier).createTask(
              title: _titleCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              dueDate: _dueDate,
              status: _status,
              blockedById: _blockedById,
            );
        await ref.read(draftProvider.notifier).clear();
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: FlodoColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: FlodoColors.accent,
            surface: FlodoColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(tasksProvider).value ?? [];
    final available = _isEditing
        ? allTasks.where((t) => t.id != widget.task!.id).toList()
        : allTasks;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: FlodoColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding:
            const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: FlodoColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Text(
                      _isEditing ? 'Edit Task' : 'New Task',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title
                _label('Title *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  autofocus: !_isEditing,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      hintText: 'e.g. Write the project report'),
                  onChanged: _isEditing
                      ? null
                      : (v) =>
                          ref.read(draftProvider.notifier).setTitle(v),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                ),
                const SizedBox(height: 16),
                // Description
                _label('Description'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      hintText: 'Add details...'),
                  onChanged: _isEditing
                      ? null
                      : (v) =>
                          ref.read(draftProvider.notifier).setDescription(v),
                ),
                const SizedBox(height: 16),
                // Due Date + Status row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Due Date'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: FlodoColors.surface,
                                border: Border.all(
                                    color: FlodoColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: FlodoColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _dueDate != null
                                          ? DateFormat('MMM d, yyyy')
                                              .format(_dueDate!)
                                          : 'Pick date',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _dueDate != null
                                            ? FlodoColors.textPrimary
                                            : FlodoColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  if (_dueDate != null)
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _dueDate = null),
                                      child: const Icon(Icons.close,
                                          size: 14,
                                          color: FlodoColors.textMuted),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Status'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<TaskStatus>(
                            value: _status,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12)),
                            items: TaskStatus.values
                                .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.label,
                                        style: const TextStyle(
                                            fontSize: 13))))
                                .toList(),
                            onChanged: (v) {
                              if (v != null)
                                setState(() => _status = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Blocked By
                _label('Blocked By'),
                const SizedBox(height: 6),
                DropdownButtonFormField<int?>(
                  value: _blockedById,
                  decoration: const InputDecoration(
                      hintText: 'None',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12)),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('None')),
                    ...available.map((t) => DropdownMenuItem<int?>(
                        value: t.id,
                        child: Text(
                          t.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ))),
                  ],
                  onChanged: (v) => setState(() => _blockedById = v),
                ),
                const SizedBox(height: 28),
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : Text(_isEditing ? 'Save Changes' : 'Create Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FlodoColors.textSecondary,
            letterSpacing: 0.3),
      );
}
