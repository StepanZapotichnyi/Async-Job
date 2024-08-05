import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  LightningModal  from 'lightning/modal';
import updateTransaction from '@salesforce/apex/PortfolioController.updateTransaction';
import deleteTransaction from '@salesforce/apex/PortfolioController.deleteTransaction';
import {  api } from 'lwc';


export default class BuyOrSellPopup extends LightningModal {
    
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
        console.log( 'ss' +event.target.value);
        this.priceTransaction = parseFloat(event.target.value);
        
    }
    
    handleTransaction(){
        if(this.quantityTransaction === 0) {
            this.close();
            this.showToast('Info', 'The transaction did not take place because you did not fill in the fields!', 'info'); 
            return;
        }
            
        if(this.transaction.type === 'Buy'){
            if(this.validateBuyTransaction()){
                console.log( 'work');
                
                const newTransactionBuying =  this.calculateToBuyTransaction(this.transaction);
                this.updateNewTransaction(newTransactionBuying);
                
        }
                
        }else if(this.transaction.type ==='Sell'){
            if(this.validateSellTransaction()){
                
                const newTransactionSelling = this.calculateToSellTransaction(this.transaction);
                if (newTransactionSelling.Quantity__c <= 0 ) {
                    console.log('work');
                    this.completeSellTransaction(newTransactionSelling.Id);
                    // this.close({ transaction: newTransaction});
                    
                }else{
                    console.log('work1');
                    console.log( 'newTransaction' + JSON.stringify(newTransactionSelling));
                    this.updateNewTransaction(newTransactionSelling);
                    // this.close({ transaction: newTransaction });
                }   
            }
        }

    }

    

    calculateToBuyTransaction(token){
        
        let totalHoldings = parseFloat(this.quantityTransaction + token.holdings);
    
        let totalFirst = parseFloat(token.holdings * token.average);
    
        let totalSecond = parseFloat(this.quantityTransaction * this.priceTransaction);
      
        let average = parseFloat((totalFirst + totalSecond) / totalHoldings); 
        console.log(average);

        return this.createNewTransaction(totalHoldings, average, token);
    }

    calculateToSellTransaction(token){
        console.log('C21');
        let totalHoldings = parseFloat(token.holdings - this.quantityTransaction);

        return this.createNewTransaction(totalHoldings, token.average, token);

    }
    

    // createNewTransaction(totalHoldings, average, token){
    //     return {
    //         id: token.id,
    //         name: token.name,
    //         type: token.type,
    //         price: token.price,
    //         holdings: totalHoldings,
    //         average: average, 
    //         profitAndLoss: token.profitAndLoss,
    //         totalProfitAndLoss: token.totalProfitAndLoss
    //     };
    // }

    createNewTransaction(totalHoldings, average, token){
        return {
            Id: token.id,
            Name: token.name,
            Quantity__c: totalHoldings,
            Price_Per_Coin__c: average, 
        };
    }

    updateNewTransaction(newTransaction){
        console.log('work' +newTransaction);
        updateTransaction({ opportunityTransaction : newTransaction})
        .then(result => {
            console.log(result);
        this.close({transaction : newTransaction});
        this.showToast('Success', 'Transaction has been created', 'success');
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

    completeSellTransaction(id) {
        deleteTransaction({opportunityId : id})
        .then(result => {
            console.log(result);
        this.close();
        this.showToast('Success', 'You have successfully sold your all tokens', 'success');
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


    validateBuyTransaction(){
        if(this.quantityTransaction <= 0){

            this.close({transaction :this.transaction});
            return false;
        }
        return true;
    }
    
    validateSellTransaction(){

        if(this.transaction.holdings < this.quantityTransaction ){
            this.showToast('Error', 'Not enough tokens', 'error');
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