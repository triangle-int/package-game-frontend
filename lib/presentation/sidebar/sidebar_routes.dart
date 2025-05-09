import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/bloc/truck/remove_schedule.dart/remove_schedule_bloc.dart';
import 'package:package_flutter/presentation/sidebar/schedule_item.dart';
import 'package:package_flutter/presentation/sidebar/sidebar_route_category.dart';
import 'package:package_flutter/presentation/sidebar/truck_item.dart';
import 'package:separated_column/separated_column.dart';

class SidebarRoutes extends StatelessWidget {
  const SidebarRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RemoveScheduleBloc, RemoveScheduleState>(
      listener: (context, state) {
        switch (state) {
          case RemoveScheduleStateLoadSuccess():
            context
                .read<SidebarBloc>()
                .add(const SidebarEvent.routesSelected());
          default:
            break;
        }
      },
      child: Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: () {
                  context
                      .read<SidebarBloc>()
                      .add(const SidebarEvent.initialPageSelected());
                },
                child: const Text(
                  '❌ 🚚 Routes',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 20),
              child: BlocBuilder<SidebarBloc, SidebarState>(
                builder: (context, sidebarState) {
                  return sidebarState.map(
                    initial: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    routes: (s) {
                      if (s.isLoading && s.schedulesOrFailure == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Column(
                        children: [
                          const SizedBox(height: 7),
                          const SidebarRouteCategory('scheduled routes'),
                          const SizedBox(height: 18),
                          SeparatedColumn(
                            children: s.schedulesOrFailure!.fold(
                              (f) => [
                                Text('Routes loading failed: ${f.getMessage()}')
                              ],
                              (schedules) => schedules.schedules.isNotEmpty
                                  ? schedules.schedules
                                      .map(
                                        (schedule) => ScheduleItem(schedule),
                                      )
                                      .toList()
                                  : [
                                      const Text(
                                        'No scheduled routes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 13),
                          ),
                          const SizedBox(height: 18),
                          const SidebarRouteCategory('one time routes'),
                          const SizedBox(height: 18),
                          SeparatedColumn(
                            children: s.schedulesOrFailure!.fold(
                              (f) => [
                                Text('Routes loading failed: ${f.getMessage()}')
                              ],
                              (schedulesAndTrucks) =>
                                  schedulesAndTrucks.trucks.isNotEmpty
                                      ? schedulesAndTrucks.trucks
                                          .map(
                                            (truck) => TruckItem(truck),
                                          )
                                          .toList()
                                      : [
                                          const Text(
                                            'No one time routes',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 13),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
