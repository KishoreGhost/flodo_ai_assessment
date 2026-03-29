import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(statusFilterProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final allTasks = tasksAsync.value ?? [];

    Map<TaskStatus, int> counts = {
      for (final s in TaskStatus.values)
        s: allTasks.where((t) => t.status == s).length,
    };

    return Container(
      width: 220,
      color: FlodoColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: FlodoColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Flodo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SidebarItem(
              icon: Icons.format_list_bulleted_rounded,
              label: 'My Tasks',
              count: allTasks.length,
              isSelected: statusFilter == null,
              onTap: () =>
                  ref.read(statusFilterProvider.notifier).state = null,
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                'STATUS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...TaskStatus.values.map((s) {
              final color = s == TaskStatus.todo
                  ? FlodoColors.todo
                  : s == TaskStatus.inProgress
                      ? FlodoColors.inProgress
                      : FlodoColors.done;
              return _SidebarItem(
                icon: s == TaskStatus.todo
                    ? Icons.radio_button_unchecked
                    : s == TaskStatus.inProgress
                        ? Icons.timelapse_rounded
                        : Icons.check_circle_outline_rounded,
                label: s.label,
                count: counts[s],
                isSelected: statusFilter == s,
                statusColor: color,
                onTap: () =>
                    ref.read(statusFilterProvider.notifier).state = s,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final bool isSelected;
  final Color? statusColor;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.count,
    required this.isSelected,
    this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? FlodoColors.sidebarHover
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: statusColor ??
                  (isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (count != null && count! > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
