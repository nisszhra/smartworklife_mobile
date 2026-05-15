import 'package:get/get.dart';

import '../modules/health/bindings/health_binding.dart';
import '../modules/health/views/health_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
import '../modules/notulen/bindings/notulen_binding.dart';
import '../modules/notulen/views/notulen_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/pomodoro/bindings/pomodoro_binding.dart';
import '../modules/pomodoro/views/pomodoro_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/stretching/bindings/stretching_binding.dart';
import '../modules/stretching/views/stretching_detail_view.dart';
import '../modules/stretching/views/stretching_preview_view.dart';
import '../modules/stretching/views/stretching_view.dart';
import '../modules/todolist/bindings/todolist_binding.dart';
import '../modules/todolist/views/todolist_view.dart';
import '../modules/verifikasi/bindings/verifikasi_binding.dart';
import '../modules/verifikasi/views/verifikasi_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.POMODORO,
      page: () => const PomodoroView(),
      binding: PomodoroBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.NOTULEN,
      page: () => const NotulenView(),
      binding: NotulenBinding(),
    ),
    GetPage(
      name: _Paths.TODOLIST,
      page: () => const TodolistView(),
      binding: TodolistBinding(),
    ),
    GetPage(
      name: _Paths.STRETCHING,
      page: () => const StretchingView(),
      binding: StretchingBinding(),
    ),
    GetPage(
      name: _Paths.STRETCHING_DETAIL,
      page: () => const StretchingDetailView(),
      binding: StretchingBinding(),
    ),
    GetPage(
      name: _Paths.STRETCHING_PREVIEW,
      page: () => const StretchingPreviewView(),
      binding: StretchingBinding(),
    ),
    GetPage(
      name: _Paths.VERIFIKASI,
      page: () => const VerifikasiView(),
      binding: VerifikasiBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
  ];
}
