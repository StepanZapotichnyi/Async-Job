import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkTokenPresenceSymbol from '@salesforce/apex/UtilityToPortfolio.checkTokenPresenceSymbol';
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
        console.log('work' + this.nameTransaction);
        
        if(!this.nameTransaction) {
            console.log('work1' + this.nameTransaction);
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Field Name should not be empty',
                    variant: 'error'
                })
            );
            
        }else {
            checkTokenPresenceSymbol({ symbol: this.nameTransaction.toUpperCase() })
            .then(response => {
                console.log(response);
                this.close({
                    nameTransaction: response,
                    quantityTransaction: this.quantityTransaction,
                    pricePerCoinTransaction: this.pricePerCoinTransaction
                });
            })
            .catch(error => {
                console.error('error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
            
        }  
        
        
    }

}