import { Component, OnDestroy, OnInit, Signal, signal } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { MatDialogModule } from '@angular/material/dialog';
import { CommonModule } from '@angular/common';

import { ButtonModule } from 'primeng/button';
import { CheckboxModule } from 'primeng/checkbox';
import { PasswordModule } from 'primeng/password';
import { InputTextModule } from 'primeng/inputtext';
import { Router, RouterLink } from '@angular/router';
import { LayoutService } from '../../layout/service/app.layout.service';
import { InputGroupModule } from 'primeng/inputgroup';
import { Subscription } from 'rxjs';
import { AutoFocusModule } from 'primeng/autofocus';
import { MetamaskLoginService } from '../../services/auth/metamask/meatamask-login.service';
import { EmailLoginService } from '../../services/auth/email/email-login.service';
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
  login$!: Subscription;
  auth$!: Subscription;
  pdLessPart_1: boolean = false;

  constructor(
    private fb: FormBuilder,
    private emailService: EmailLoginService,
    public layoutService: LayoutService,
    private router: Router,
    private metamaskLoginSrv: MetamaskLoginService
  ) {}

  ngOnInit(): void {
    this.createloginForm();
    this.createCodeVerifF();
  }
  createloginForm(): void {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
    });
  }

  createCodeVerifF(): void {
    this.codeVerifForm = this.fb.group({
      input1: [''],
      input2: [''],
      input3: [''],
      input4: [''],
      input5: [''],
      input6: [''],
    });
    this.authenticateListener();
  }

  authenticateListener() {
    this.codeVerifForm.valueChanges.subscribe((value) => {
      if (Object.values(value).join('').length == 6) {
        this.auth$ = this.emailService
          .authenticatePwrdLess(
            this.loginForm.controls['email'].value,
            Object.values(value).join('')
          )
          .subscribe((authResut) => {
            if (authResut.token) {
              this.emailService.setSession(authResut);
              this.router.navigate(['home']);
            }
          });
      }
    });
  }

  onSubmit(): void {
    if (this.loginForm.valid) {
      this.callLogin();
    } else {
    }
  }

  callLogin() {
    this.login$ = this.emailService
      .passwordlessLogin(this.loginForm.controls['email'].value)
      .subscribe((data) => {
        this.pdLessPart_1 = true;
      });
  }

  async metamaskConnect() {
    this.metamaskLoginSrv.connectMetamask();
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
    if (this.login$) this.login$.unsubscribe();
    if (this.auth$) this.auth$.unsubscribe();
  }
}
