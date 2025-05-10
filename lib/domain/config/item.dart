import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@Freezed(unionKey: 'type')
sealed class Item with _$Item {
  const Item._();

  const factory Item.resource({
    required String name,
    required String emoji,
    required int group,
    required int level,
    required String color,
  }) = ItemResource;
  const factory Item.booster({
    required String name,
    required String description,
    required String emoji,
    required int price,
  }) = ItemBooster;
  const factory Item.unknown({
    required String name,
  }) = ItemUnknown;

  String get emoji => switch (this) {
        ItemResource(emoji: final emoji) => emoji,
        ItemBooster(emoji: final emoji) => emoji,
        ItemUnknown() => '❓',
      };

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
