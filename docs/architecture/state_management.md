# State Management

The application utilizes the **BLoC (Business Logic Component)** pattern for state management, powered by the `flutter_bloc` package.

## BLoC Pattern Structure

For each distinct piece of UI logic or feature workflow, a BLoC is created. A typical BLoC directory (e.g., `lib/features/auth/presentation/bloc/login_bloc/`) contains three files:

### 1. Events (`login_event.dart`)
Events represent actions or triggers from the UI (e.g., button clicks, form submissions).
* All events extend a base abstract class (e.g., `abstract class LoginEvent extends Equatable`).
* Events hold data necessary for the action (e.g., `LoginManualSubmitted(this.employeeNo, this.password)`).

### 2. States (`login_state.dart`)
States represent the current condition of the UI.
* All states extend a base abstract class (e.g., `abstract class LoginState extends Equatable`).
* Common states include:
  * `InitialState`: The default state before any action.
  * `LoadingState`: Used to show progress indicators while an async operation is running.
  * `SuccessState`: Holds the resulting data when an operation completes successfully.
  * `FailureState`: Holds an error message when an operation fails.

### 3. BLoC (`login_bloc.dart`)
The BLoC class orchestrates the conversion of Events to States.
* It extends `Bloc<Event, State>`.
* It takes UseCases as dependencies via its constructor.
* It registers event handlers using `on<Event>((event, emit) async { ... })`.
* Inside handlers, it calls UseCases (which return an `Either<AppFailure, Data>`), and `emit()`s the corresponding Loading, Success, or Failure state based on the result.

## Example Flow (Login)
1. **UI Action**: User taps "Login". The UI dispatches `context.read<LoginBloc>().add(LoginManualSubmitted(...))`.
2. **BLoC Handling**: The BLoC catches `LoginManualSubmitted`.
3. **Loading**: The BLoC calls `emit(LoginLoading())`. The UI shows a spinner.
4. **Execution**: The BLoC invokes the `CheckLoginUsecase`.
5. **Result**:
   * On Success: `emit(LoginSuccess(data))`. UI navigates to the dashboard.
   * On Failure: `emit(LoginFailure(error.message))`. UI shows a snackbar/toast with the error.

## Provision and Injection
* **GetIt**: BLoCs are registered in `get_it` as factory methods (not singletons) to ensure fresh instances are created when needed.
  ```dart
  locator.registerFactory(() => LoginBloc(checkLogin: locator(), ...));
  ```
* **BlocProvider**: The UI layer wraps screens in `BlocProvider` to supply the BLoC to the widget tree.
  ```dart
  BlocProvider(
    create: (context) => locator<LoginBloc>(),
    child: const LoginPage(),
  )
  ```
