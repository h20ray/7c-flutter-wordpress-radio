import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_radio_config.dart';
import 'radio_event.dart';
import 'radio_state.dart';

class RadioBloc extends Bloc<RadioEvent, RadioState> {
  final GetRadioConfig getRadioConfig;

  RadioBloc({required this.getRadioConfig})
      : super(const RadioState.initial()) {
    on<RadioEvent>(_onRadioEvent);
  }

  Future<void> _onRadioEvent(
    RadioEvent event,
    Emitter<RadioState> emit,
  ) async {
    await event.when(
      getRadioConfig: () async {
        emit(const RadioState.loading());

        final result = await getRadioConfig();
        result.fold(
          (failure) => emit(RadioState.error(failure)),
          (radioConfig) => emit(RadioState.loaded(radioConfig)),
        );
      },
      refreshRadioConfig: () async {
        emit(const RadioState.loading());

        final result = await getRadioConfig();
        result.fold(
          (failure) => emit(RadioState.error(failure)),
          (radioConfig) => emit(RadioState.loaded(radioConfig)),
        );
      },
    );
  }
}
