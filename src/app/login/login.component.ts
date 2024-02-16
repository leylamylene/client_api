import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { MatDialogModule } from '@angular/material/dialog';
import { AuthService } from '../services/auth/auth.service';
import { CommonModule } from '@angular/common';

import { ButtonModule } from 'primeng/button';
import { CheckboxModule } from 'primeng/checkbox';
import { PasswordModule } from 'primeng/password';
import { InputTextModule } from 'primeng/inputtext';
import { Router, RouterLink } from '@angular/router';
import { LayoutService } from '../layout/service/app.layout.service';
import { InputGroupModule } from 'primeng/inputgroup';
import { Subscription } from 'rxjs';
import { AutoFocusModule } from 'primeng/autofocus';
import { MeatamaskLoginService } from '../services/metamask/meatamask-login.service';
@Component({
  selector: 'app-register-form',
  standalone: true,
  imports: [
    CommonModule,
    MatDialogModule,
    FormsModule,
    ReactiveFormsModule,
    ButtonModule,
    CheckboxModule,
    InputTextModule,
    PasswordModule,
    RouterLink,
    InputGroupModule,
    AutoFocusModule,
  ],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css'],
})
export class LoginComponent implements OnInit, OnDestroy {
  loginForm!: FormGroup;
  codeVerifForm!: FormGroup;
  subscription!: Subscription;
  pdLessPart_1: boolean = false;
  loggedIn: boolean = false;
  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    public layoutService: LayoutService,
    private router: Router,
    private metamaskLoginS: MeatamaskLoginService
  ) {}

  ngOnInit(): void {
    this.createloginForm();
    this.createCodeVerifFor();
  }
  createloginForm(): void {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
    });
  }

  createCodeVerifFor(): void {
    this.codeVerifForm = this.fb.group({
      input1: [''],
      input2: [''],
      input3: [''],
      input4: [''],
      input5: [''],
      input6: [''],
    });
    this.authenticate();
  }

  authenticate() {
    this.codeVerifForm.valueChanges.subscribe((value) => {
      if (Object.values(value).join('').length == 6) {
        this.authService
          .authenticatePdLess(
            this.loginForm.controls['email'].value,
            Object.values(value).join('')
          )
          .subscribe((value) => {
            if (value.token) {
              this.router.navigate(['home']);
            }
          });
      }
    });
  }

  handleAuthResponse(value: any) {
    this.authService.setSession(value);
  }
  onSubmit(): void {
    if (this.loginForm.valid) {
      this.callLogin();
    } else {
      // Form is invalid
      console.log('Form is invalid. Please check the fields.');
    }
  }

  callLogin() {
    this.subscription = this.authService
      .passwordlessLogin(this.loginForm.controls['email'].value)
      .subscribe((data) => {
        console.log('data', data);
        this.pdLessPart_1 = true;
      });
  }

  async metamaskConnect() {
    this.metamaskLoginS.connectMetamask();
  }
  onKeyup(i: number, event: KeyboardEvent) {
    const input = event.target as HTMLInputElement;
    if (
      input.value.length > 0 &&
      i < Object.keys(this.codeVerifForm.controls).length - 1
    ) {
      const nextInput = document.querySelector(
        `input[ng-reflect-name="input${i + 2}"]`
      ) as HTMLInputElement;
      nextInput.focus();
    }
  }
  ngOnDestroy() {
    this.subscription.unsubscribe();
  }
}
