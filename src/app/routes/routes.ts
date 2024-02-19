import { Routes } from '@angular/router';
import { AppLayoutComponent } from '../layout/app.layout.component';
import { HomeComponent } from '../pages/home/home.component';
import { authGuard } from '../auth/auth.guard';

const routeConfig: Routes = [
  {
    path: '',
    component: AppLayoutComponent,
    title: 'Layout page',
  },
  { path: 'home', component: HomeComponent, canActivate: [authGuard] },

  {
    path: 'auth',
    loadChildren: () => import('./auth.routes').then((r) => r.AUTH_ROUTES),
  },
];

export default routeConfig;
