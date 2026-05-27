import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/countdown/services/countdown_service.dart';
import 'features/gamification/services/gamification_service.dart';
import 'features/study_planner/services/study_planner_service.dart';
import 'firebase_options.dart';
import 'src/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CountdownService.instance.init();
  await GamificationService.instance.init();
  await StudyPlannerService.instance.init();
  await NotificationService.instance.init();
  runApp(const BacApp());
}
