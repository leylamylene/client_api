import { createEntityAdapter, EntityAdapter, EntityState } from '@ngrx/entity';
import { User } from '../../entities/User';

export interface UserState extends EntityState<User> {
  loading: [];
  isLoggedIn :boolean
}

export const selectId = ({ _id }: User) => _id;

// export const sortComparer = (a: User, b: User): number =>
//   a.publishDate.toString().localeCompare(b.publishDate.toString());

export const adapter: EntityAdapter<User> = createEntityAdapter({ selectId });

export const initialState: UserState = adapter.getInitialState({ isLoggedIn :false,loading: [] });
