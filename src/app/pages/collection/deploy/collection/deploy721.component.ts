import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';


@Component({
  selector: 'drop721',
  standalone: true,
  imports: [CommonModule],
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
