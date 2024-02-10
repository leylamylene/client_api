import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, map } from 'rxjs';
import UrlConstants from '../../constants/apiUrls';

const BASE_URL = UrlConstants.BASE_URL;
const AUTH_API = UrlConstants.AUTH_API;

const httpOptions = {
  headers: new HttpHeaders({
    'Content-Type': 'application/json',
  }),
};

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  constructor(private http: HttpClient) {}

  // Function for user login
  login(username: string, password: string): Observable<any> {
    return this.http.post(
      BASE_URL + AUTH_API + 'login',
      { username, password },
      httpOptions
    );
  }

  // Function for user registration
  register(username: string, email: string, password: string): Observable<any> {
    return this.http
      .post(
        BASE_URL + AUTH_API + 'register',
        { username, email, password },
        httpOptions
      )
      .pipe(
        map((response: any) => {
          const { token, user } = response;
          localStorage.setItem('token', token);
          return { user };
        })
      );
  }
}
