import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/consent_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/patient_registration/patient_registration_screen.dart';
import '../../features/clinical_questionnaire/clinical_questionnaire_screen.dart';
import '../../features/lifestyle_assessment/lifestyle_assessment_screen.dart';
import '../../features/device_connection/device_connection_screen.dart';
import '../../features/device_connection/sensor_placement_screen.dart';
import '../../features/screening_test/screening_test_screen.dart';
import '../../features/screening_test/processing_screen.dart';
import '../../features/risk_result/risk_result_screen.dart';
import '../../features/risk_result/explainability_screen.dart';
import '../../features/patient_history/patient_history_screen.dart';
import '../../features/guidance/guidance_screen.dart';
import '../../features/referrals/referral_screen.dart';
import '../../features/follow_up/follow_up_screen.dart';
import '../../features/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/consent',
      builder: (context, state) => const ConsentScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/patient-registration',
      builder: (context, state) => const PatientRegistrationScreen(),
    ),
    GoRoute(
      path: '/clinical-questionnaire',
      builder: (context, state) => const ClinicalQuestionnaireScreen(),
    ),
    GoRoute(
      path: '/lifestyle-assessment',
      builder: (context, state) => const LifestyleAssessmentScreen(),
    ),
    GoRoute(
      path: '/device-connection',
      builder: (context, state) => const DeviceConnectionScreen(),
    ),
    GoRoute(
      path: '/sensor-placement',
      builder: (context, state) => const SensorPlacementScreen(),
    ),
    GoRoute(
      path: '/screening-test',
      builder: (context, state) => const ScreeningTestScreen(),
    ),
    GoRoute(
      path: '/processing',
      builder: (context, state) => const ProcessingScreen(),
    ),
    GoRoute(
      path: '/risk-result',
      builder: (context, state) => const RiskResultScreen(),
    ),
    GoRoute(
      path: '/explainability',
      builder: (context, state) => const ExplainabilityScreen(),
    ),
    GoRoute(
      path: '/patient-history',
      builder: (context, state) => const PatientHistoryScreen(),
    ),
    GoRoute(
      path: '/guidance',
      builder: (context, state) => const GuidanceScreen(),
    ),
    GoRoute(
      path: '/referrals',
      builder: (context, state) => const ReferralScreen(),
    ),
    GoRoute(
      path: '/referral-create',
      builder: (context, state) => const ReferralScreen(),
    ),
    GoRoute(
      path: '/follow-up',
      builder: (context, state) => const FollowUpScreen(),
    ),
    GoRoute(
      path: '/follow-up-create',
      builder: (context, state) => const FollowUpScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
