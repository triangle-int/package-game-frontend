import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/building/get_business_response.dart';
import 'package:package_flutter/domain/business/business_repository.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/user/user.dart';

part 'business_event.dart';
part 'business_state.dart';
part 'business_bloc.freezed.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final BuildingRepository _buildingRepository;
  final BusinessRepository _businessRepository;

  BusinessBloc(this._buildingRepository, this._businessRepository)
      : super(const BusinessState.initial()) {
    on<BusinessEvent>((event, emit) async {
      await event.map(
        businessRequested: (e) async {
          emit(const BusinessState.loadInProgress());
          Logger().d('Send event');
          final businessOrFailure =
              await _buildingRepository.getBusiness(businessId: e.businessId);
          businessOrFailure.fold((l) => null, (r) => null);
          Logger().d(businessOrFailure);

          emit(
            businessOrFailure.fold(
              (f) => BusinessState.loadFailure(f),
              (business) => BusinessState.loadSuccess(business),
            ),
          );

          add(BusinessEvent.collectMoney(e.user));
        },
        collectMoney: (e) => state.map(
          initial: (_) {},
          loadInProgress: (_) {},
          loadFailure: (_) {},
          loadSuccess: (s) async {
            if (e.user.id != s.businessAndTax.business.ownerId) return;
            final businessOrFailure = await _businessRepository.collectMoney(
              businessId: s.businessAndTax.business.id,
            );
            emit(
              businessOrFailure.fold(
                (f) => BusinessState.loadFailure(f),
                (business) => BusinessState.loadSuccess(
                  s.businessAndTax.copyWith(business: business),
                ),
              ),
            );
          },
        ),
        businessGot: (e) => state.map(
          initial: (s) {},
          loadInProgress: (s) {},
          loadFailure: (s) {},
          loadSuccess: (s) {
            emit(
              BusinessState.loadSuccess(
                s.businessAndTax.copyWith(business: e.businessBuilding),
              ),
            );
          },
        ),
      );
    });
  }
}
