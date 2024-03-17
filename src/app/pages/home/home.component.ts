import { Component, OnInit } from '@angular/core';
import { AppTopBarComponent } from '../../layout/app.topbar.component';
import { HotBidsComponent } from '../hot-bids/hot-bids.component';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule ,AppTopBarComponent , HotBidsComponent],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css',
})
export class HomeComponent implements OnInit{

  hotBids : any[] =[];
constructor(private httpClient :HttpClient){

}


ngOnInit(){
  this.getHotBids();
}

  getHotBids() {
    //use service later
    this.httpClient.get('assets/data/hotBids.json').subscribe({
      next: (hotBids) => {
        this.hotBids = hotBids as any[];
       
      },
      error: (errors) => {
        console.log(errors)
      }
    })
  }
}
