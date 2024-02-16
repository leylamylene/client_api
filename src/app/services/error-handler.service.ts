import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
export interface HttpError {
  status: number | undefined;
  message: string | undefined;
}
@Injectable({
  providedIn: 'root',
})
export class ErrorHandlerService {
  private error = new BehaviorSubject<HttpError>({
    status: undefined,
    message: undefined,
  });

  handleError(errorResponse: any) {
    // Handle your error here
    // console.error('An error occurred:', error.status, error.message);
    this.setError(errorResponse);
  }

  setError(errorResponse: any) {
    this.error.next({ status: errorResponse.status, message: errorResponse.error } );
    
  }

  getError() {
    return this.error.asObservable();
  }
}
