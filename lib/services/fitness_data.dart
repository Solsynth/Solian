import 'package:health/health.dart';
import 'package:easy_localization/easy_localization.dart';

/// Represents a fitness workout with structured data
class FitnessWorkout {
  final DateTime startTime;
  final DateTime endTime;
  final HealthWorkoutActivityType workoutType;
  final double? totalEnergyBurned;
  final HealthDataUnit? totalEnergyBurnedUnit;
  final double? totalDistance;
  final HealthDataUnit? totalDistanceUnit;
  final double? totalSteps;
  final HealthDataUnit? totalStepsUnit;

  FitnessWorkout({
    required this.startTime,
    required this.endTime,
    required this.workoutType,
    this.totalEnergyBurned,
    this.totalEnergyBurnedUnit,
    this.totalDistance,
    this.totalDistanceUnit,
    this.totalSteps,
    this.totalStepsUnit,
  });

  /// Convert workout type to human-readable string
  String get workoutTypeString {
    switch (workoutType) {
      case HealthWorkoutActivityType.BADMINTON:
        return 'fitnessWorkoutTypeBadminton'.tr();
      case HealthWorkoutActivityType.BASEBALL:
        return 'fitnessWorkoutTypeBaseball'.tr();
      case HealthWorkoutActivityType.BASKETBALL:
        return 'fitnessWorkoutTypeBasketball'.tr();
      case HealthWorkoutActivityType.BIKING:
        return 'fitnessWorkoutTypeBiking'.tr();
      case HealthWorkoutActivityType.CALISTHENICS:
        return 'fitnessWorkoutTypeCalisthenics'.tr();
      case HealthWorkoutActivityType.CRICKET:
        return 'fitnessWorkoutTypeCricket'.tr();
      case HealthWorkoutActivityType.DANCING:
        return 'fitnessWorkoutTypeDancing'.tr();
      case HealthWorkoutActivityType.ELLIPTICAL:
        return 'fitnessWorkoutTypeElliptical'.tr();
      case HealthWorkoutActivityType.FENCING:
        return 'fitnessWorkoutTypeFencing'.tr();
      case HealthWorkoutActivityType.FRISBEE_DISC:
        return 'fitnessWorkoutTypeFrisbeeDisc'.tr();
      case HealthWorkoutActivityType.GOLF:
        return 'fitnessWorkoutTypeGolf'.tr();
      case HealthWorkoutActivityType.GYMNASTICS:
        return 'fitnessWorkoutTypeGymnastics'.tr();
      case HealthWorkoutActivityType.HIKING:
        return 'fitnessWorkoutTypeHiking'.tr();
      case HealthWorkoutActivityType.HOCKEY:
        return 'fitnessWorkoutTypeHockey'.tr();
      case HealthWorkoutActivityType.JUMP_ROPE:
        return 'fitnessWorkoutTypeJumpRope'.tr();
      case HealthWorkoutActivityType.KICKBOXING:
        return 'fitnessWorkoutTypeKickboxing'.tr();
      case HealthWorkoutActivityType.LACROSSE:
        return 'fitnessWorkoutTypeLacrosse'.tr();
      case HealthWorkoutActivityType.MARTIAL_ARTS:
        return 'fitnessWorkoutTypeMartialArts'.tr();
      case HealthWorkoutActivityType.MIND_AND_BODY:
        return 'fitnessWorkoutTypeMindAndBody'.tr();
      case HealthWorkoutActivityType.PILATES:
        return 'fitnessWorkoutTypePilates'.tr();
      case HealthWorkoutActivityType.ROWING:
        return 'fitnessWorkoutTypeRowing'.tr();
      case HealthWorkoutActivityType.ROWING_MACHINE:
        return 'fitnessWorkoutTypeRowingMachine'.tr();
      case HealthWorkoutActivityType.RUGBY:
        return 'fitnessWorkoutTypeRugby'.tr();
      case HealthWorkoutActivityType.RUNNING:
        return 'fitnessWorkoutTypeRunning'.tr();
      case HealthWorkoutActivityType.SAILING:
        return 'fitnessWorkoutTypeSailing'.tr();
      case HealthWorkoutActivityType.SKIING:
        return 'fitnessWorkoutTypeSkiing'.tr();
      case HealthWorkoutActivityType.SNOW_SPORTS:
        return 'fitnessWorkoutTypeSnowSports'.tr();
      case HealthWorkoutActivityType.SOFTBALL:
        return 'fitnessWorkoutTypeSoftball'.tr();
      case HealthWorkoutActivityType.STAIR_CLIMBING:
        return 'fitnessWorkoutTypeStairClimbing'.tr();
      case HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE:
        return 'fitnessWorkoutTypeStairClimbingMachine'.tr();
      case HealthWorkoutActivityType.STEP_TRAINING:
        return 'fitnessWorkoutTypeStepTraining'.tr();
      case HealthWorkoutActivityType.SURFING:
        return 'fitnessWorkoutTypeSurfing'.tr();
      case HealthWorkoutActivityType.SWIMMING:
        return 'fitnessWorkoutTypeSwimming'.tr();
      case HealthWorkoutActivityType.TABLE_TENNIS:
        return 'fitnessWorkoutTypeTableTennis'.tr();
      case HealthWorkoutActivityType.TENNIS:
        return 'fitnessWorkoutTypeTennis'.tr();
      case HealthWorkoutActivityType.CROSS_TRAINING:
        return 'fitnessWorkoutTypeCrossTraining'.tr();
      case HealthWorkoutActivityType.CURLING:
        return 'fitnessWorkoutTypeCurling'.tr();
      case HealthWorkoutActivityType.CROSS_COUNTRY_SKIING:
        return 'fitnessWorkoutTypeCrossCountrySkiing'.tr();
      case HealthWorkoutActivityType.EQUESTRIAN_SPORTS:
        return 'fitnessWorkoutTypeEquestrianSports'.tr();
      case HealthWorkoutActivityType.FISHING:
        return 'fitnessWorkoutTypeFishing'.tr();
      case HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
        return 'fitnessWorkoutTypeFunctionalStrengthTraining'.tr();
      case HealthWorkoutActivityType.HAND_CYCLING:
        return 'fitnessWorkoutTypeHandCycling'.tr();
      case HealthWorkoutActivityType.MIXED_CARDIO:
        return 'fitnessWorkoutTypeMixedCardio'.tr();
      case HealthWorkoutActivityType.OTHER:
        return 'fitnessWorkoutTypeOther'.tr();
      case HealthWorkoutActivityType.PADDLE_SPORTS:
        return 'fitnessWorkoutTypePaddleSports'.tr();
      case HealthWorkoutActivityType.PICKLEBALL:
        return 'fitnessWorkoutTypePickleball'.tr();
      case HealthWorkoutActivityType.RACQUETBALL:
        return 'fitnessWorkoutTypeRacquetball'.tr();
      case HealthWorkoutActivityType.ROCK_CLIMBING:
        return 'fitnessWorkoutTypeRockClimbing'.tr();
      case HealthWorkoutActivityType.SKATING:
        return 'fitnessWorkoutTypeSkating'.tr();
      case HealthWorkoutActivityType.SNOWBOARDING:
        return 'fitnessWorkoutTypeSnowboarding'.tr();
      case HealthWorkoutActivityType.SOCCER:
        return 'fitnessWorkoutTypeSoccer'.tr();
      case HealthWorkoutActivityType.SQUASH:
        return 'fitnessWorkoutTypeSquash'.tr();
      case HealthWorkoutActivityType.STRENGTH_TRAINING:
        return 'fitnessWorkoutTypeStrengthTraining'.tr();
      case HealthWorkoutActivityType.VOLLEYBALL:
        return 'fitnessWorkoutTypeVolleyball'.tr();
      case HealthWorkoutActivityType.WALKING:
        return 'fitnessWorkoutTypeWalking'.tr();
      case HealthWorkoutActivityType.WEIGHTLIFTING:
        return 'fitnessWorkoutTypeWeightlifting'.tr();
      case HealthWorkoutActivityType.YOGA:
        return 'fitnessWorkoutTypeYoga'.tr();
      default:
        return 'fitnessWorkoutTypeDefault'.tr();
    }
  }

  /// Get formatted duration string
  String get durationString {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get formatted energy burned string
  String get energyBurnedString {
    if (totalEnergyBurned == null || totalEnergyBurnedUnit == null) {
      return '';
    }
    return '${totalEnergyBurned!.toStringAsFixed(2)} ${totalEnergyBurnedUnit!.name}';
  }

  /// Get formatted distance string
  String get distanceString {
    if (totalDistance == null || totalDistanceUnit == null) {
      return '';
    }
    return '${totalDistance!.toStringAsFixed(2)} ${totalDistanceUnit!.name}';
  }

  /// Get formatted steps string
  String get stepsString {
    if (totalSteps == null || totalStepsUnit == null) {
      return '';
    }
    return '${totalSteps!.toStringAsFixed(0)} ${totalStepsUnit!.name}';
  }
}

/// Enum for different types of fitness data
enum FitnessDataType { workout, steps, distance, calories, heartRate, sleep }

/// Enum for permission status
enum FitnessPermissionStatus { granted, denied, restricted, notDetermined }
