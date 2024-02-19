import { createAction, props } from '@ngrx/store';
import { User } from '../../entities/User';

export const userKey = '[User]';

export const addUser = createAction(
  `${userKey} Add User`, 
  props<{ user: User }>()
);

export const deleteUser = createAction(
  `${userKey} Delete User`, 
  props<{ id: string }>()
);