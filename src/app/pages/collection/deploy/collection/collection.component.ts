import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';

@Component({
  selector: 'app-collection',
  standalone: true,
  imports: [CommonModule, ButtonModule, InputTextModule],
  templateUrl: './collection.component.html',
  styleUrl: './collection.component.css',
})
export class CollectionComponent {
  filePreview: string | ArrayBuffer | null = null;
  isImage = false;
  isVideo = false;
  continue() {}

  onFileSelected($event: any) {}

  deleteFile() {}

  onDragOver($event: any) {}

  onFileDropped($event: any) {}
}
