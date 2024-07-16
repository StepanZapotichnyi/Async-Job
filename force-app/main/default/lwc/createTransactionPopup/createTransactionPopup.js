import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  LightningModal  from 'lightning/modal';


export default class CreateTransactionPopup extends LightningModal {
    
    nameTransaction = '';
    quantityTransaction = 0;
    pricePerCoinTransaction = 0;
    
    handleNameChange(event) {
        this.nameTransaction = event.target.value;
    }

    handleQuantityChange(event) {
        this.quantityTransaction = event.target.value;
    }
    handlePricePerCoinChange(event) {
        this.pricePerCoinTransaction = event.target.value;
    }

    handleAddTransaction() {
        if(!this.nameTransaction) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Field Name should not be empty',
                    variant: 'error'
                })
            );

        }else {
            this.close( {
                nameTransaction: this.nameTransaction,
                quantityTransaction: this.quantityTransaction,
                pricePerCoinTransaction: this.pricePerCoinTransaction
            });
        }  
        
    }

}