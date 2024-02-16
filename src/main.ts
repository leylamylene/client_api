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
import { importProvidersFrom } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AuthInterceptor } from './app/interceptors/authInterceptor';
import { SpinnerInterceptor } from './app/interceptors/spinnerInterceptor';
import { ErrorInterceptor } from './app/interceptors/errorInterceptor';
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
  ],
}).catch((err) => console.error(err));
