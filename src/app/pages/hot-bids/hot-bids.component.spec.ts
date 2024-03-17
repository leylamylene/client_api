import { ComponentFixture, TestBed } from '@angular/core/testing';

import { HotBidsComponent } from './hot-bids.component';

describe('HotBidsComponent', () => {
  let component: HotBidsComponent;
  let fixture: ComponentFixture<HotBidsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HotBidsComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(HotBidsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
