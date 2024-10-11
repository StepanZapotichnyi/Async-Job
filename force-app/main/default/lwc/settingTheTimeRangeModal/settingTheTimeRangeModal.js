
import  LightningModal  from 'lightning/modal';
import {  track } from 'lwc';

export default class SettingTheTimeRangeModal extends LightningModal {

    dataStarting = '';
    dataEnding  = '';

    @track today = ''
    @track lastThirtyDays = '';
    
    
    
    connectedCallback(){
        this.setTodayAndLastThirtyDays();

    }

    setTodayAndLastThirtyDays() {
        
        let date = new Date();
        this.today = date.toISOString().split('T')[0]; 
        
        date.setDate(date.getDate() - 30); 
        this.lastThirtyDays = date.toISOString().split('T')[0];
        
    }

    handleChangeDateStart(event){
        this.dateStarting = event?.detail?.value;
        console.log(this.dateStarting);
    }

    
    handleChangeDateEnd(event){
        this.dateEnding = event?.detail?.value;
        console.log(event);
    }

    handleContinue() {
        this.isNotEmpty(this.dateStarting, this.dateEnding);
    
        if (this.dateStarting && this.dateEnding) {
            this.close({
                startDate: this.dateStarting,
                endDate: this.dateEnding
            });
        } else {
            this.close();
        }
    }

    isNotEmpty(starting, ending) {  
        if (!starting) {
            this.dateStarting = this.today; 
        }
        if (!ending) {
            this.dateEnding = this.lastThirtyDays; 
        }
    }
}