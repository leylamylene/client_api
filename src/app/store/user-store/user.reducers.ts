import { ActionReducer, createReducer, on } from '@ngrx/store';
import { adapter, initialState, UserState } from './user.state';
import { addUser, deleteUser } from './user.actions';

export const userReducers: ActionReducer<UserState> = createReducer(
  initialState,
  on(addUser, (state: UserState, { user }) => 
    adapter.addOne(user, state)),
  on(deleteUser, (state: UserState, { id }) => 
    adapter.removeOne(id, state))
);