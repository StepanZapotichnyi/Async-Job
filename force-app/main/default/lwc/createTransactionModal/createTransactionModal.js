import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyTokenSymbol from '@salesforce/apex/UtilityToPortfolio.verifyTokenSymbol';
import  LightningModal  from 'lightning/modal';


export default class CreateTransactionModal extends LightningModal {
    
    symbolTransaction = '';
    quantityTransaction = 0;
    amountTransaction = 0;
    
    handleTokenSymbolChange(event) {
        this.symbolTransaction =  event.target.value;
    }

    handleQuantityChange(event) {
        this.quantityTransaction =  parseFloat(event.target.value);
    }
    handleAmountChange(event) {
        this.amountTransaction = event.target.value;
    }
    
    
    handleAddTransaction() {
        
        if(!this.symbolTransaction) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Field Name should not be empty',
                    variant: 'error'
                })
            );
            
        }else {
            verifyTokenSymbol({ symbol: this.symbolTransaction.toUpperCase() })
            .then(response => {
                this.close({
                    symbolTransaction: response,
                    quantityTransaction: this.quantityTransaction,
                    amountTransaction: this.amountTransaction
                });
            })
            .catch(error => {
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