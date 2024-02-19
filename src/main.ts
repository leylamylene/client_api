/*
 *  Protractor support is deprecated in Angular.
 *  Protractor is used in this example for compatibility with Angular documentation tools.
 */
import {
  BrowserModule,
  bootstrapApplication,
  provideProtractorTestingSupport,
} from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { provideRouter } from '@angular/router';
import routeConfig from './app/routes/routes';
import {
  HTTP_INTERCEPTORS,
  HttpInterceptorFn,
  provideHttpClient,
  withInterceptorsFromDi,
} from '@angular/common/http';
import { MatDialogModule } from '@angular/material/dialog';
import { importProvidersFrom, isDevMode } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AuthInterceptor } from './app/interceptors/authInterceptor';
import { SpinnerInterceptor } from './app/interceptors/spinnerInterceptor';
import { ErrorInterceptor } from './app/interceptors/errorInterceptor';
import { provideStore } from '@ngrx/store';
import { userReducers } from './app/store/user-store';
import { provideStoreDevtools } from '@ngrx/store-devtools';
bootstrapApplication(AppComponent, {
  providers: [
    provideProtractorTestingSupport(),
    provideRouter(routeConfig),
    provideHttpClient(withInterceptorsFromDi()),
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true,
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: SpinnerInterceptor,
      multi: true,
    },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },
    importProvidersFrom(
      MatDialogModule,
      BrowserModule,
      BrowserAnimationsModule,
      MatDialogModule
    ),
    provideStore({ user: userReducers }),
    provideStoreDevtools({
      maxAge: 25, // Retains last 25 states
      logOnly: !isDevMode(), // Restrict extension to log-only mode
      autoPause: true, // Pauses recording actions and state changes when the extension window is not open
      trace: false, //  If set to true, will include stack trace for every dispatched action, so you can see it in trace tab jumping directly to that part of code
      traceLimit: 75, // maximum stack trace frames to be stored (in case trace option was provided as true)
    }),
  ],
});
