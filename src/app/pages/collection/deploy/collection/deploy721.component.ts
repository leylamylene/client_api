import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import web3 from '../../../../web3';

@Component({
  selector: 'drop721',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './deploy721.component.html',
  styleUrl: './deploy721.component.css',
})
export class Deploy721Component implements OnInit {
  filePreview: string | ArrayBuffer | null = null;
  isImage = false;
  isVideo = false;
  marketAddress = '0x925517C15f4Ec1cD49E7f26a9130ba1cFCFA35f4';
  contractAddress = '0xbdbFd4b2e6D490bc3dC39eb66063b40731881c9B';
  ERC721DropFactory = require('../../../../../../artifacts/contracts/ERC721DropFactory.sol/ERC721DropFactory.json');

  ngOnInit(): void {
    this.createClone();
  }
  async createClone() {
    // console.log('TYPE OF ERCFACTORY FROM FILE', typeof this.ERC721DropFactory);
    // let parsed = JSON.parse(this.ERC721DropFactory);
    let contractABI = this.ERC721DropFactory.abi;
    const dropFactoryInstance = new web3.eth.Contract(
      contractABI,
      this.contractAddress
    );

    try {
      const accounts = await web3.eth.getAccounts();
      const tx = await dropFactoryInstance.methods['createClone'](
        'm ycolle',
        'hdg',
        this.marketAddress
      ).send({
        from: accounts[0],
        value: web3.utils.toWei('', 'ether'),
      });
      const txReceipt = tx.events ? tx.events['ERC721DropCreated']['data'] : '';
      console.log('topics', web3.eth.abi.decodeParameter('address', txReceipt));
    } catch (err) {}
  }
  continue() {}

  onFileSelected($event: any) {}

  deleteFile() {}

  onDragOver($event: any) {}

  onFileDropped($event: any) {}
}
