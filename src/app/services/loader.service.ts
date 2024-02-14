import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class LoaderService {

  private loading = new BehaviorSubject<boolean>(false);
  constructor() { }

  setLoading(isLoading : boolean) {
    this.loading.next(isLoading)
  }


  getLoading() {
    return this.loading.asObservable()
  }
}
