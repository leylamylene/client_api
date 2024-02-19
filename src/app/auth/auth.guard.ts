import { Pipe, inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth/auth.service';
import { MetamaskLoginService } from '../services/auth/metamask/meatamask-login.service';
import { shareReplay } from 'rxjs';

export const authGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);
  const authService = inject(AuthService);
  const isLoggedIn = authService.isLoggedIn();
  //@ts-ignore

  // logged in by email
  if (isLoggedIn) {
    console.log('trrrrue ');
    return true;
  } else {
    console.log('not connected');
    router.navigate(['auth/login']);
    // show the login modal
    return false;
  }
};
