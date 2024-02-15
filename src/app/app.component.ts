import { Component, OnInit } from '@angular/core';

import { RouterLink, RouterModule, RouterOutlet } from '@angular/router';
import { Subscription } from 'rxjs';
import { LoaderService } from './services/loader.service';
import { CommonModule } from '@angular/common';
import { ToastModule } from 'primeng/toast';
import {
  ErrorHandlerService,
  HttpError,
} from './services/error-handler.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterModule, RouterLink, RouterOutlet, CommonModule, ToastModule],
  template: `
    <main class="">
      <section class="content">
        <router-outlet></router-outlet>
      </section>
    </main>
    <ng-container *ngIf="loading">
      <div class="spinner-overlay">
        <div class="spinner"></div>
      </div>
    </ng-container>

    <ng-container *ngIf="error.message">
      <div id="toast" class="show">
        <div id="desc">{{ error.message }}</div>
      </div>
    </ng-container>
  `,
  styleUrls: ['./app.component.css'],
})
export class AppComponent implements OnInit {
  constructor(
    private loaderService: LoaderService,
    private errorHandler: ErrorHandlerService
  ) {}
  loading: boolean = false;
  loadingSubscription!: Subscription;
  errorSubscription!: Subscription;
  error: HttpError = { status: undefined, message: undefined };
  title = 'homes';

  ngOnInit() {
    this.loadingSubscription = this.loaderService
      .getLoading()
      .subscribe((loading: boolean) => {
        this.loading = loading;
        console.log('loading', this.loading);
      });
    this.errorSubscription = this.errorHandler.getError().subscribe((error) => {
      this.error = error;
      setTimeout(() => {
        this.error = { status: undefined, message: undefined };
      } , 3000);
    });
  }

  ngOnDestroy() {
    if (this.loadingSubscription) {
      this.loadingSubscription.unsubscribe();
      this.errorSubscription.unsubscribe();
    }
  }
}
