import { LightningElement, track } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import CreatePortfolio from 'c/createPortfolio';
import CreateTransactionPopup from 'c/createTransactionPopup';
import createPortfolio from '@salesforce/apex/PortfolioController.createPortfolio';
import createTransaction from '@salesforce/apex/PortfolioController.createTransaction';
import getPortfolios from '@salesforce/apex/PortfolioController.getPortfolios';
import getTransaction from '@salesforce/apex/PortfolioController.getTransaction';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' },
];

const COLUMNS = [
    {label: 'Name', fieldName : 'name'},
    {label: 'Price', fieldName : 'price'},
    {label: 'Holdings', fieldName : 'holdings'},
    {label: 'Avg. Buy Price', fieldName : 'average'},
    {label: 'Profit/Loss', fieldName : 'profitAndLoss'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
const PAGE_SIZE = 9;


export default class Portfolio extends LightningElement {
    @track toggle = false;
    @track isIconUp = false;
    @track isIconDown = false;
    @track isPaginator = false

    @track portfolios = [];
    @track selectedPortfolio = {};
    @track dataTable = [];
    @track pageNumber = 1;
    @track numberOfPages;
    @track averageProfitAndLoss = 0;
    
    priceList = {};
    startingPageIndex = 1;
    endingPageIndex = 0;
    totalRecordCount;
    columns = COLUMNS;

    connectedCallback() {
        console.log('call' + JSON.stringify(this.portfolios));
        this.loadPortfolios();
    }
    
    async loadPortfolios(toggle) {
        console.log('Loading data from server...');
        try{
            this.portfolios = await getPortfolios();
            console.log('id' + JSON.stringify(this.portfolios));
            if(toggle) {
                this.selectedPortfolio = this.portfolios[this.portfolios.length - 1];
                this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
         
            }else{
                this.selectedPortfolio = this.portfolios[0];
                this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});

            }
            console.log( JSON.stringify(this.selectedPortfolio));
        }catch (error){
            console.error('Error loading data', error);
        }
    }



    async handleMyPortfolio() {
        this.toggle = true;
        console.log('1work');
        await this.loadPortfolios(false);
        // console.log('3work');
        // this.selectedPortfolio = this.portfolios[0]

        //  if (!this.portfolios) {
        //         this.selectedPortfolio = this.portfolios[0]; // Присвоєння першого об'єкта
        // } else {
        //         this.selectedPortfolio = {}; // Або null, якщо список порожній
        // }

    }


    async handleCreatePortfolio() {
        console.log('HE');
        const result = await CreatePortfolio.open({
            size: 'Small',
            label: 'Portfolio',
            description: 'This is a modal popup'
        });
        console.log(result.label);

        createPortfolio({ name: result.label})
            .then(created => {
                this.portfolios = created;
                console.log( JSON.stringify(this.portfolios));
                this.showToast('Success', 'Portfolio Created', 'success');
                
                this.loadPortfolios(true);
                // this.selectedPortfolio = this.portfolios[0];
                // this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            })
            .catch(error =>{
                this.showToast('Error', 'Portfolio not created', 'error');
            }) 
    }

    handleSelectPortfolio(event) {
        const portfolioId = event.currentTarget.dataset.id;
        console.log(portfolioId);
        
        this.selectedPortfolio = this.portfolios.find(portfolio => portfolio.Id == portfolioId);
        console.log( 'ff' + JSON.stringify(this.selectedPortfolio));
        
        console.log(portfolioId);
        getTransaction({accountId : portfolioId})
            .then(transaction => {
                //  testData = transaction;
                console.log(JSON.stringify(transaction));
                
                    
                this.priceList = transaction.map(trans =>({
                    name: trans.Name,
                    price:trans.Price_Per_Coin__c ,
                    holdings: trans.TotalOpportunityQuantity, 
                    average: '120.00', 
                    profitAndLoss: '30099999999.00'
                }));   
                
 
                this.totalRecordCount = this.priceList.length;
                this.numberOfPages = Math.ceil(this.totalRecordCount / PAGE_SIZE);
                console.log(this.totalRecordCount);
                this.displayRecordPerPage(this.pageNumber);
                console.log('pp'+JSON.stringify(this.priceList));
                this.calculateAverageProfitAndLoss(this.priceList);
        

            })
            .catch(error =>{
                this.showToast('Error', 'Transaction do not loaded', 'error');

            })

    }

    prevHandler(event) {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.displayRecordPerPage(this.pageNumber);
        }
    }

    nextHandler(event) {
        if (this.pageNumber < this.numberOfPages) {
            this.pageNumber += 1;
            this.displayRecordPerPage(this.pageNumber);
        }
    }

    displayRecordPerPage(page) {
        this.startingPageIndex = (page - 1) * PAGE_SIZE;
        this.endingPageIndex = page * PAGE_SIZE;
        this.dataTable = this.priceList.slice(this.startingPageIndex, this.endingPageIndex);

        console.log( 'after++'+this.dataTable.length);
        if(this.dataTable.length >= 9){
            console.log( 'if'+this.dataTable.length);
            this.isPaginator = true;
        }else{
            this.isPaginator = false;
        }

        console.log('45 ++ '+JSON.stringify(this.dataTable));
    }

    async handleNewTransaction() {
        console.log('2' + this.selectedPortfolio.Id);
    
    
        const resultTransactionPopup = await CreateTransactionPopup.open({
            size: 'Small',
            label: 'Transaction',
            description: 'This is a modal popup'
        });
        
        console.log(JSON.stringify(resultTransactionPopup));
        if(resultTransactionPopup) {
            // console.log('4' + JSON.stringify(this.priceList));

            createTransaction({ 
                accountId : this.selectedPortfolio.Id,
                name : resultTransactionPopup.nameTransaction,
                quantity : resultTransactionPopup.quantityTransaction,
                pricePerCoin : resultTransactionPopup.pricePerCoinTransaction
             })

             .then(transaction => {
                console.log( JSON.stringify(transaction));
                this.showToast('Success', 'Transaction Created', 'success');
                // this.handlePortfolio(transaction.accountId);
                this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});


            })
            .catch(error =>{
                this.showToast('Error', 'Transaction not created', 'error');

            })

        }
    } 

    async handleAddTransaction() {
        const resultTransactionPopup = await CreateTransactionPopup.open({
            size: 'small',
            label: 'Transaction',
            description: 'This is a modal popup'
        });
        console.log(JSON.stringify(resultTransactionPopup));

        if(resultTransactionPopup) {
            // console.log('4' + JSON.stringify(this.priceList));

            createTransaction({ 
                accountId : this.selectedPortfolio.Id,
                name : resultTransactionPopup.nameTransaction,
                quantity : resultTransactionPopup.quantityTransaction,
                pricePerCoin : resultTransactionPopup.pricePerCoinTransaction
             })

             .then(transaction => {
                console.log( JSON.stringify(transaction));
                this.showToast('Success', 'Transaction Created', 'success');
                // this.handlePortfolio(transaction.accountId);
                this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});


            })
            .catch(error =>{
                this.showToast('Error', 'Transaction not created', 'error');

            })

        }

    }

    calculateAverageProfitAndLoss(priceList) {
        console.log('ddd' + priceList);
        // if (priceList) {
            let profitAndLossValues = priceList.map(item => parseFloat(item.profitAndLoss));    
            this.averageProfitAndLoss = profitAndLossValues.reduce((total, value) => total + value, 0);
            // this.averageProfitAndLoss = 0;

            console.log('ave' + this.averageProfitAndLoss);
            this.addStyleToAverage(this.averageProfitAndLoss);      
        // }else{
            
        //     // this.averageProfitAndLoss = 0;
        //     console.log('else' + this.averageProfitAndLoss);
        // }
        
    }

    addStyleToAverage(averageProfitAndLoss) {
        
        const textElement = this.template.querySelector('.aside_context_average');

        if(textElement) { 
            if(averageProfitAndLoss > 0) {
                this.isIconUp = true;
                this.isIconDown = false;
                textElement.style.color = '#32e462';
            } else if(averageProfitAndLoss < 0) {
                this.isIconUp = false;
                this.isIconDown = true;
                textElement.style.color = 'red';
            } else{
                this.isIconUp = false;
                this.isIconDown = false;
                textElement.style.color = 'black';
                
            };
        }
    }

    handleRename(){
        
        console.log('hell');
        console.log('hell' + this.selectedPortfolio);
    }

    handleRemove(){
        
        console.log('hell');
        console.log('hell' + this.selectedPortfolio);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'show_details':
                this.showDetails(row);
                break;
            case 'delete':
                this.deleteRow(row);
                break;
            default:
        }
    }

    showDetails(row) {
        // Implement show details logic here
        console.log('Showing details for:', row);
    }

    deleteRow(row) {
        // Implement delete logic here
        console.log('Deleting row:', row);
        this.data = this.data.filter(item => item.name !== row.name);
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