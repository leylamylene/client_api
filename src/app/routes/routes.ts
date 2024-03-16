import { Routes } from '@angular/router';
import { AppLayoutComponent } from '../layout/app.layout.component';
import { HomeComponent } from '../pages/home/home.component';
import { authGuard } from '../guards/auth.guard';
import { MintComponent } from '../pages/create-mint/mint/mint.component';
import { Deploy721Component } from '../pages/collection/deploy/collection/deploy721.component';

const routeConfig: Routes = [
  {
    path: '',
    component: HomeComponent,
    title: 'Home page',
  },
  { path: 'home', component: HomeComponent, canActivate: [authGuard] },

  { path: 'mint', component: MintComponent, canActivate: [authGuard] },
  { path: 'collection/deploy', component: Deploy721Component },

  {
    path: 'auth',
    loadChildren: () => import('./auth.routes').then((r) => r.AUTH_ROUTES),
  },
];

export default routeConfig;
