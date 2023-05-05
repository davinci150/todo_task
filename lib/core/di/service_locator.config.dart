// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../../api/auth_api.dart' as _i3;
import '../../api/birthdays_api.dart' as _i5;
import '../../api/tasks_api.dart' as _i8;
import '../../dao/auth_dao.dart' as _i4;
import '../../dao/tasks_dao.dart' as _i9;
import '../../repository/birthdays_repository.dart' as _i6;
import '../../repository/tasks_repository.dart' as _i10;
import '../../services/notification_service.dart' as _i7;

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// initializes the registration of main-scope dependencies inside of GetIt
_i1.GetIt $initGetIt(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.lazySingleton<_i3.AuthApi>(() => _i3.AuthApi());
  gh.lazySingleton<_i4.AuthDao>(() => _i4.AuthDao());
  gh.lazySingleton<_i5.BirthdaysApi>(
      () => _i5.BirthdaysApi(authApi: gh<_i3.AuthApi>()));
  gh.lazySingleton<_i6.BirthdaysRepository>(
      () => _i6.BirthdaysRepository(birthdaysApi: gh<_i5.BirthdaysApi>()));
  gh.lazySingleton<_i7.NotificationService>(() => _i7.NotificationService());
  gh.lazySingleton<_i8.TasksApi>(
      () => _i8.TasksApi(authApi: gh<_i3.AuthApi>()));
  gh.lazySingleton<_i9.TasksDao>(() => _i9.TasksDao());
  gh.lazySingleton<_i10.TasksRepository>(() => _i10.TasksRepository(
        taskApi: gh<_i8.TasksApi>(),
        tasksDao: gh<_i9.TasksDao>(),
      ));
  return getIt;
}
