import { Injectable } from '@angular/core';
import {
  HttpInterceptor,
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpErrorResponse,
} from '@angular/common/http';
import { Observable, of, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { ErrorHandlerService } from '../services/error-handler.service';
import { SuccessHandlerService } from '../services/successHandler.service';

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(
    private errorHandlerService: ErrorHandlerService,
    private successHandlerS: SuccessHandlerService
  ) {}

  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {

    return next.handle(request).pipe(
      tap((data: any) => {
        // add 201 later , the success toast wil only show when data is created ? 
       if(data.status == 200)
        this.successHandlerS.showSuccessToast();
      }),
      catchError((errorResponse: any) => {
        this.errorHandlerService.handleError(errorResponse.error);

        return of(errorResponse);
      })
    );
  }
}
