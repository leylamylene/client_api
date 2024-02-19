import { HttpClient } from '@angular/common/http';
import { Inject, Injectable } from '@angular/core';
import UrlConstants from '../../constants/apiUrls';
import moment from 'moment';
import { DOCUMENT } from '@angular/common';
import { MetamaskLoginService } from './metamask/meatamask-login.service';
import { toSignal } from '@angular/core/rxjs-interop';
import { Router } from '@angular/router';
import { shareReplay } from 'rxjs';
import Web3 from 'web3';

const BASE_URL = UrlConstants.BASE_URL;
const AUTH_API = UrlConstants.AUTH_API;
@Injectable({
  providedIn: 'root',
})
export class AuthService {
  web3!: Web3;

  constructor(
    private http: HttpClient,
    @Inject(DOCUMENT) private document: Document,
    private metamaskSrv: MetamaskLoginService,
    private router: Router
  ) {
    this.web3 = new Web3(window.ethereum);
  }

  localStorage = this.document.defaultView?.localStorage;

  logout() {
    this.localStorage?.removeItem('id_token');
    this.localStorage?.removeItem('expires_at');
  }

  public isLoggedIn() {
    return (
      moment().isBefore(this.getExpiration()) ||
      !!this.localStorage?.getItem('user')
    );
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
