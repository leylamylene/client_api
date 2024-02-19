import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Inject, Injectable } from '@angular/core';
import { Observable, map } from 'rxjs';
import UrlConstants from '../../../constants/apiUrls';
import moment from 'moment';
import { spinnerFlagedOptions } from '../../HttpOptions';
import { DOCUMENT } from '@angular/common';
const BASE_URL = UrlConstants.BASE_URL;
const AUTH_API = UrlConstants.AUTH_API;

@Injectable({
  providedIn: 'root',
})
export class EmailLoginService {
  constructor(
    private http: HttpClient,
    @Inject(DOCUMENT) private document: Document
  ) {}
  localStorage = this.document.defaultView?.localStorage;

  // Function for user login
  passwordlessLogin(email: string): Observable<any> {
    return this.http.post(
      BASE_URL + AUTH_API + '/passwordlessLogin',
      { email },
      spinnerFlagedOptions
    );
  }

  authenticatePwrdLess(email: string, code: string): Observable<any> {
    return this.http.get(
      BASE_URL + AUTH_API + `/authenticate/${email}/${code}`,
      spinnerFlagedOptions
    );
  }

  setSession(authResult: any) {
    const expiresAt = moment().add(authResult.expiresAt, 'second');

    this.localStorage?.setItem('id_token', authResult.token);
    this.localStorage?.setItem(
      'expires_at',
      JSON.stringify(expiresAt.valueOf())
    );
  }
}
