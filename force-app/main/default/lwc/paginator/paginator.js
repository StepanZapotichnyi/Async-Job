import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {
    @api pageNumber;
    @api numberOfPages;
    
    handelPrevious(event) {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext(event) {
        this.dispatchEvent(new CustomEvent('next'));
    }
}