import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  LightningModal  from 'lightning/modal';

export default class CreatePortfolio extends LightningModal {
    
    labelValue = '';
    
    handleLabelChange(event) {
        this.labelValue = event.target.value;
    }

    handleSave(){  

          if(!this.labelValue ) {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Name should not be  empty',
                      variant: 'error'
                  })
              );
              return;
          }

          console.log(this.labelValue);
          if(this.labelValue) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Name should not be longer than 20 sings',
                    variant: 'error'
                })
            );
            return;
        }
  
  
           this.close({
               label: this.labelValue
          });
      }  
       
  }