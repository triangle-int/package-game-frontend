import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/business/business_repository.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

part 'business_upgrade_event.dart';
part 'business_upgrade_state.dart';
part 'business_upgrade_bloc.freezed.dart';

class BusinessUpgradeBloc
    extends Bloc<BusinessUpgradeEvent, BusinessUpgradeState> {
  final BusinessRepository _repository;

  BusinessUpgradeBloc(this._repository)
      : super(const BusinessUpgradeState.initial()) {
    on<BusinessUpgradeEvent>((event, emit) async {
      switch (event) {
        case UpgradeRequested(:final building):
          emit(const BusinessUpgradeState.loadInProgress());

          final failureOrBusiness =
              await _repository.upgradeBusiness(businessId: building.id);

          failureOrBusiness.fold(
            (f) => emit(BusinessUpgradeState.loadFailure(f)),
            (building) => emit(BusinessUpgradeState.loadSuccess(building)),
          );
      }
    });
  }
}
