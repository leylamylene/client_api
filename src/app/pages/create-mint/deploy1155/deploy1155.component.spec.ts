import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Deploy721Component } from './deploy1155.component';

describe('Deploy721Component', () => {
  let component: Deploy721Component;
  let fixture: ComponentFixture<Deploy721Component>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Deploy721Component],
    }).compileComponents();

    fixture = TestBed.createComponent(Deploy721Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
