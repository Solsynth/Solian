import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/fitness_service.dart';
import 'package:island/fitness/fitness_data.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

class FitnessActivityScreen extends HookConsumerWidget {
  const FitnessActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fitnessService = ref.watch(fitnessServiceProvider);
    final selectedDate = useState(DateTime.now());
    final workouts = useState<List<FitnessWorkout>>([]);
    final isLoading = useState(false);
    final hasPermission = useState(false);
    final isDataAvailable = useState(false);

    // Load initial data
    useEffect(() {
      _loadData(
        fitnessService,
        selectedDate.value,
        workouts,
        isLoading,
        hasPermission,
        isDataAvailable,
      );
      return null;
    }, []);

    return AppScaffold(
      appBar: AppBar(
        title: Text('fitnessActivity').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () {
              _loadData(
                fitnessService,
                selectedDate.value,
                workouts,
                isLoading,
                hasPermission,
                isDataAvailable,
              );
            },
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: isLoading.value
          ? _buildLoadingView()
          : _buildMainContent(
              context,
              fitnessService,
              selectedDate,
              workouts,
              hasPermission,
              isDataAvailable,
              (date) {
                selectedDate.value = date;
                _loadData(
                  fitnessService,
                  date,
                  workouts,
                  isLoading,
                  hasPermission,
                  isDataAvailable,
                );
              },
            ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('loadingFitnessData').tr(),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    FitnessService fitnessService,
    ValueNotifier<DateTime> selectedDate,
    ValueNotifier<List<FitnessWorkout>> workouts,
    ValueNotifier<bool> hasPermission,
    ValueNotifier<bool> isDataAvailable,
    ValueChanged<DateTime> onDateSelected,
  ) {
    if (!fitnessService.isPlatformSupported) {
      return _buildUnsupportedPlatformView();
    }

    if (!hasPermission.value) {
      return _buildPermissionDeniedView(fitnessService);
    }

    if (!isDataAvailable.value) {
      return _buildNoDataView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar View
          _buildCalendarView(
            context,
            selectedDate,
            workouts.value,
            onDateSelected,
          ),
          const SizedBox(height: 24),

          // Summary Cards
          _buildSummaryCards(workouts.value),
          const SizedBox(height: 24),

          // Selected Date Workouts
          _buildSelectedDateWorkouts(
            selectedDate.value,
            workouts.value,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedPlatformView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.fitness_center, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'fitnessDataNotAvailable',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            'fitnessDataNotAvailableDescription',
            textAlign: TextAlign.center,
          ).tr(),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(FitnessService fitnessService) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.block, size: 64, color: Colors.red[600]),
          const SizedBox(height: 16),
          Text(
            'fitnessPermissionRequired',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            'fitnessPermissionRequiredDescription',
            textAlign: TextAlign.center,
          ).tr(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Symbols.settings),
            label: Text('requestPermission').tr(),
            onPressed: () async {
              final granted = await fitnessService.requestPermissions();
              if (granted) {
                // Reload data
                // This would need to be handled by the parent widget
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.fitness_center, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'noFitnessData',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).tr(),
          const SizedBox(height: 8),
          Text('noFitnessDataDescription', textAlign: TextAlign.center).tr(),
        ],
      ),
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    ValueNotifier<DateTime> selectedDate,
    List<FitnessWorkout> workouts,
    ValueChanged<DateTime> onDateSelected,
  ) {
    // Create a map of dates with workout data
    final workoutData = <DateTime, List<FitnessWorkout>>{};
    for (final workout in workouts) {
      final date = DateTime(
        workout.startTime.year,
        workout.startTime.month,
        workout.startTime.day,
      );
      if (!workoutData.containsKey(date)) {
        workoutData[date] = [];
      }
      workoutData[date]!.add(workout);
    }

    return Card(
      child: TableCalendar<FitnessWorkout>(
        firstDay: DateTime(2020),
        lastDay: DateTime.now(),
        focusedDay: selectedDate.value,
        selectedDayPredicate: (day) {
          return isSameDay(day, selectedDate.value);
        },
        onDaySelected: (selectedDay, focusedDay) {
          onDateSelected(selectedDay);
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (workoutData.containsKey(date)) {
              final dailyWorkouts = workoutData[date]!;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: _buildFitnessMarker(dailyWorkouts),
              );
            }
            return null;
          },
          todayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<FitnessWorkout> workouts) {
    if (workouts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate summary statistics
    final totalWorkouts = workouts.length;
    final totalDuration = workouts.fold(
      Duration.zero,
      (sum, workout) => sum + workout.endTime.difference(workout.startTime),
    );
    final totalCalories = workouts.fold(
      0.0,
      (sum, workout) => sum + (workout.totalEnergyBurned ?? 0),
    );
    final totalDistance = workouts.fold(
      0.0,
      (sum, workout) => sum + (workout.totalDistance ?? 0),
    );
    final totalSteps = workouts.fold(
      0.0,
      (sum, workout) => sum + (workout.totalSteps ?? 0),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSummaryCard(
          icon: Symbols.fitness_center,
          title: 'totalWorkouts',
          value: totalWorkouts.toString(),
          color: Colors.blue,
        ),
        _buildSummaryCard(
          icon: Symbols.timer,
          title: 'totalDuration',
          value: _formatDuration(totalDuration),
          color: Colors.green,
        ),
        _buildSummaryCard(
          icon: Symbols.local_fire_department,
          title: 'totalCalories',
          value: '${totalCalories.toInt()} kcal',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ).tr(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateWorkouts(
    DateTime selectedDate,
    List<FitnessWorkout> workouts,
    BuildContext context,
  ) {
    // Filter workouts for selected date
    final dateWorkouts = workouts.where((workout) {
      final workoutDate = DateTime(
        workout.startTime.year,
        workout.startTime.month,
        workout.startTime.day,
      );
      return isSameDay(workoutDate, selectedDate);
    }).toList();

    if (dateWorkouts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Symbols.calendar_month, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'noWorkoutsOnDate',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ).tr(args: [DateFormat('MMM d, yyyy').format(selectedDate)]),
              const SizedBox(height: 8),
              Text('noWorkoutsOnDateDescription').tr(),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'workoutsOnDate',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ).tr(args: [DateFormat('MMM d, yyyy').format(selectedDate)]),
          ),
          const Divider(height: 1),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dateWorkouts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final workout = dateWorkouts[index];
              return ListTile(
                leading: _getWorkoutIcon(workout.workoutType),
                title: Text(workout.workoutTypeString),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('HH:mm').format(workout.startTime)} - ${DateFormat('HH:mm').format(workout.endTime)}',
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (workout.energyBurnedString.isNotEmpty)
                            _buildStatChip(
                              icon: Symbols.local_fire_department,
                              text: workout.energyBurnedString,
                              color: Colors.orange,
                            ),
                          if (workout.distanceString.isNotEmpty)
                            _buildStatChip(
                              icon: Symbols.straighten,
                              text: workout.distanceString,
                              color: Colors.blue,
                            ),
                          if (workout.stepsString.isNotEmpty)
                            _buildStatChip(
                              icon: Symbols.directions_walk,
                              text: '${workout.stepsString} steps',
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: Text(workout.durationString),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _getWorkoutIcon(HealthWorkoutActivityType type) {
    switch (type) {
      case HealthWorkoutActivityType.RUNNING:
        return const Icon(Symbols.directions_run, color: Colors.blue);
      case HealthWorkoutActivityType.WALKING:
        return const Icon(Symbols.directions_walk, color: Colors.green);
      case HealthWorkoutActivityType.BIKING:
        return const Icon(Symbols.directions_bike, color: Colors.orange);
      case HealthWorkoutActivityType.SWIMMING:
        return const Icon(Symbols.pool, color: Colors.cyan);
      case HealthWorkoutActivityType.STRENGTH_TRAINING:
      case HealthWorkoutActivityType.WEIGHTLIFTING:
        return const Icon(Symbols.fitness_center, color: Colors.red);
      case HealthWorkoutActivityType.YOGA:
        return const Icon(Symbols.self_improvement, color: Colors.purple);
      default:
        return const Icon(Symbols.fitness_center, color: Colors.grey);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildFitnessMarker(List<FitnessWorkout> workouts) {
    // If no workouts, show nothing
    if (workouts.isEmpty) {
      return const SizedBox.shrink();
    }

    // For better visibility, we'll use a simple colored dot with workout count
    // This is more visible than the complex ring for small calendar cells
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Text(
          workouts.length.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

Future<void> _loadData(
  FitnessService fitnessService,
  DateTime date,
  ValueNotifier<List<FitnessWorkout>> workouts,
  ValueNotifier<bool> isLoading,
  ValueNotifier<bool> hasPermission,
  ValueNotifier<bool> isDataAvailable,
) async {
  isLoading.value = true;

  try {
    // Check platform support
    if (!fitnessService.isPlatformSupported) {
      hasPermission.value = false;
      isDataAvailable.value = false;
      workouts.value = [];
      return;
    }

    // Check permissions
    final permissionStatus = await fitnessService.getPermissionStatus();
    hasPermission.value = permissionStatus == FitnessPermissionStatus.granted;

    if (!hasPermission.value) {
      isDataAvailable.value = false;
      workouts.value = [];
      return;
    }

    // Get workouts for the last 30 days to populate calendar
    final allWorkouts = await fitnessService.getWorkoutsLast30Days();
    workouts.value = allWorkouts;
    isDataAvailable.value = allWorkouts.isNotEmpty;
  } catch (e) {
    showErrorAlert(e);
    workouts.value = [];
    isDataAvailable.value = false;
  } finally {
    isLoading.value = false;
  }
}

/// A fitness ring marker that shows workout progress for a specific day
class FitnessRingMarker extends StatelessWidget {
  final List<FitnessWorkout> workouts;
  final double size;

  const FitnessRingMarker({super.key, required this.workouts, this.size = 24});

  @override
  Widget build(BuildContext context) {
    // Calculate total stats for the day
    final totalDuration = workouts.fold(
      Duration.zero,
      (sum, workout) => sum + workout.endTime.difference(workout.startTime),
    );
    final totalCalories = workouts.fold(
      0.0,
      (sum, workout) => sum + (workout.totalEnergyBurned ?? 0),
    );
    final totalDistance = workouts.fold(
      0.0,
      (sum, workout) => sum + (workout.totalDistance ?? 0),
    );
    final totalSteps = workouts.fold(
      0.0,
      (sum, workout) => sum + (workout.totalSteps ?? 0),
    );

    // Calculate progress percentages (with some reasonable goals)
    final durationProgress = _calculateDurationProgress(totalDuration);
    final caloriesProgress = _calculateCaloriesProgress(totalCalories);
    final stepsProgress = _calculateStepsProgress(totalSteps);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background ring (Steps)
        _buildRing(
          progress: stepsProgress,
          color: Colors.green,
          width: 3,
          size: size,
          isBackground: true,
        ),
        // Middle ring (Calories)
        _buildRing(
          progress: caloriesProgress,
          color: Colors.orange,
          width: 3,
          size: size - 4,
          isBackground: true,
        ),
        // Inner ring (Duration)
        _buildRing(
          progress: durationProgress,
          color: Colors.blue,
          width: 3,
          size: size - 8,
          isBackground: false,
        ),
        // Center indicator
        _buildCenterIndicator(workouts.length),
      ],
    );
  }

  Widget _buildRing({
    required double progress,
    required Color color,
    required double width,
    required double size,
    required bool isBackground,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: FitnessRingPainter(
        progress: progress,
        color: color,
        width: width,
        isBackground: isBackground,
      ),
    );
  }

  Widget _buildCenterIndicator(int workoutCount) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Text(
          workoutCount.toString(),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  double _calculateDurationProgress(Duration duration) {
    // Goal: 30 minutes of exercise per day
    final goalMinutes = 30.0;
    final actualMinutes = duration.inMinutes.toDouble();
    return (actualMinutes / goalMinutes).clamp(0.0, 1.0);
  }

  double _calculateCaloriesProgress(double calories) {
    // Goal: 250 calories burned per day
    final goalCalories = 250.0;
    return (calories / goalCalories).clamp(0.0, 1.0);
  }

  double _calculateStepsProgress(double steps) {
    // Goal: 5000 steps per day
    final goalSteps = 5000.0;
    return (steps / goalSteps).clamp(0.0, 1.0);
  }
}

/// Custom painter for drawing fitness rings
class FitnessRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;
  final bool isBackground;

  FitnessRingPainter({
    required this.progress,
    required this.color,
    required this.width,
    required this.isBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - width / 2;

    final paint = Paint()
      ..color = isBackground ? color.withOpacity(0.2) : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    if (isBackground) {
      // Draw full background ring
      canvas.drawCircle(center, radius, paint);
    } else {
      // Draw progress arc
      final sweepAngle = 2 * pi * progress;
      final startAngle = -pi / 2; // Start from top

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
