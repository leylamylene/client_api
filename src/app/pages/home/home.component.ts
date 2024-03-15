import { Component } from '@angular/core';
import { AppTopBarComponent } from '../../layout/app.topbar.component';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [AppTopBarComponent],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css',
})
export class HomeComponent {}
