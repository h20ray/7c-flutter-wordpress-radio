import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../audio/audio_focus_manager.dart';
import '../logger/app_logger.dart';
import '../../features/radio/data/datasources/radio_remote_datasource.dart';
import '../../features/radio/data/datasources/radio_player_remote_datasource.dart';
import '../../features/radio/data/repositories/radio_repository_impl.dart';
import '../../features/radio/data/repositories/radio_player_repository_impl.dart';
import '../../features/radio/data/services/album_art_service.dart';
import '../../features/radio/domain/repositories/radio_repository.dart';
import '../../features/radio/domain/repositories/radio_player_repository.dart';
import '../../features/radio/domain/usecases/get_radio_config.dart';
import '../../features/radio/domain/usecases/initialize_radio_player.dart';
import '../../features/radio/domain/usecases/play_radio.dart';
import '../../features/radio/domain/usecases/pause_radio.dart';
import '../../features/radio/domain/usecases/reset_radio_player.dart';
import '../../features/radio/presentation/bloc/radio_bloc.dart';
import '../../features/radio/presentation/bloc/radio_player_bloc.dart';
import '../../features/shoutbox/data/datasources/shoutbox_remote_datasource.dart';
import '../../features/shoutbox/data/repositories/shoutbox_repository_impl.dart';
import '../../features/shoutbox/domain/repositories/shoutbox_repository.dart';
import '../../features/shoutbox/domain/usecases/get_shoutbox_messages.dart';
import '../../features/shoutbox/domain/usecases/send_shoutbox_message.dart';
import '../../features/shoutbox/domain/usecases/delete_shoutbox_message.dart';
import '../../features/shoutbox/presentation/bloc/shoutbox_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/system_volume_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Guard to avoid double initialization
  if (getIt.isRegistered<Dio>()) {
    Log.debug('[DI] Dependencies already initialized, skipping');
    return;
  }

  Log.info('[DI] Initializing dependencies...');

  // External
  getIt.registerLazySingleton<Dio>(() => Dio());
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // Core services
  getIt.registerLazySingleton<AudioFocusManager>(
      () => AudioFocusManager.instance);
  getIt.registerLazySingleton<SystemVolumeService>(() {
    final svc = SystemVolumeService();
    svc.ensureInitialized();
    return svc;
  });

  // Features - Radio
  // Data sources
  getIt.registerLazySingleton<RadioRemoteDataSource>(
    () => RadioRemoteDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<RadioPlayerRemoteDataSource>(
    () => RadioPlayerRemoteDataSourceImpl(),
  );

  // Services
  getIt.registerLazySingleton<AlbumArtService>(() => AlbumArtService.instance);

  // Repositories
  getIt.registerLazySingleton<RadioRepository>(
    () => RadioRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<RadioPlayerRepository>(
    () => RadioPlayerRepositoryImpl(
      remoteDataSource: getIt(),
      albumArtService: getIt(),
    ),
  );

  // Radio Use cases
  getIt.registerLazySingleton(() => GetRadioConfig(getIt()));
  getIt.registerLazySingleton(() => InitializeRadioPlayer(getIt()));
  getIt.registerLazySingleton(() => PlayRadio(getIt()));
  getIt.registerLazySingleton(() => PauseRadio(getIt()));
  getIt.registerLazySingleton(() => ResetRadioPlayer(getIt()));

  // Radio Blocs
  getIt.registerLazySingleton(() => RadioBloc(getRadioConfig: getIt()));
  getIt.registerLazySingleton(() => RadioPlayerBloc(
        initializeRadioPlayer: getIt(),
        playRadio: getIt(),
        pauseRadio: getIt(),
        resetRadioPlayer: getIt(),
        repository: getIt(),
        radioConfigBloc: getIt<RadioBloc>(),
      ));

  // Features - Shoutbox
  // Data sources
  getIt.registerLazySingleton<ShoutboxRemoteDataSource>(
    () => ShoutboxRemoteDataSourceImpl(
      dio: getIt(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<ShoutboxRepository>(
    () => ShoutboxRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetShoutboxMessages>(
    () => GetShoutboxMessages(getIt()),
  );
  getIt.registerLazySingleton<SendShoutboxMessage>(
    () => SendShoutboxMessage(getIt()),
  );
  getIt.registerLazySingleton<DeleteShoutboxMessage>(
    () => DeleteShoutboxMessage(getIt()),
  );

  // BLoCs
  getIt.registerLazySingleton<ShoutboxBloc>(
    () => ShoutboxBloc(
      getMessages: getIt(),
      sendMessage: getIt(),
      deleteMessage: getIt(),
    ),
  );

  Log.info('[DI] Dependencies initialized successfully');
}
