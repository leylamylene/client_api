import { Component, ViewEncapsulation, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { HousingLocationComponent } from '../housing-location/housing-location.component';
import { HousingLocation } from '../housinglocation';
import { HousingService } from '../housing.service';
import {
  MatDialog,
  MAT_DIALOG_DATA,
  MatDialogRef,
  MatDialogTitle,
  MatDialogContent,
  MatDialogActions,
  MatDialogClose,
  MatDialogModule,
} from '@angular/material/dialog';
import { RegisterFormComponent } from '../register-form/register-form.component';
import { NavbarComponent } from '../components/navbar/navbar.component';
import { RouterOutlet } from '@angular/router';
import { CategoryBarComponent } from '../components/category-bar/category-bar.component';
@Component({
  selector: 'app-home',
  standalone: true,
  imports: [
    CommonModule,
    NavbarComponent,
    MatDialogModule,
    MatCardModule,
    CategoryBarComponent,
  ],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css'],
  encapsulation: ViewEncapsulation.None,
})
export class HomeComponent {
  housingLocationList: HousingLocation[] = [];
  housingService: HousingService = inject(HousingService);
  filteredLocationList: HousingLocation[] = [];
  items: any[] = [
    {
      title: 'Beautiful Landscape',
      description:
        'Explore the breathtaking beauty of nature with our landscape photography collection.',
      imageUrl: 'https://via.placeholder.com/300x200',
    },
    {
      title: 'Tech Gadgets',
      description:
        'Discover the latest tech gadgets and accessories for your everyday life.',
      imageUrl: 'https://via.placeholder.com/300x200',
    },
    {
      title: 'Healthy Recipes',
      description:
        'Get inspired by our collection of delicious and nutritious recipes.',
      imageUrl: 'https://via.placeholder.com/300x200',
    },
  ];
  constructor() {}

  ngOnInit() {
    console.log('ng onint hooooooome');
  }
  filterResults(text: string) {
    if (!text) {
      this.filteredLocationList = this.housingLocationList;
      return;
    }

    this.filteredLocationList = this.housingLocationList.filter(
      (housingLocation) =>
        housingLocation?.city.toLowerCase().includes(text.toLowerCase())
    );
  }
}
