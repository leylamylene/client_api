import { Routes } from '@angular/router';
import { AppLayoutComponent } from '../layout/app.layout.component';
import { HomeComponent } from '../pages/home/home.component';

const routeConfig: Routes = [
  {
    path: '',
    component: AppLayoutComponent,
    title: 'Home page',
  },

  {path :'home', component
 : HomeComponent},
  {
    path: 'auth',
    loadChildren :()=>import('./auth.routes').then(r=>r.AUTH_ROUTES)
  },
];

export default routeConfig;
