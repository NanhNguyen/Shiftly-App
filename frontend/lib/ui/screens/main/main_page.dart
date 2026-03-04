import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/constant/enums.dart';
import '../../../data/service/auth_service.dart';
import '../../di/di_config.dart';
import '../home/home_page.dart';
import '../schedule/schedule_page.dart';
import '../status/status_page.dart';
import '../profile/profile_page.dart';
import '../manager/manager_request_page.dart';
import '../schedule/cubit/schedule_cubit.dart';
import 'cubit/main_cubit.dart';
import 'cubit/main_state.dart';
import '../home/cubit/home_cubit.dart';
import '../notifications/cubit/notification_cubit.dart';
import '../notifications/cubit/notification_state.dart';
import 'widget/in_app_notification_banner.dart';
import '../../../resource/app_strings.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final HomeCubit _homeCubit;
  late final MainCubit _mainCubit;
  late final NotificationCubit _notifCubit;

  late final UserRole _userRole;
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navItems;
  late final Color _selectedColor;

  @override
  void initState() {
    super.initState();
    final authService = getIt<AuthService>();
    _userRole = authService.currentUser?.role ?? UserRole.INTERN;

    _mainCubit = getIt<MainCubit>()..setIndex(0); // always start at Home tab
    _homeCubit = getIt<HomeCubit>()..loadData();
    _notifCubit = getIt<NotificationCubit>()..loadNotifications();

    _pages = _getPagesForRole(_userRole);
    _navItems = _getNavItemsForRole(_userRole);
    _selectedColor = _getColorForRole(_userRole);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _mainCubit),
        BlocProvider.value(value: _homeCubit),
        BlocProvider.value(value: _notifCubit),
      ],
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, notifState) {
          return BlocBuilder<MainCubit, MainState>(
            builder: (context, state) {
              final unreadNotifications = notifState.notifications
                  .where((n) => !n.isRead)
                  .toList();

              return InAppNotificationOverlay(
                notifications: notifState.notifications,
                unreadCount: unreadNotifications.length,
                child: Scaffold(
                  body: IndexedStack(
                    index: state.currentIndex,
                    children: _pages,
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: state.currentIndex,
                    onTap: (index) {
                      _mainCubit.setIndex(index);
                      // Auto-refresh schedule when switching to Schedule tab
                      if ((_userRole == UserRole.INTERN && index == 1) ||
                          (_userRole == UserRole.MANAGER && index == 2) ||
                          (_userRole == UserRole.HR && index == 1)) {
                        getIt<ScheduleCubit>().loadSchedules(_userRole);
                      }
                    },
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: _selectedColor,
                    unselectedItemColor: Colors.grey,
                    iconSize: 30, // Increased
                    selectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(fontSize: 13),
                    items: _navItems,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _getPagesForRole(UserRole role) {
    switch (role) {
      case UserRole.MANAGER:
        return const [
          HomePage(),
          ManagerRequestPage(),
          SchedulePage(),
          ProfilePage(),
        ];
      case UserRole.HR:
        return const [HomePage(), SchedulePage(), ProfilePage()];
      case UserRole.INTERN:
      case UserRole.EMPLOYEE:
        return const [HomePage(), SchedulePage(), StatusPage(), ProfilePage()];
    }
  }

  List<BottomNavigationBarItem> _getNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.MANAGER:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: AppStrings.manage,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: AppStrings.schedule,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ];
      case UserRole.HR:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: AppStrings.schedule,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ];
      case UserRole.INTERN:
      case UserRole.EMPLOYEE:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: AppStrings.schedule,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: AppStrings.status,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ];
    }
  }

  Color _getColorForRole(UserRole role) {
    switch (role) {
      case UserRole.MANAGER:
        return Colors.deepPurple;
      case UserRole.HR:
        return Colors.teal;
      case UserRole.INTERN:
      case UserRole.EMPLOYEE:
        return Colors.blue.shade700;
    }
  }
}
