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
import '../../api/tasks_api.dart' as _i9;
import '../../dao/auth_dao.dart' as _i4;
import '../../dao/tasks_dao.dart' as _i10;
import '../../dao/theme_dao.dart' as _i12;
import '../../repository/birthdays_repository.dart' as _i6;
import '../../repository/tasks_repository.dart' as _i11;
import '../../router/router.dart' as _i8;
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
  gh.singleton<_i8.RouterI>(_i8.Router());
  gh.lazySingleton<_i9.TasksApi>(
      () => _i9.TasksApi(authApi: gh<_i3.AuthApi>()));
  gh.lazySingleton<_i10.TasksDao>(() => _i10.TasksDao());
  gh.lazySingleton<_i11.TasksRepository>(() => _i11.TasksRepository(
        taskApi: gh<_i9.TasksApi>(),
        tasksDao: gh<_i10.TasksDao>(),
      ));
  gh.lazySingleton<_i12.ThemeDao>(() => _i12.ThemeDao());
  return getIt;
}
