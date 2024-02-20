import { Routes } from '@angular/router';
import { AppLayoutComponent } from '../layout/app.layout.component';
import { HomeComponent } from '../pages/home/home.component';
import { authGuard } from '../guards/auth.guard';
import { MintComponent } from '../pages/create-mint/mint/mint.component';

const routeConfig: Routes = [
  {
    path: '',
    component: AppLayoutComponent,
    title: 'Layout page',
  },
  { path: 'home', component: HomeComponent, canActivate: [authGuard] },

  { path: 'mint', component: MintComponent, canActivate: [authGuard] },

  {
    path: 'auth',
    loadChildren: () => import('./auth.routes').then((r) => r.AUTH_ROUTES),
  },
];

export default routeConfig;
