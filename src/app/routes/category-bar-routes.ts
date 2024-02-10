import { Routes } from '@angular/router';
import { AllComponent } from '../categories/all/all.component';
import { ArtComponent } from '../categories/art/art.component';

export const CATEGORY_ROUTES: Routes = [
  {
    path: '',
    component: AllComponent,
    title: 'All listings',
  },
  {
    path: 'art',
    component: ArtComponent,
    title: 'Art listings',
  },
];

