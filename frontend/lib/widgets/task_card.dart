import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../models/task_model.dart';
import 'highlighted_text.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isBlocked;
  final String? blockingTaskTitle;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
    this.blockingTaskTitle,
    required this.searchQuery,
    required this.onTap,
    required this.onDelete,
  });

  Color get _stripColor {
    if (isBlocked) return FlodoColors.blocked;
    return switch (task.status) {
      TaskStatus.todo => FlodoColors.todo,
      TaskStatus.inProgress => FlodoColors.inProgress,
      TaskStatus.done => FlodoColors.done,
    };
  }

  Color get _dueDateColor {
    if (task.dueDate == null) return FlodoColors.textSec;
    final today = DateUtils.dateOnly(DateTime.now());
    final due = DateUtils.dateOnly(task.dueDate!);
    if (due.isBefore(today)) return FlodoColors.danger;
    if (due == today) return FlodoColors.todo;
    return FlodoColors.textSec;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => _confirmDelete(context),
              backgroundColor: FlodoColors.danger,
              foregroundColor: Colors.white,
              icon: LucideIcons.trash2,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isBlocked ? FlodoColors.bg : FlodoColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isBlocked
                  ? FlodoColors.border.withValues(alpha: 0.5)
                  : FlodoColors.border,
            ),
            boxShadow: [
              if (!isBlocked)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              highlightColor: FlodoColors.accent.withValues(alpha: 0.1),
              splashColor: FlodoColors.accent.withValues(alpha: 0.1),
              child: Opacity(
                opacity: isBlocked ? 0.5 : 1.0,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Glow strip
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: _stripColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _stripColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(2, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Main content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: HighlightedText(
                                    text: task.title,
                                    query: searchQuery,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isBlocked
                                          ? FlodoColors.textSec
                                          : FlodoColors.textPrimary,
                                      letterSpacing: -0.3,
                                      height: 1.3,
                                    ),
                                    highlightStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: FlodoColors.accent,
                                      backgroundColor:
                                          FlodoColors.accentSoft,
                                      letterSpacing: -0.3,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: FlodoColors.textSec,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Meta row
                            Row(
                              children: [
                                if (task.dueDate != null) ...[
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 14,
                                    color: _dueDateColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('MMM d').format(task.dueDate!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _dueDateColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                if (isBlocked) ...[
                                  const Icon(LucideIcons.lock,
                                      size: 14, color: FlodoColors.accent),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Blocked by: ${blockingTaskTitle ?? "task"}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: FlodoColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Center-aligned status chip
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width > 600
                                ? 8
                                : 16),
                        child: _StatusChip(
                            status: task.status, isBlocked: isBlocked),
                      ),
                    ),
                    // Desktop visible delete button
                    if (MediaQuery.of(context).size.width > 600)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            onPressed: () => _confirmDelete(context),
                            icon: const Icon(LucideIcons.trash2),
                            color: FlodoColors.textHint,
                            hoverColor: FlodoColors.dangerSoft,
                            tooltip: 'Delete',
                          ),
                        ),
                      ),
                    // Drag handle on the far right
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, left: 4),
                        child: Icon(
                          LucideIcons.gripVertical,
                          size: 18,
                          color: FlodoColors.textHint.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          '"${task.title}" will be permanently deleted.',
          style: const TextStyle(color: FlodoColors.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: FlodoColors.textSec),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: FlodoColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  final bool isBlocked;

  const _StatusChip({required this.status, required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    if (isBlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: FlodoColors.bg,
          border: Border.all(color: FlodoColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.lock, size: 12, color: FlodoColors.textSec),
            SizedBox(width: 6),
            Text(
              'Blocked',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FlodoColors.textSec,
              ),
            ),
          ],
        ),
      );
    }

    final (Color color, Color bg, String lbl, IconData icon) = switch (status) {
      TaskStatus.todo => (
          FlodoColors.textPrimary,
          FlodoColors.todoSoft,
          'To-Do',
          LucideIcons.circleDashed
        ),
      TaskStatus.inProgress => (
          FlodoColors.inProgress,
          FlodoColors.inProgressSoft,
          'In\u00A0Progress',
          LucideIcons.clock3
        ),
      TaskStatus.done => (
          FlodoColors.done,
          FlodoColors.doneSoft,
          'Done',
          LucideIcons.checkCircle2
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            lbl,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
