import 'package:package_flutter/l10n/translations.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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
  void didUpdateWidget(covariant InventoryBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.inventory.inventory.keys.toList();
    final ids = widget.inventory.inventory.keys.toList();
    if (oldIds.length != ids.length ||
        !List.generate(oldIds.length, (i) => oldIds[i] == ids[i])
            .every((v) => v)) {
      final selectedId = oldIds.isEmpty ? null : oldIds[_tabController.index];
      final selectedIndex = ids.indexOf(selectedId ?? -1);
      final oldController = _tabController;
      _tabController = TabController(
        length: max(ids.length, 1),
        initialIndex: max(selectedIndex, 0),
        vsync: this,
      );
      oldController.dispose();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildingsId = widget.inventory.inventory.keys.toList();

    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AppText('Inventory · Choose a warehouse to see its resources',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white70)),
          ),
          const SizedBox(height: 12),
          if (buildingsId.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: buildingsId.length > 3,
                  tabAlignment: buildingsId.length > 3
                      ? TabAlignment.start
                      : TabAlignment.fill,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).primaryColor,
                  ),
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  onTap: (_) => AudioPlayer().play(
                    AssetSource('sounds/inventory_category_switch.wav'),
                  ),
                  tabs: buildingsId
                      .map((id) => Tab(text: translate(context, 'Warehouse #${id + 1}')))
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              color: const Color(0xFF252525),
              child: buildingsId.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: AppText(
                          'No warehouses yet. Tap the map and build one to store resources.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: buildingsId
                          .map((id) => InventoryTab(buildingId: id))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
