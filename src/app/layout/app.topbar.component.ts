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
import { MatDialog } from '@angular/material/dialog';
import { LoginComponent } from '../pages/login/login.component';

@Component({
  selector: 'app-topbar',
  templateUrl: './app.topbar.component.html',
  standalone: true,
  imports: [CommonModule, RouterLink, ButtonModule],
  styleUrls: ['./app.topbar.component.css'],
})
export class AppTopBarComponent implements OnInit {
  isLoggedIn: Signal<boolean | undefined> = signal(false);

  items!: MenuItem[];

  @ViewChild('menubutton') menuButton!: ElementRef;

  @ViewChild('topbarmenubutton') topbarMenuButton!: ElementRef;

  @ViewChild('topbarmenu') menu!: ElementRef;

  constructor(
    public layoutService: LayoutService,
    private authService: AuthService,
    private dialog: MatDialog
  ) {
    this.isLoggedIn = toSignal(of(this.authService.isLoggedIn()));
  }

  ngOnInit() {}

  openConnect() {
    this.dialog.open(LoginComponent, {
      width: '380px',
    });
  }
}
