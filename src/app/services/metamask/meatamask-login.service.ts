import { Injectable } from '@angular/core';
import Web3 from 'web3';
export const MESSAGE =
  'Please sign this message to confirm you agree to neffty rules';
@Injectable({
  providedIn: 'root',
})
export class MeatamaskLoginService {
  accounts!: string[];
  account!: string;
  web3!: Web3;
  signature!: string;
  constructor() {}

  connectMetamask() {
    window.ethereum
      .request({ method: 'eth_requestAccounts' })
      .then((accounts) => {
        this.account = accounts[0];
        this.web3 = new Web3(window.ethereum);
        this.signMessage(accounts[0]);
      });
  }

  async signMessage(account: any) {
    const message = MESSAGE;

    await this.web3.eth.personal
      .sign(message, account, 'test password')
      .then((signature) => {
        console.log('signature', signature);
        this.verifySignature(signature);
      });
  }

  verifySignature(signature: any) {
    try {
      const recoveredAddress = this.web3.eth.accounts.recover(
        MESSAGE,
        signature
      );
      if (
        recoveredAddress.toLocaleLowerCase() ===
        this.account.toLocaleLowerCase()
      ) {
        console.log('Signature is valid');
      } else {
        console.log('signature is invalid');
      }
    } catch (error) {
      console.log('invalid');
    }
  }
}
