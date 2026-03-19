import 'package:redux/redux.dart';
import 'app_state.dart';
import 'actions.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserAction) {
    return state.copyWith(currentUser: action.user);
  } else if (action is ClearUserAction) {
    return state.copyWith(clearUser: true);
  }
  return state;
}

Store<AppState> createStore() {
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
  );
}
