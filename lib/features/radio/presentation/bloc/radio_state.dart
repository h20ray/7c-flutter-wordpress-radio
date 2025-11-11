import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/radio_entity.dart';

part 'radio_state.freezed.dart';

@freezed
class RadioState with _$RadioState {
  const factory RadioState.initial() = _Initial;
  const factory RadioState.loading() = _Loading;
  const factory RadioState.loaded(RadioEntity radioConfig) = _Loaded;
  const factory RadioState.error(Failure failure) = _Error;
}
