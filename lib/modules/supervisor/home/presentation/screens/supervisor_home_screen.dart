import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/unread_count_bloc.dart';
import 'package:anestrack_mobile/modules/common/profile/presentation/blocs/current_user_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedure_types_bloc/procedure_types_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_dashboard.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/blocs/dashboard_bloc/dashboard_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/widgets/supervisor_home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupervisorHomeScreen extends StatelessWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<CurrentUserBloc>()..add(FetchCurrentUserEvent()),
        ),
        // UnreadCountBloc is a singleton owned by the service locator (see
        // service_locator.dart), so it must be provided via `.value` rather
        // than `create` — `create` would make flutter_bloc close() it when
        // this screen is disposed, permanently breaking the singleton.
        BlocProvider.value(
          value: sl<UnreadCountBloc>()..add(FetchUnreadCountEvent()),
        ),
        BlocProvider(
          create: (_) => sl<HospitalsBloc>()..add(FetchHospitalsEvent()),
        ),
        BlocProvider(
          create: (_) =>
              sl<ProcedureTypesBloc>()..add(FetchProcedureTypesEvent()),
        ),
        BlocProvider(create: (_) => sl<DashboardBloc>()..add(FetchDashboardEvent())),
      ],
      child: const _SupervisorHomeView(),
    );
  }
}

class _SupervisorHomeView extends StatefulWidget {
  const _SupervisorHomeView();

  @override
  State<_SupervisorHomeView> createState() => _SupervisorHomeViewState();
}

class _SupervisorHomeViewState extends State<_SupervisorHomeView> {
  String? _selectedHospitalId;

  void _onHospitalChanged(String? hospitalId) {
    setState(() => _selectedHospitalId = hospitalId);
    context.read<DashboardBloc>().add(FetchDashboardEvent(hospitalId));
  }

  Future<void> _onRefresh() async {
    context.read<CurrentUserBloc>().add(FetchCurrentUserEvent());
    sl<UnreadCountBloc>().add(FetchUnreadCountEvent());
    context.read<HospitalsBloc>().add(FetchHospitalsEvent());
    context.read<ProcedureTypesBloc>().add(FetchProcedureTypesEvent());
    context.read<DashboardBloc>().add(FetchDashboardEvent(_selectedHospitalId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SupervisorHomeHeader(),
              HospitalFilterDropdown(
                selectedHospitalId: _selectedHospitalId,
                onChanged: _onHospitalChanged,
              ),
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  final SupervisorDashboardStats? stats = state.data;
                  return BlocBuilder<ProcedureTypesBloc, ProcedureTypesState>(
                    builder: (context, typesState) {
                      final nameById = <String, String>{
                        for (final t in typesState.data ?? const [])
                          t.id: t.nameAr ?? t.name,
                      };
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DashboardTopStats(stats: stats),
                          ProceduresByTypeChart(
                            byProcedureType: stats?.byProcedureType ?? const [],
                            nameById: nameById,
                          ),
                          GeneralStatsSection(stats: stats),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
