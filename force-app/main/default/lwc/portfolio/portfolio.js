import { LightningElement, track } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import CreatePortfolio from 'c/createPortfolio';
import BuyOrSellPopup  from 'c/buyOrSellPopup';
import CreateTransactionPopup from 'c/createTransactionPopup';
import createPortfolio from '@salesforce/apex/PortfolioController.createPortfolio';
import createTransaction from '@salesforce/apex/PortfolioController.createTransaction';
import getPortfolios from '@salesforce/apex/PortfolioController.getPortfolios';
import getTransaction from '@salesforce/apex/PortfolioController.getTransaction';
import deletePortfolio from '@salesforce/apex/PortfolioController.deletePortfolio';

const actions = [
    { label: 'Buy', name: 'buy_token' },
    { label: 'Sell', name: 'sell_token' },
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
const SYMBOL_USD = '$';


export default class Portfolio extends LightningElement {
    @track toggle = false;
    @track isPaginator = false;
    @track isMenuOpen = false;

    @track portfolios = [];
    @track selectedPortfolio = {};
    @track dataTable = [];
    @track pageNumber = 1;
    @track numberOfPages;
    @track averageProfitAndLoss = 0;
    
    priceList = {};
    // isLoading = false;
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
          
            this.portfolios = await getPortfolios();
            console.log('id' + JSON.stringify(this.portfolios));
            
            if(this.portfolios.length > 0) {  
                if(toggle) {
                    this.selectedPortfolio = this.portfolios[this.portfolios.length - 1];
                    this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            
                }else{
                    console.log('www')  
                    this.selectedPortfolio = this.portfolios[0];
                }
                this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            }else{
                this.addButtonAddPortfolio()
                this.selectedPortfolio = {};
                this.priceList = [];
                this.dataTable = [];
                this.isPaginator = false;
                this.averageProfitAndLoss = 0;
            }
        console.log( JSON.stringify(this.selectedPortfolio));
    }

    



    async handleMyPortfolio() {
        
        this.toggle = true;
        console.log('1work');
        await this.loadPortfolios(false);
        await this.addButtonAddPortfolio();
        
    }

    async addButtonAddPortfolio() {
        console.log('add');
        const buttonAddPortfolio = this.template.querySelector('.aside-button-add-portfolio'); 
        console.log('add!'+ this.portfolios.length); ///when started  undefined
        console.log('add@' + buttonAddPortfolio);

        if (this.portfolios.length > 0 && buttonAddPortfolio) {
            buttonAddPortfolio.classList.remove('slds-hide');
        }else if(this.portfolios.length === 0) {
            buttonAddPortfolio.classList.add('slds-hide');
        }
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

        if (this.selectedPortfolio) {
        getTransaction({accountId : portfolioId})
        // this.isLoading = true;
        .then(transaction => {
            //  testData = transaction;
            console.log(JSON.stringify(transaction));
                
                   
                this.priceList = transaction.map(trans =>({
                    id:trans.Id,
                    name: trans.Name,
                    price: SYMBOL_USD + trans.Price__c,
                    holdings: trans.Quantity__c, 
                    average: SYMBOL_USD + trans.Price_Per_Coin__c, 
                    profitAndLoss: SYMBOL_USD + trans.Profit_and_Loss__c,
                    totalProfitAndLoss: trans.Profit_and_Loss__c
                }));   
                
                this.calculateAverageProfitAndLoss(this.priceList);

                    console.log(JSON.stringify(this.priceList));
                this.totalRecordCount = this.priceList.length;
                    console.log('total' +this.totalRecordCount);
                this.numberOfPages = Math.ceil(this.totalRecordCount / PAGE_SIZE);
                this.displayRecordPerPage(this.pageNumber);
 
                this.addButtonAddPortfolio();
                this.activeItem(portfolioId);


            })
            .catch(error =>{
                this.showToast('Error', error, 'error');

            })

            }else{
                this.priceList = [];
                this.dataTable = [];
                this.isPaginator = false;
                this.averageProfitAndLoss = 0;
            }
            

    }


    activeItem(portfolioId) {
        const previouslySelected = this.template.querySelector('.is-selected');
        const currentSelected = this.template.querySelector(`[data-id="${portfolioId}"]`);
        
        if (previouslySelected) {
            previouslySelected.classList.remove('is-selected');
            //fun toggle
            previouslySelected.classList.add('is-active');

            const previouslyButton = previouslySelected.querySelector('.portfolio_threedots_button');
            if (previouslyButton) {
                previouslyButton.classList.add('slds-hide');
            }
        }

        if (currentSelected) {
            currentSelected.classList.add('is-selected');
            currentSelected.classList.remove('is-active');

            const currentButton = currentSelected.querySelector('.portfolio_threedots_button');
            if (currentButton) {
                currentButton.classList.remove('slds-hide');
            }
        }
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
        
        console.log( 'page+++'+ page);
        console.log( 'page_siZe'+ PAGE_SIZE);

        if (page > this.numberOfPages){
            page -= 1;
            this.pageNumber = page;
        }  

        this.startingPageIndex = (page - 1) * PAGE_SIZE;
        this.endingPageIndex = page * PAGE_SIZE;

        console.log('sta'+this.startingPageIndex);
        console.log('end'+this.endingPageIndex);
        
        this.dataTable = this.priceList.slice(this.startingPageIndex, this.endingPageIndex);

        console.log( 'after++'+this.dataTable.length);
        if(this.priceList.length >= 10){
            console.log( 'if'+this.dataTable.length);
            this.isPaginator = true;
        }else{
            this.isPaginator = false;
        }

        console.log('45 ++ '+JSON.stringify(this.dataTable));
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
        
            let profitAndLossValues = priceList.map(item => parseFloat(item.totalProfitAndLoss)); 
            this.averageProfitAndLoss = profitAndLossValues.reduce((total, value) => total + value, 0);
            this.averageProfitAndLoss = parseFloat(this.averageProfitAndLoss.toFixed(2));
            // this.averageProfitAndLoss = -666;

            this.addStyleToAverage(this.averageProfitAndLoss);      
        
        
    }

    addStyleToAverage(averageProfitAndLoss) {
        
        const textElement = this.template.querySelector('.aside_context_average');
        const iconDown = this.template.querySelector('.icon-down');
        const iconUp = this.template.querySelector('.icon-up');

        if(textElement && iconDown && iconUp) { 
                     
            iconUp.classList.add('slds-hide');
            iconDown.classList.add('slds-hide');
            textElement.style.color = 'black';

            if(averageProfitAndLoss > 0) {
                iconUp.classList.remove('slds-hide');
                textElement.style.color = '#32e462';
            } else if(averageProfitAndLoss < 0) {
                iconDown.classList.remove('slds-hide');
                textElement.style.color = 'red';
            } 
        }

    }


    handleThreedots() {
        this.isMenuOpen = !this.isMenuOpen;
    }

    handleRename() {
        console.log('Rename clicked');
        this.closeMenu();
    }

    handleDelete() {

        this.closeMenu();
        if(this.selectedPortfolio.Id) {
            console.log('isDelete');
            deletePortfolio({portfolioId: this.selectedPortfolio.Id})
            .then(result => {
                this.showToast('Success', 'Portfolio Deleted', 'success');
                // if(this.portfolios.length > 0) {
                this.loadPortfolios(true);
                

            })
            .catch(error =>{
                this.showToast('Error', error , 'error');
            })

        }else{
            this.showToast('Error', 'Invalid Portfolio ID', 'Error');
        }

       
    }


    closeMenu() {
        this.isMenuOpen = false;
    }



//     Igor, [22/07/2024 3:02 PM]
    handleActionsBlur(event) {
        console.log(event);
        console.log('ss1' + JSON.stringify(event.relatedTarget ));
        console.log('ss' +JSON.stringify(event.target));
        if (String(event.relatedTarget) === String(event.target)) {
           

            console.log('work');
            this.setActionsPanelVisibility(false);
        }
    }

// Igor, [22/07/2024 3:02 PM]
// setActionsPanelVisibility(showPanel) {
//         this.showActionsPanel = showPanel;
//         const actionsPanel = this.template.querySelector(".actions-panel");

//         if (!actionsPanel) {
//             return;
//         }

//         const escalateSubmenu = this.template.querySelector(".escalate-submenu");
//         escalateSubmenu?.classList?.add("slds-hide");

//         if (showPanel) {
//             actionsPanel.classList.remove("slds-hide");
//             actionsPanel.focus();
//         } else {
//             actionsPanel.classList.add("slds-hide");
//         }
//     }
    // }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const token = event.detail.row;

        switch (actionName) {
            case 'buy_token':
                const buyingData = this.createTransactionData(token, 'Buy', 'success');
                this.handleTokenTransaction(buyingData);

                break;
            case 'sell_token':
                const sellingData = this.createTransactionData(token, 'Sell', 'destructive');
                this.handleTokenTransaction(sellingData);

                break;
            default:
        }
    }

    createTransactionData(token, type, variant) {
        return {
            id: token.id,
            name: token.name,
            type: type,
            variant: variant,
            price: token.price.replace(/\$/g, ''),
            holdings: token.holdings,
            average: token.average.replace(/\$/g, ''),
            profitAndLoss: token.profitAndLoss.replace(/\$/g, ''),
            totalProfitAndLoss: token.totalProfitAndLoss
        };
    }

    handleTokenTransaction(transaction) {
        console.log(JSON.stringify(transaction));
        BuyOrSellPopup.open({transaction: transaction})
        .then(result => {
            this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            console.log(' modal result:', JSON.stringify(result));
        }).catch(error => {
            console.error(' modal error:', error);
        });

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