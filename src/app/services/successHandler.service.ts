import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class SuccessHandlerService {
  private status = new BehaviorSubject<boolean>(false);

  showSuccessToast() {
    this.status.next(true);
  }

  getStatus() {
    return this.status.asObservable();
  }
}
