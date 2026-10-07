import 'package:flutter/material.dart';

import '../theme/lock_in_theme.dart';
import '../widgets/lock_in_card.dart';
import '../widgets/page_header.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<_Task> _tasks = [
    _Task('Deep work — 90 min', 'FOCUS', true),
    _Task('Gym session', 'HEALTH', true),
    _Task('Read 20 pages', 'LEARN', false),
    _Task('No doomscrolling', 'DISCIPLINE', false),
    _Task('Plan tomorrow', 'FOCUS', false),
    _Task('Sleep by 23:00', 'HEALTH', false),
  ];

  Future<void> _showAddTaskDialog() async {
    var enteredTitle = '';
    final taskTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add task'),
        content: TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'What do you need to do?',
          ),
          onChanged: (value) => enteredTitle = value,
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, enteredTitle.trim()),
            child: const Text('ADD TASK'),
          ),
        ],
      ),
    );
    if (taskTitle == null || taskTitle.isEmpty || !mounted) return;
    setState(() => _tasks.add(_Task(taskTitle, 'CUSTOM', false)));
  }

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((task) => task.done).length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeader(title: 'TASKS.', sub: 'STAY LOCKED IN'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              LockInCard(
                child: Row(children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(alignment: Alignment.center, children: [
                      CircularProgressIndicator(
                        value: _tasks.isEmpty ? 0 : done / _tasks.length,
                        strokeWidth: 3,
                        backgroundColor: LockInColors.surfaceAlt,
                        color: LockInColors.white,
                      ),
                      Text(
                        '$done/${_tasks.length}',
                        style: dot(11, weight: FontWeight.w700),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY\'S PROGRESS',
                          style: dot(9, color: LockInColors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          done == _tasks.length
                              ? 'ALL DONE. REST.'
                              : 'KEEP GOING.',
                          style: dot(16, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              ..._tasks.map(_taskTile),
              const SizedBox(height: 8),
              _addButton(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _taskTile(_Task task) {
    return GestureDetector(
      onTap: () => setState(() => task.done = !task.done),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LockInColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LockInColors.line),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: task.done ? LockInColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: task.done ? LockInColors.white : LockInColors.darkGrey,
                width: 1.5,
              ),
            ),
            child: task.done
                ? const Icon(Icons.check, size: 16, color: LockInColors.bg)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              task.title.toUpperCase(),
              style: dot(
                12,
                weight: FontWeight.w700,
                color: task.done ? LockInColors.darkGrey : LockInColors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LockInColors.line),
            ),
            child: Text(task.tag, style: dot(8, color: LockInColors.grey)),
          ),
        ]),
      ),
    );
  }

  Widget _addButton() => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddTaskDialog,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: LockInColors.darkGrey),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 18, color: LockInColors.grey),
                const SizedBox(width: 8),
                Text(
                  'ADD TASK',
                  style: dot(
                    11,
                    color: LockInColors.grey,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Task {
  String title;
  String tag;
  bool done;

  _Task(this.title, this.tag, this.done);
}
