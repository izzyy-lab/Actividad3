import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/agenda/data/datasources/task_remote_datasource.dart';
import 'features/agenda/data/repositories/task_repository_impl.dart';
import 'features/agenda/domain/usecases/create_task_usecase.dart';
import 'features/agenda/domain/usecases/delete_task_usecase.dart';
import 'features/agenda/domain/usecases/get_tasks_usecase.dart';
import 'features/agenda/domain/usecases/toggle_task_usecase.dart';
import 'features/agenda/domain/usecases/update_task_usecase.dart';
import 'features/agenda/presentation/pages/agenda_list_page.dart';
import 'features/agenda/presentation/providers/agenda_provider.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Formatos de fecha en espanol para los widgets de la agenda.
  await initializeDateFormatting('es');
  runApp(const GestorAgendaApp());
}

/// Punto de entrada e inyeccion de dependencias.
///
/// El grafo se arma de afuera hacia adentro:
/// almacenamiento -> cliente HTTP -> datasource -> repositorio -> casos de uso -> provider.
class GestorAgendaApp extends StatelessWidget {
  const GestorAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Core ---
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);

    // --- Feature: auth (Aprendiz A) ---
    final authRepository = AuthRepositoryImpl(
      remote: AuthRemoteDataSource(apiClient),
      tokenStorage: tokenStorage,
    );

    // --- Feature: agenda (Aprendiz B) ---
    final taskRepository = TaskRepositoryImpl(TaskRemoteDataSource(apiClient));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            login: LoginUseCase(authRepository),
            register: RegisterUseCase(authRepository),
            forgotPassword: ForgotPasswordUseCase(authRepository),
            resetPassword: ResetPasswordUseCase(authRepository),
            getProfile: GetProfileUseCase(authRepository),
            updateProfile: UpdateProfileUseCase(authRepository),
            logout: LogoutUseCase(authRepository),
            repository: authRepository,
          )..verificarSesion(),
        ),
        ChangeNotifierProvider(
          create: (_) => AgendaProvider(
            getTasks: GetTasksUseCase(taskRepository),
            createTask: CreateTaskUseCase(taskRepository),
            updateTask: UpdateTaskUseCase(taskRepository),
            deleteTask: DeleteTaskUseCase(taskRepository),
            toggleTask: ToggleTaskUseCase(taskRepository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Gestor de Agenda',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _PantallaInicial(),
      ),
    );
  }
}

/// Decide la primera pantalla segun exista o no una sesion guardada.
class _PantallaInicial extends StatelessWidget {
  const _PantallaInicial();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    return switch (status) {
      AuthStatus.desconocido => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.autenticado => const AgendaListPage(),
      AuthStatus.noAutenticado => const LoginPage(),
    };
  }
}
