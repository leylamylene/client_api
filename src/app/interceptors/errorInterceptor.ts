import { Injectable } from '@angular/core';
import {
  HttpInterceptor,
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpErrorResponse,
} from '@angular/common/http';
import { Observable, of, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { ErrorHandlerService } from '../services/error-handler.service';

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(private errorHandlerService: ErrorHandlerService) {}

  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    console.log('error interceptor');

    return next.handle(request).pipe(
      catchError((errorResponse: any) => {
        this.errorHandlerService.handleError(errorResponse.error);

        return of(errorResponse);
      })
    );
  }
}
