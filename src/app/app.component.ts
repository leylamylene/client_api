import { Component, OnInit, Signal, signal } from '@angular/core';

import { RouterLink, RouterModule, RouterOutlet } from '@angular/router';
import { Subscription } from 'rxjs';
import { LoaderService } from './services/loader.service';
import { CommonModule } from '@angular/common';
import { ToastModule } from 'primeng/toast';
import {
  ErrorHandlerService,
  HttpError,
} from './services/error-handler.service';
import { SuccessHandlerService } from './services/successHandler.service';
import { MetamaskLoginService } from './services/auth/metamask/meatamask-login.service';
import { AppConfigComponent } from './layout/config/app.config.component';
import { AppMenuitemComponent } from './layout/app.menuitem.component';
import { AppTopBarComponent } from './layout/app.topbar.component';
import { AppFooterComponent } from './layout/app.footer.component';
import { AppMenuComponent } from './layout/app.menu.component';
import Web3 from 'web3';
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    RouterModule,
    RouterLink,
    RouterOutlet,
    CommonModule,
    ToastModule,
    AppConfigComponent,
    AppMenuitemComponent,
    AppTopBarComponent,
    AppFooterComponent,
    AppMenuComponent,
  ],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent implements OnInit {
  web3!: Web3;
  loading: boolean = false;
  loadingSubscription!: Subscription;
  errorSubscription!: Subscription;
  successSubscription!: Subscription;
  error: HttpError = { status: undefined, message: undefined };
  success: boolean = false;
  constructor(
    private loaderService: LoaderService,
    private errorHandler: ErrorHandlerService,
    private successHanler: SuccessHandlerService,
    private metamaskSrv: MetamaskLoginService
  ) {
    this.web3 = new Web3(window.ethereum);
  }

  ngOnInit() {
    this.listenAccounts();
    this.interceptorsWorker();
  }

  interceptorsWorker() {
    this.getIsLoading();
    this.getIsError();
    this.getIsSuccess();
  }

  listenAccounts() {
    //@ts-ignore
    window.ethereum.on('accountsChanged', async () => {
      var accounts = await this.web3.eth.getAccounts();
      this.metamaskSrv.setWallet(!!accounts[0]);
      // if wallet disconnected , show the login modal
    });
  }
  getIsLoading() {
    this.loadingSubscription = this.loaderService
      .getLoading()
      .subscribe((loading: boolean) => {
        this.loading = loading;
      });
  }
  getIsError() {
    this.errorSubscription = this.errorHandler.getError().subscribe((error) => {
      this.error = error;
      setTimeout(() => {
        this.error = { status: undefined, message: undefined };
      }, 3000);
    });
  }
  getIsSuccess() {
    this.successSubscription = this.successHanler
      .getStatus()
      .subscribe((success: boolean) => {
        this.success = success;
        setTimeout(() => {
          this.success = false;
        }, 3000);
      });
  }

  ngOnDestroy() {
    if (this.loadingSubscription) {
      this.loadingSubscription.unsubscribe();
      this.errorSubscription.unsubscribe();
      this.successSubscription.unsubscribe();
    }
  }
}
