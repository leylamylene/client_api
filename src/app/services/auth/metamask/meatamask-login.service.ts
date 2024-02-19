import { Inject, Injectable, inject, signal } from '@angular/core';
import { BehaviorSubject, shareReplay } from 'rxjs';
import { Store } from '@ngrx/store';
import { DOCUMENT } from '@angular/common';
import { EthersService } from '../../utils.ether';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root',
})
export class MetamaskLoginService {
  private readonly store: Store = inject(Store);
  accounts!: string[];
  account!: string;
  loggedIn = new BehaviorSubject<boolean>(false);
  walletConnected = new BehaviorSubject<boolean>(false);
  constructor(
    @Inject(DOCUMENT) private document: Document,
    private ethersSrv: EthersService,
    private router : Router
  ) {}

  localStorage = this.document.defaultView?.localStorage;

  async connectMetamask() {
    const accounts = await window.ethereum.request({
      method: 'eth_requestAccounts',
    });
    this.account = accounts[0];
    const verification = this.ethersSrv.signMessage(this.account, 'login');
    verification.then((value) =>
      value.subscribe((response) => this.handleVerify(response))
    );
  }

  handleVerify(response: any, operation?: string) {
    this.loggedIn.next(response.isValid);
    this.localStorage?.setItem('user', JSON.stringify(response.data));
    this.router.navigate(['home'])
  }

  setWallet(connected: boolean) {
    if (!connected) {
      this.localStorage?.removeItem('user');
    }
    this.walletConnected.next(connected);
  }

  isWalletConnected() {
    return this.walletConnected.asObservable().pipe(shareReplay(1));
  }
}
