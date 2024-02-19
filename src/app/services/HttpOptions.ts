import { HttpHeaders } from "@angular/common/http";

export const httpDefaultOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
    }),
  };
  
  export const spinnerFlagedOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
      'Show-Spinner': 'true',
    }),
  };