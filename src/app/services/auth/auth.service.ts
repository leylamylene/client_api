import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, map } from 'rxjs';
import UrlConstants from '../../constants/apiUrls';
import moment from 'moment';
const BASE_URL = UrlConstants.BASE_URL;
const AUTH_API = UrlConstants.AUTH_API;

const httpDefaultOptions = {
  headers: new HttpHeaders({
    'Content-Type': 'application/json',
  }),
};

const spinnerFlagedOptions = {
  headers: new HttpHeaders({
    'Content-Type': 'application/json',
    'Show-Spinner': 'true',
  }),
};
@Injectable({
  providedIn: 'root',
})
export class AuthService {
  constructor(private http: HttpClient) {}

  // Function for user login
  passwordlessLogin(email: string): Observable<any> {
    return this.http.post(
      BASE_URL + AUTH_API + '/passwordlessLogin',
      { email },
      spinnerFlagedOptions
    );
  }

  authenticatePdLess(email: string, code: string): Observable<any> {
    return this.http.get(
      BASE_URL + AUTH_API + `/authenticate/${email}/${code}`,
      spinnerFlagedOptions
    );
  }

  setSession(authResult: any) {
    const expiresAt = moment().add(authResult.expiresIn, 'second');

    localStorage.setItem('id_token', authResult.idToken);
    localStorage.setItem('expires_at', JSON.stringify(expiresAt.valueOf()));
  }

  logout() {
    localStorage.removeItem('id_token');
    localStorage.removeItem('expires_at');
  }

  public isLoggedIn() {
    return moment().isBefore(this.getExpiration());
  }

  isLoggedOut() {
    return !this.isLoggedIn();
  }

  getExpiration() {
    const expiration = localStorage.getItem('expires_at');
    let expiresAt;
    if (expiration) {
      expiresAt = JSON.parse(expiration);
    }
    return moment(expiresAt);
  }

  getToken() {
    return localStorage.getItem('id_token');
  }
}
