import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/domain/inventory/inventory.dart';
import 'package:package_flutter/presentation/inventory/inventory_tab.dart';

class InventoryBody extends StatefulWidget {
  const InventoryBody({super.key, required this.inventory});

  final Inventory inventory;

  @override
  InventoryBodyState createState() => InventoryBodyState();
}

class InventoryBodyState extends State<InventoryBody>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: max(widget.inventory.inventory.length, 1),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buildingsId = widget.inventory.inventory.keys.toList();

    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        final inv = switch (state) {
          InventoryStateLoadSuccess(:final inventory) => inventory.inventory,
          _ => {},
        };
        _tabController = TabController(length: max(inv.length, 1), vsync: this);
      },
      child: Expanded(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  onTap: (_) {
                    AudioPlayer().play(
                      AssetSource('sounds/inventory_category_switch.wav'),
                    );
                  },
                  tabs: buildingsId.isEmpty
                      ? [
                          const Tab(
                            text: 'No storages',
                          )
                        ]
                      : buildingsId
                          .map((id) => Tab(text: '#${id + 1}'))
                          .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                color: const Color(0xFF252525),
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: buildingsId.isEmpty
                      ? [
                          const InventoryTab(buildingId: 0),
                        ]
                      : buildingsId
                          .map((bi) => InventoryTab(buildingId: bi))
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
