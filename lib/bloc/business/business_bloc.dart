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
      switch (event) {
        case BusinessRequested(:final businessId, :final user):
          emit(const BusinessState.loadInProgress());
          Logger().d('Send event');
          final businessOrFailure =
              await _buildingRepository.getBusiness(businessId: businessId);
          businessOrFailure.fold((l) => null, (r) => null);
          Logger().d(businessOrFailure);

          emit(
            businessOrFailure.fold(
              (f) => BusinessState.loadFailure(f),
              (business) => BusinessState.loadSuccess(business),
            ),
          );

          add(BusinessEvent.collectMoney(user));
        case CollectMoney(:final user):
          switch (state) {
            case BusinessStateInitial():
              break;
            case BusinessStateLoadInProgress():
              break;
            case BusinessStateLoadFailure():
              break;
            case BusinessStateLoadSuccess(:final businessAndTax):
              if (user.id != businessAndTax.business.ownerId) return;
              final businessOrFailure = await _businessRepository.collectMoney(
                businessId: businessAndTax.business.id,
              );
              emit(
                businessOrFailure.fold(
                  (f) => BusinessState.loadFailure(f),
                  (business) => BusinessState.loadSuccess(
                    businessAndTax.copyWith(business: business),
                  ),
                ),
              );
          }
        case BusinessGot(:final businessBuilding):
          switch (state) {
            case BusinessStateInitial():
              break;
            case BusinessStateLoadInProgress():
              break;
            case BusinessStateLoadFailure():
              break;
            case BusinessStateLoadSuccess(:final businessAndTax):
              emit(
                BusinessState.loadSuccess(
                  businessAndTax.copyWith(business: businessBuilding),
                ),
              );
          }
      }
    });
  }
}
