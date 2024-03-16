import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextareaModule } from 'primeng/inputtextarea';

@Component({
  selector: 'app-deploy1155',
  standalone: true,
  imports: [CommonModule, ButtonModule, InputTextModule, InputTextareaModule],
  templateUrl: './deploy1155.component.html',
  styleUrl: './deploy1155.component.css'
})
export class Deploy1155Component {
  constructor(private router: Router){
    
  }
  filePreview: string | ArrayBuffer | null = null;
  isImage: boolean = false;
  isVideo: boolean = false;
  onFileSelected(event: Event): void {
    // Handle file selection (e.g., store file data)
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

  displayFilePreview(file: File): void {
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

  addCollection() {
    this.router.navigate(['/collection/deploy']);
  }

}
