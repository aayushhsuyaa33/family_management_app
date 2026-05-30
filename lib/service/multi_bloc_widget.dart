import 'package:family_management_app/bloc/add%20tasks/add_tasks_cubit.dart';
import 'package:family_management_app/bloc/chats/all_chats_cubit.dart';
import 'package:family_management_app/bloc/fetch%20Notifications/fetch_notifications_cubit.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_cubit/fetch_event_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/bloc/google_calender/cubit/google_calendar_cubit.dart';
import 'package:family_management_app/bloc/login/login_cubit.dart';
import 'package:family_management_app/bloc/register/register_cubit.dart';
import 'package:family_management_app/bloc/role_update/role_update_cubit.dart';
import 'package:family_management_app/bloc/score/score_cubit.dart';
import 'package:family_management_app/bloc/voice_command/voice_command_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/saving chats bloc/saving_chats_cubit.dart';

class MultiBlocWidget extends StatelessWidget {
  final Widget child;
  const MultiBlocWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => FetchUserCubit()),
        BlocProvider(create: (context) => FetchTasksCubit()),
        BlocProvider(create: (context) => AddTasksCubit()),
        BlocProvider(create: (context) => RoleUpdateCubit()),
        BlocProvider(create: (context) => FetchEventCubit()),
        BlocProvider(create: (context) => GoogleCalendarCubit()),
        BlocProvider(create: (context) => AllChatsCubit()),
        BlocProvider(create: (context) => SavingChatsCubit()),
        BlocProvider(create: (context) => ScoreCubit()),
        BlocProvider(create: (context) => VoiceCommandCubit()),
        BlocProvider(create: (context) => FetchNotificationsCubit()),
      ],
      child: child,
    );
  }
}
