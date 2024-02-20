import { CommonModule } from '@angular/common';
import { Component, signal } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextareaModule } from 'primeng/inputtextarea';

@Component({
  selector: 'app-mint',
  standalone: true,

  imports: [CommonModule, ButtonModule, InputTextModule, InputTextareaModule],
  templateUrl: './mint.component.html',
  styleUrl: './mint.component.css',
})
export class MintComponent {
  filePreview: string | ArrayBuffer | null = null;
  isImage = false;
  isVideo = false;
  onFileSelected(event: Event): void {
    // Handle file selection (e.g., store file data)
  }

  createForm(): void {
    // Handle form submission (e.g., send data to server)
  }

  onFileDropped(event: DragEvent): void {
    event.preventDefault();
    const files = event?.dataTransfer?.files;

    if (files && files.length > 0) {
      this.displayFilePreview(files[0]);
    }
    // Process dropped files
  }

  onDragOver(event: DragEvent): void {
    event.preventDefault();
    // Add styling for drag-over effect
  }

  private displayFilePreview(file: File): void {
    if (file.type.startsWith('image/')) {
      this.isImage = true;
      this.isVideo = false;
    } else if (file.type.startsWith('video/')) {
      this.isImage = false;
      this.isVideo = true;
    } else {
      this.isImage = false;
      this.isVideo = false;
    }

    const reader = new FileReader();
    reader.onload = () => {
      this.filePreview = reader.result;
    };
    reader.readAsDataURL(file);
  }
  deleteFile() {
    console.log('buttttton');
    this.filePreview = null;
    this.isImage = false;
    this.isVideo = false;
  }
}
