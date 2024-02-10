import { Component } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { MatDialogContent, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { AuthService } from '../services/auth/auth.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-register-form',
  standalone: true,
  imports: [CommonModule, MatDialogModule, FormsModule, ReactiveFormsModule],
  templateUrl: './register-form.component.html',
  styleUrls: ['./register-form.component.css'],
})
export class RegisterFormComponent {
  registrationForm!: FormGroup;
  constructor(private fb: FormBuilder, private authService: AuthService , private dialogRef: MatDialogRef<RegisterFormComponent>) {}

  closeDialog(): void {
    this.dialogRef.close();
  }
  ngOnInit(): void {
    this.createRegistrationForm();
  }
  createRegistrationForm(): void {
    this.registrationForm = this.fb.group(
      {
        username: ['', Validators.required],
        email: ['', [Validators.required, Validators.email]],
        password: ['', [Validators.required, Validators.minLength(6)]],
        confirmPassword: ['', [Validators.required]],
      },
      { validators: this.passwordMatchValidator }
    );
  }

  onSubmit(): void {
    if (this.registrationForm.valid) {
      this.callRegister();
      console.log('Form submitted:', this.registrationForm.value);
    } else {
      // Form is invalid
      console.log('Form is invalid. Please check the fields.');
    }
  }
  passwordMatchValidator(control: AbstractControl) {
    const password = control.get('password')?.value;
    const confirmPassword = control.get('confirmPassword')?.value;
    return password === confirmPassword ? null : { passwordsNotMatch: true };
  }
  callRegister() {
    this.authService
      .register(
        this.registrationForm.controls['username'].value,
        this.registrationForm.controls['email'].value,
        this.registrationForm.controls['password'].value
      )
      .subscribe((data) => {
        console.log('data', data);
        // store the user status in session
        // dispatch login success

        //navigate to home page if success
        //
      });
  }
}
