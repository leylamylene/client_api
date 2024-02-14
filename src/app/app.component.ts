import { Component, OnInit } from '@angular/core';

import { RouterLink, RouterModule, RouterOutlet } from '@angular/router';
import { Subscription } from 'rxjs';
import { LoaderService } from './services/loader.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterModule, RouterLink, RouterOutlet, CommonModule],
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
  `,
  styleUrls: ['./app.component.css'],
})
export class AppComponent implements OnInit {
  constructor(private loaderService: LoaderService) {}
  loading: boolean = false;
  loadingSubscription!: Subscription;
  title = 'homes';

  ngOnInit() {
    this.loadingSubscription = this.loaderService
      .getLoading()
      .subscribe((loading: boolean) => {
        this.loading = loading;
        console.log('loading' , this.loading)
      });
  }

  ngOnDestroy() {
    if (this.loadingSubscription) {
      this.loadingSubscription.unsubscribe();
    }
  }
}
