import { Injectable } from '@angular/core';
import {
  HttpEvent,
  HttpHandler,
  HttpInterceptor,
  HttpRequest,
} from '@angular/common/http';
import { Observable } from 'rxjs';
import { finalize } from 'rxjs/operators';
import { LoaderService } from '../services/loader.service';

@Injectable()
export class SpinnerInterceptor implements HttpInterceptor {
  constructor(public loaderService: LoaderService) {}

  intercept(
    req: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    console.log('spinner interceptor')

    // Check if the custom header is present
    if (req.headers.get('Show-Spinner')) {
      this.loaderService.setLoading(true);
      return next.handle(req).pipe(
        finalize(() => {
          this.loaderService.setLoading(false);
          console.log('setting loading');
        })
      );
    } else {
      // If the header is not present, simply forward the request
      return next.handle(req);
    }
  }
}
