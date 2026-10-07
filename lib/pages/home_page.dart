import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/daily_exercise_service.dart';
import '../theme/lock_in_theme.dart';
import '../widgets/lock_in_card.dart';
import '../widgets/page_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _waterGoalMl = 2000;
  static const _waterDateKey = 'lock_in_water_date';
  static const _waterAmountKey = 'lock_in_water_amount';

  int _waterMl = 0;
  bool _waterLoaded = false;
  bool _exerciseLoading = true;
  String? _exerciseError;
  List<ExerciseInstruction> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadWater();
    _loadExercises();
  }

  Future<void> _loadWater() async {
    final preferences = await SharedPreferences.getInstance();
    final today = _dateStamp(DateTime.now());
    if (preferences.getString(_waterDateKey) != today) {
      final savedDate = await preferences.setString(_waterDateKey, today);
      final savedAmount = await preferences.setInt(_waterAmountKey, 0);
      if (!savedDate || !savedAmount) {
        throw StateError('Today\'s water intake could not be saved.');
      }
    }
    final amount = preferences.getInt(_waterAmountKey) ?? 0;
    if (!mounted) return;
    setState(() {
      _waterMl = amount;
      _waterLoaded = true;
    });
  }

  Future<void> _loadExercises() async {
    setState(() {
      _exerciseLoading = true;
      _exerciseError = null;
    });
    try {
      final exercises = await DailyExerciseService.loadForToday();
      if (!mounted) return;
      setState(() {
        _exercises = exercises;
        _exerciseLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _exerciseError = error.toString();
        _exerciseLoading = false;
      });
    }
  }

  Future<void> _showAddWaterDialog() async {
    var enteredAmount = '250';
    final formKey = GlobalKey<FormState>();
    final amount = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add water'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: enteredAmount,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => enteredAmount = value,
            decoration: const InputDecoration(
              labelText: 'Amount in millilitres',
              suffixText: 'ml',
            ),
            validator: (value) {
              final parsed = int.tryParse(value ?? '');
              return parsed == null || parsed <= 0
                  ? 'Enter an amount greater than zero.'
                  : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, int.parse(enteredAmount));
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
    if (amount == null) return;

    final preferences = await SharedPreferences.getInstance();
    final updatedAmount = _waterMl + amount;
    final saved = await preferences.setInt(_waterAmountKey, updatedAmount);
    if (!saved) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Water intake could not be saved.')),
        );
      }
      return;
    }
    if (mounted) setState(() => _waterMl = updatedAmount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeader(title: 'LOCK IN.', sub: 'GOOD MORNING'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _waterCard(),
                const SizedBox(height: 16),
                _focusCard(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TODAY\'S WORKOUT',
                        style: dot(12, weight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: _exerciseLoading ? null : _loadExercises,
                      tooltip: 'Refresh exercises',
                      icon: const Icon(Icons.refresh, size: 18),
                    ),
                  ],
                ),
                if (_exerciseLoading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )
                else if (_exerciseError != null)
                  _exerciseErrorCard()
                else ...[
                  for (var index = 0; index < _exercises.length; index++)
                    _exerciseTile(_exercises[index], index),
                  const SizedBox(height: 6),
                  Text(
                    'EXERCISES: WGER · CC BY-SA 4.0',
                    style: dot(8, color: LockInColors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _waterCard() {
    final progress = (_waterMl / _waterGoalMl).clamp(0.0, 1.0);
    return LockInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: LockInColors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('WATER INTAKE',
                    style: dot(10, color: LockInColors.grey)),
              ),
              Text('DAILY GOAL', style: dot(8, color: LockInColors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _waterLoaded ? '$_waterMl' : '—',
                style: dot(26, weight: FontWeight.w700),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 3),
                child: Text(
                  'ML / $_waterGoalMl ML',
                  style: dot(9, color: LockInColors.grey),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: dot(11, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: _waterLoaded ? progress : 0,
              minHeight: 10,
              backgroundColor: LockInColors.surfaceAlt,
              color: LockInColors.white,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _waterLoaded ? _showAddWaterDialog : null,
              icon: const Icon(Icons.add, size: 17),
              label: Text('ADD WATER', style: dot(10, weight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _focusCard() => LockInCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: LockInColors.white, width: 1.5),
              ),
              child:
                  const Icon(Icons.timer_outlined, color: LockInColors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FOCUS SESSIONS',
                      style: dot(9, color: LockInColors.grey)),
                  const SizedBox(height: 4),
                  Text('6 / 8 TODAY', style: dot(16, weight: FontWeight.w700)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: LockInColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'START',
                style: dot(10, color: LockInColors.bg, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

  Widget _exerciseErrorCard() => LockInCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WORKOUTS UNAVAILABLE',
                style: dot(10, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Could not load today\'s instructions. Check your connection and try again.',
              style: dot(10, color: LockInColors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadExercises,
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      );

  Widget _exerciseTile(ExerciseInstruction exercise, int index) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LockInColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LockInColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '0${index + 1}',
                  style: dot(10, color: LockInColors.grey),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exercise.name.toUpperCase(),
                    style: dot(11, weight: FontWeight.w700),
                  ),
                ),
                Text(
                  exercise.category.toUpperCase(),
                  style: dot(8, color: LockInColors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              exercise.instructions,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: dot(10, color: LockInColors.grey),
            ),
          ],
        ),
      );

  static String _dateStamp(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
