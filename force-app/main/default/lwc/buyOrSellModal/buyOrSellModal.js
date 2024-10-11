import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  LightningModal  from 'lightning/modal';
import createTransaction from '@salesforce/apex/TransactionController.createTransaction';
import {  api } from 'lwc';


export default class BuyOrSellModal extends LightningModal {
    
    @api transaction;
   

    quantityTransaction = 0;
    priceTransaction = 0;


    connectedCallback() {
        if (this.transaction) {
            this.priceTransaction = parseFloat(this.transaction.price);
        }
    }

    handleQuantityChange(event) {
        this.quantityTransaction = parseFloat(event.target.value);
        
    }

    handlePriceChange(event) {
        this.priceTransaction = parseFloat(event.target.value);
        
    }
    
    handleTransaction(){
        if(this.quantityTransaction === 0) {
            this.close();
            this.showToast('Info', 'The transaction did not take place because you did not fill in the fields!', 'info'); 
            return;
        }

        if (this.transaction.type === 'Sell' && !this.validateSellTransaction(this.quantityTransaction)) {
            this.showToast('Error', 'Not enough tokens', 'error');
            return;
        }
        this.handleTransactionCreation(this.createToTransactionData(this.transaction));


    }

    createToTransactionData(token) {
        return {
            portfolioCurrencyId: token.id,
            typeTransaction: token.type,
            symbol: token.name,
            quantityTransaction: this.quantityTransaction,
            amountTransaction: (this.quantityTransaction * this.priceTransaction).toFixed(4),
        }
    }

    handleTransactionCreation(transactionData) {
        createTransaction({data: JSON.stringify(transactionData)})
        this.close();
        
    }



    validateSellTransaction(quantityTransaction){
        if(this.transaction.holdings < quantityTransaction ){
            return false;
        }
        return true;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }  


}
