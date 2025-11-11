import 'package:freezed_annotation/freezed_annotation.dart';

part 'radio_event.freezed.dart';

@freezed
class RadioEvent with _$RadioEvent {
  const factory RadioEvent.getRadioConfig() = _GetRadioConfig;
  const factory RadioEvent.refreshRadioConfig() = _RefreshRadioConfig;
}
