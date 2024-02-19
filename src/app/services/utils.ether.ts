import { Injectable, signal } from '@angular/core';
import UrlConstants from '../constants/apiUrls';
import Web3 from 'web3';
import { HttpClient } from '@angular/common/http';
import { spinnerFlagedOptions } from './HttpOptions';
export const MESSAGE =
  'Please sign this message to confirm you agree to neffty rules';
const BASE_URL = UrlConstants.BASE_URL;
const AUTH_API = UrlConstants.AUTH_API;

@Injectable({
  providedIn: 'root',
})
export class EthersService {
  web3!: Web3;
  constructor(private http: HttpClient) {
    this.web3 = new Web3(window.ethereum);

  }

  async signMessage(account: string , operation? : string) {
    const message = MESSAGE;
    const signature = await this.web3.eth.personal
    .sign(message, account, `I don't think you can guess !! it's bestila`);
    const verification = this.verifySignature(MESSAGE , signature , account)
    return verification ; 
  }

 verifySignature(message: string, signature: string, account: string ,operation? : string) {
   
    return  this.http
      .post<{ isValid: boolean }>(
        BASE_URL + AUTH_API + '/verifySignature',
        {
          address: account,
          message,
          signature: signature,
        },
        spinnerFlagedOptions
      )
      
  }


}
