import {
  Component,
  ElementRef,
  OnInit,
  Signal,
  ViewChild,
  signal,
} from '@angular/core';
import { MenuItem } from 'primeng/api';
import { LayoutService } from './service/app.layout.service';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { toSignal } from '@angular/core/rxjs-interop';
import { MetamaskLoginService } from '../services/auth/metamask/meatamask-login.service';
import { AuthService } from '../services/auth/auth.service';
import { of } from 'rxjs';

@Component({
  selector: 'app-topbar',
  templateUrl: './app.topbar.component.html',
  standalone: true,

  imports: [CommonModule, RouterLink, ButtonModule],
})
export class AppTopBarComponent implements OnInit {
  isLoggedIn: Signal<boolean | undefined> = signal(false);

  items!: MenuItem[];

  @ViewChild('menubutton') menuButton!: ElementRef;

  @ViewChild('topbarmenubutton') topbarMenuButton!: ElementRef;

  @ViewChild('topbarmenu') menu!: ElementRef;

  constructor(
    public layoutService: LayoutService,
    private authService: AuthService
  ) {
    this.isLoggedIn = toSignal(of(this.authService.isLoggedIn()));
  }

  ngOnInit() {}
}
