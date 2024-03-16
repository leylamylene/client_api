import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';

@Component({
  selector: 'drop721',
  standalone: true,
  imports: [CommonModule, ButtonModule, InputTextModule],
  templateUrl: './deploy721.component.html',
  styleUrl: './deploy721.component.css',
})
export class Deploy721Component {
  filePreview: string | ArrayBuffer | null = null;
  isImage = false;
  isVideo = false;
  continue() {}

  onFileSelected($event: any) {}

  deleteFile() {}

  onDragOver($event: any) {}

  onFileDropped($event: any) {}
}
