import { Component } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { RegisterFormComponent } from '../../register-form/register-form.component';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css',
})
export class NavbarComponent {
  registerOpened: boolean = false;
  hovered: boolean = false;
  constructor(public dialog: MatDialog) {}

  hover(hover: boolean) {
    this.hovered = hover;
  }

  openSignUp(): void {
    if (!this.registerOpened) {
      const dialogRef = this.dialog.open(RegisterFormComponent, {
        width: '800px',
        position: {
          top: '40vh',
          left: '50vw',
        },
        panelClass: 'custom-modalbox',
        data: {},
      });

      dialogRef.afterClosed().subscribe((result) => {
        this.registerOpened = false;
      });

      this.registerOpened = true;
    }
  }
}
