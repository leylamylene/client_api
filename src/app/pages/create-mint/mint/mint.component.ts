import { CommonModule } from '@angular/common';
import { Component, signal } from '@angular/core';
import { Router } from '@angular/router';
import { Deploy1155Component } from '../deploy1155/deploy1155.component';
import { Deploy721Component } from '../../collection/deploy/collection/deploy721.component';

@Component({
  selector: 'app-mint',
  standalone: true,

  imports: [CommonModule, Deploy1155Component, Deploy721Component],
  templateUrl: './mint.component.html',
  styleUrl: './mint.component.css',
})
export class MintComponent {
  stepOne: boolean = true;
  stepTwo: boolean = false;
  collectionType: string = '';
  constructor(private router: Router) {}

  createForm(): void {}

  dropCollection() {
    this.stepOne = false;
    this.stepTwo = true;
    this.collectionType = 'drop';
  }

  mintNFT() {
    this.stepOne = false;
    this.stepTwo = true;
    this.collectionType = 'mint';
  }
}
