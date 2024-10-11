import { LightningElement, track } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import getInvestmentDetails from '@salesforce/apex/CryptoInvestorController.getInvestmentDetails';
import getDataTableDetails from '@salesforce/apex/CryptoInvestorController.getDataTableDetails';
// import getDateTimeNow from '@salesforce/apex/CryptoInvestorController.getDateTimeNow';
import CreatePortfolioModal from 'c/createPortfolioModal';
import createPortfolio from '@salesforce/apex/PortfolioController.createPortfolio';
import deletePortfolio from '@salesforce/apex/PortfolioController.deletePortfolio';
import createTransaction from '@salesforce/apex/TransactionController.createTransaction';
import CreateTransactionModal from 'c/createTransactionModal';
import BuyOrSellModal  from 'c/buyOrSellModal';
import SettingTheTimeRangeModal  from 'c/settingTheTimeRangeModal';
import StartDate from '@salesforce/schema/Contract.StartDate';


const ACTIONS = [
    { label: 'Buy', name: 'buy_token' },
    { label: 'Sell', name: 'sell_token' },
];
const COLUMNS_TO_PORTFOLIO = [
    {label: 'Name', fieldName : 'name'},
    {label: 'Price', fieldName : 'price'},
    {label: 'Holdings', fieldName : 'holdings'},
    {label: 'Spent', fieldName : 'spending'},
    {label: 'Avg. Buy Price', fieldName : 'average'},
    {label: 'Profit/Loss', fieldName : 'profitAndLoss'},
    
    {
        type: 'action',
        typeAttributes: { rowActions: ACTIONS },
    },
];

const COLUMNS_TO_HISTORY_TRANSACTIONS = [
    {label: 'Symbol', fieldName : 'symbol'},
    {label: 'Name', fieldName : 'name'},
    {label: 'Price Per Coin', fieldName : 'price_per_coin'},
    {label: 'Quantity', fieldName : 'quantity'},
    {label: 'Spent', fieldName : 'spending'},
    {label: 'Type', fieldName : 'typeTransaction'},
    {label: 'Created Date', fieldName : 'created_date'},
    
];

const PAGE_SIZE = 10;
const SYMBOL_USD = '$';

export default class CryptoInvestor extends LightningElement {
   
    @track amountInvestments = `0.00 ${SYMBOL_USD}`;
    @track currencyBalance = `0.00 ${SYMBOL_USD}`;
    @track todayPnl = `0.00 ${SYMBOL_USD}`;
    @track averageProfitAndLoss = `0.00${SYMBOL_USD}`;

    @track selectedPortfolio = {};
    @track portfolios = [];
    @track dataTable = [];
    @track transactions = [];
    interimToDataTablePortfolio = [];
    
    columnsToPortfolio = COLUMNS_TO_PORTFOLIO;

    
    isLoading = false;
    isMenuOpen = false;
    @track isPaginatorToPortfolioTab = false;
    
    @track pageNumberToPortfolioTab = 1;
    @track numberOfPagesToPortfolioTab;
    startingPageIndexToPortfolioTab = 1;
    endingPageIndexToPortfolioTab = 0;
    totalRecordCountToPortfolioTab;


    isPaginatorToHistoryTransactions = false;
    @track pageNumberToHistoryTab = 1;
    @track numberOfPagesToHistoryTab;

    startingPageIndexToHistoryTab = 1;
    endingPageIndexToHistoryTab = 0; 
    totalRecordCountToHistoryTab;
    @track dataTableToHistoryTab =[];



    

    @track transactionTypeOptions = [
        { key: 'all_type', value: 'All' },
        { key: 'buy_type', value: 'Buy' },
        { key: 'sell_type', value: 'Sell' },
    ];

    @track transactionTimeOptions = [
        { key: 'all_time', value: 'All The Time' },
        { key: '7days', value: 'Last 7 days' },
        { key: '30days', value: 'Last 30 days' },
        { key: '90days', value: 'Last 90 days' },
        { key: 'setting', value: 'Set the date' },
    ];

    startDate = {};
    endDate = {};
    keyTransactionTypeOption = '';
    keyTransactionTimeOption = '';
    symbolTransaction = '';
    transactionsHistoryData = [];
    columnsToHistoryTransactions = COLUMNS_TO_HISTORY_TRANSACTIONS;


    
    connectedCallback(){
        this.loadDetails();    
    }

    loadDetails(){
        this.isLoading = true;
        getInvestmentDetails({})
        .then(result => {
            this.amountInvestments = `${result.totalBalanceInvestment}${SYMBOL_USD}`;
            this.currencyBalance = `${result.currencyBalance}${SYMBOL_USD}`;
            this.portfolios = result.portfolios;
            this.transactions = result.transactions;
            this.formatTransactionHistoryData(this.transactions);

            
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        })
        .finally(() => {
            this.updateUI();
            this.isLoading = false;
        });
        
    }

    updateUI() {
        if(this.portfolios.length > 0){
            this.selectedPortfolio = this.portfolios[0];
            this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
        }
        this.toggleButtonNewPortfolio();
        this.toggleDataTable();
    }

    toggleButtonNewPortfolio(){
        const newPortfolioButton = this.template.querySelector('.button-new');
        if (newPortfolioButton) {
            newPortfolioButton.classList.toggle('slds-hide', this.portfolios.length === 0);
        }
        
    }

    toggleDataTable() {
        const emptyState = this.template.querySelector('.table__empty-state');
        const dataTableContainer = this.template.querySelector('.data-table-container');

        if (this.portfolios.length > 0) {
            emptyState.classList.add('slds-hide');
            dataTableContainer.classList.remove('slds-hide');
        } else {
            emptyState.classList.remove('slds-hide');
            dataTableContainer.classList.add('slds-hide');
        }
    }


    async handleCreatePortfolio() {
        const result = await CreatePortfolioModal.open({
            size: 'Small',
            label: 'Create Portfolio',
            description: 'Please enter the name of the new portfolio',
        });

        createPortfolio({ name: result.label})
            .then(created => {
                this.portfolios = [...this.portfolios, created];
                this.showToast('Success', 'Portfolio created successfully', 'success');
                
            })
            .catch(error =>{
                this.showToast('Error', 'Portfolio creation failed', 'error');
            })
            .finally(() =>{
                this.toggleDataTable();
                this.selectedPortfolio = this.portfolios[this.portfolios.length - 1];
                this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            });
             
    }

    
    handleSelectPortfolio(event) {
        const portfolioId = event.currentTarget.dataset.id;
        this.selectedPortfolio = this.portfolios.find(portfolio => portfolio.Id == portfolioId);
        console.log(JSON.stringify( this.selectedPortfolio));
        this.updatePortfolioHighlight(portfolioId);
        this.loadPortfolioDetails(portfolioId); 
    }

    async loadPortfolioDetails(portfolioId) {
        console.log(portfolioId);
        await getDataTableDetails({ portfolioId: portfolioId })
            .then(result => {

                 this.interimToDataTablePortfolio = this.createdInterimToDataTablePortfolio(result);
 
                this.totalRecordCountToPortfolioTab = this.interimToDataTablePortfolio.length;
                this.numberOfPagesToPortfolioTab = Math.ceil(this.totalRecordCountToPortfolioTab / PAGE_SIZE);
                this.displayRecordPerPageToPortfolioTab(this.pageNumberToPortfolioTab);
                this.calculateAverageProfitAndLoss(this.interimToDataTablePortfolio);
            })
            .catch(error => {
                console.error('Error loading dataTable:', error);
            });

    }
    
    createdInterimToDataTablePortfolio(data) {
        console.log(JSON.stringify(data))
        return data.map(item => {
            let totalQuantity = parseFloat(item.totalQuantity) || 0; 
            let totalCost = parseFloat(item.totalCost) || 0;  
            let average = totalQuantity > 0 ? (totalCost / totalQuantity).toFixed(4) : '0.00';
            return {
                Id: item.portfolioCurrencyId,
                name: item.symbol,
                price: `$${parseFloat(item.price).toFixed(2)}`, 
                holdings: `${totalQuantity}`,
                spending: `$${totalCost.toFixed(4)}`, 
                average: `$${average}`, 
                profitAndLoss: this.calculateProfitAndLoss(item), 
            };
        });
    }


    displayRecordPerPageToPortfolioTab(page) {
        page = Math.max(1, Math.min(page, this.numberOfPagesToPortfolioTab));

        this.pageNumberToPortfolioTab = page;
    
        this.startingPageIndexToPortfolioTab = parseFloat(page - 1) * PAGE_SIZE;
        this.endingPageIndexToPortfolioTab = Math.min(page * PAGE_SIZE, this.interimToDataTablePortfolio.length);

        this.dataTable = this.interimToDataTablePortfolio.slice(this.startingPageIndexToPortfolioTab, this.endingPageIndexToPortfolioTab);
    
        this.isPaginatorToPortfolioTab = this.interimToDataTablePortfolio.length >= (parseFloat(PAGE_SIZE+1));
        
    }
    
    prevHandlerToPortfolioTab(event) {
        if (this.pageNumberToPortfolioToPortfolioTab > 1) {
            this.pageNumberToPortfolioToPortfolioTab -= 1;
            this.displayRecordPerPageToPortfolioTab(this.pageNumberToPortfolioTab);
        }
    }

    nextHandlerToPortfolioTab(event) {
        if (this.pageNumberToPortfolioTab < this.numberOfPagesToPortfolioTab) {
            this.pageNumberToPortfolioTab += 1;
            this.displayRecordPerPageToPortfolioTab(this.pageNumberToPortfolioTab);
        }
    }

    calculateProfitAndLoss(item) {
        let currentPrice = parseFloat(item.price.replace(/\$/g, ''));
        let totalQuantity = parseFloat(item.totalQuantity);
        let totalCost = parseFloat(item.totalCost);
    
        if (!totalQuantity || !totalCost || !currentPrice) {
            return '$0.00'; 
        }
    
        let profitAndLoss = (currentPrice - (totalCost / totalQuantity)) * totalQuantity;
    
        return `$${profitAndLoss.toFixed(4)}`;
    }
    

    calculateAverageProfitAndLoss(interimToDataTablePortfolio) {
        let profitAndLossValues = interimToDataTablePortfolio.map(item => parseFloat(item.profitAndLoss.replace(/\$/g, '')));
        this.averageProfitAndLoss = profitAndLossValues.reduce((total, value) => total + value, 0);
        this.averageProfitAndLoss = this.averageProfitAndLoss.toFixed(4);

        this.updateProfitLossStyle(this.averageProfitAndLoss);
    }

    updateProfitLossStyle(value)  {
        const textElement = this.template.querySelector('.profit-indicator__value');
        const iconDown = this.template.querySelector('.icon-down');
        const iconUp = this.template.querySelector('.icon-up');

        if(textElement && iconDown && iconUp) { 
                     
            iconUp.classList.add('slds-hide');
            iconDown.classList.add('slds-hide');
            textElement.style.color = 'black';

            if(value > 0) {
                iconUp.classList.remove('slds-hide');
                textElement.style.color = '#0eff00';
            } else if(value < 0) {
                iconDown.classList.remove('slds-hide');
                textElement.style.color = 'red';
            }else{
                profitIndicator.style.color = 'black';
                iconUp.classList.add('slds-hide');
                iconDown.classList.add('slds-hide');
            }
        }

    }

   

    updatePortfolioHighlight(portfolioId) {
    
        const previouslySelectedElement = this.template.querySelector('.is-selected');
        const currentlySelectedElement = this.template.querySelector(`[data-id="${portfolioId}"]`);
    
        this.togglePortfolioSelection(previouslySelectedElement);
        this.togglePortfolioSelection(currentlySelectedElement);
    }
    
    togglePortfolioSelection(element) {
        if (!element) return;
    
        element.classList.toggle('is-selected');
        element.classList.toggle('is-active');
    
        const threeDotsButton = element.querySelector('.sidebar-item_button-threedots');
        if (threeDotsButton) {
            threeDotsButton.classList.toggle('slds-hide');
        }
    }
    

    async handleCreateTransaction() {
        const resultTransactionModal = await CreateTransactionModal.open({
            size: 'Small',
            label: 'New Transaction',
            description: 'Enter transaction details',
        });
         
        if(resultTransactionModal){
            let transactionData = {
                portfolioId:  this.selectedPortfolio.Id,
                typeTransaction: 'Buy',
                quantityTransaction: resultTransactionModal.quantityTransaction,
                amountTransaction: resultTransactionModal.amountTransaction,
                symbol: resultTransactionModal.symbolTransaction    
             };

            await this.handleTransactionCreation(transactionData);
           
        }else{
            this.showToast('Error','Incorrectly entered parameters','error');
        }

    }


    async handleTransactionCreation(transactionData) {

        createTransaction({data: JSON.stringify(transactionData)})
        .then(response => {
            // this.loadDetails();
            this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            this.showToast('Success', 'Transaction completed', 'success');
        })
        .catch(error =>{
            console.error('Error creating transaction:', error);
        })
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
            deletePortfolio({portfolioId: this.selectedPortfolio.Id})
            .then(result => {
                this.showToast('Success', `Portfolio ${this.selectedPortfolio.Name} was successfully deleted.`, 'success');
                this.loadDetails();
            })
            .catch(error =>{
                let errorMessage = error.body ? error.body.message : 'An unexpected error occurred during portfolio deletion.';
                this.showToast('Error', `Failed to delete portfolio. Error: ${errorMessage}`, 'error');
            })
        }else{
            this.showToast('Error', 'Invalid Portfolio ID. Please select a valid portfolio and try again.', 'error');
        }

       
    }
    
    closeMenu() {
        this.isMenuOpen = false;
    }



    handleRowAction(event) {
        const actionType = event.detail.action.name;
        const token = event.detail.row;

        switch (actionType) {
            case 'buy_token':
                const buyingDetails = this.createTransactionDetails(token, 'Buy', 'success');
                this.openTransactionModal(buyingDetails);             
                break;
            case 'sell_token':
                const sellingData = this.createTransactionDetails(token, 'Sell', 'destructive');
                this.openTransactionModal(sellingData);
                break;
            default:
        }
    }

    createTransactionDetails(tokenData, transactionType, transactionVariant) {
        const cleanPrice = (price) => price.replace(/\$/g, '');

        return {
            id: tokenData.Id,
            name: tokenData.name,
            type: transactionType,
            variant: transactionVariant,
            price: cleanPrice(tokenData.price),
            holdings: tokenData.holdings,
            average: cleanPrice(tokenData.average),
            profitAndLoss: cleanPrice(tokenData.profitAndLoss),
            totalProfitAndLoss: tokenData.totalProfitAndLoss
        };
    }

    openTransactionModal(transaction) {
        BuyOrSellModal.open({transaction: transaction})
        .then(result => {
            this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            this.showToast('Transaction Successful','The transaction was completed successfully.', 'success');
        }).catch(error => {
            this.showToast('Transaction Failed', `An error occurred: ${error.message}`, 'error');
        });

    }
 

    formatTransactionHistoryData(transactions) {
        this.transactionsHistoryData = transactions.map(item => ({
            id: item.Id,
            symbol: item.Symbol__c,
            name: item.Name,
            price_per_coin: `${SYMBOL_USD}${item.Price_Per_Coin__c}`,
            quantity: item.Quantity__c,
            spending: `${SYMBOL_USD}${item.Amount__c}`,
            typeTransaction: item.Type_Transaction__c,
            created_date: item.CreatedDate.split('T')[0],
        }));

        this.toggleToShowEmptyDataMessage();
        this.totalRecordCountToHistoryTab = this.transactionsHistoryData.length;
        this.numberOfPagesToHistoryTab = Math.ceil(this.totalRecordCountToHistoryTab / PAGE_SIZE);
    
        this.displayRecordPerPageToHistoryTab(this.pageNumberToHistoryTab);

    }

    toggleToShowEmptyDataMessage() {
        const emptyDataTable = this.template.querySelector('.empty-datatable');
    
        if(emptyDataTable){
            if (emptyDataTable) {
                const hasData = this.transactionsHistoryData && this.transactionsHistoryData.length > 0;
                emptyDataTable.classList.toggle('slds-hide', hasData);
            }
        }
    }

    displayRecordPerPageToHistoryTab(page) {

        page = Math.max(1, Math.min(page, this.numberOfPagesToHistoryTab));

        this.pageNumberToHistoryTab = page;
    
        this.startingPageIndexToHistoryTab = parseFloat(page - 1) * PAGE_SIZE;
        this.endingPageIndexToHistoryTab = Math.min(page * PAGE_SIZE, this.transactionsHistoryData.length);

        this.dataTableToHistoryTab = this.transactionsHistoryData.slice(this.startingPageIndexToHistoryTab, this.endingPageIndexToHistoryTab);
    
        this.isPaginatorToHistoryTransactions = this.transactionsHistoryData.length >= (parseFloat(PAGE_SIZE+1));
        
    }


    nextHandlerToHistoryTab(event){
        if (this.pageNumberToHistoryTab < this.numberOfPagesToHistoryTab) {
            this.pageNumberToHistoryTab += 1;
            this.displayRecordPerPageToHistoryTab(this.pageNumberToHistoryTab);
        }
    }

    prevHandlerToHistoryTab(event) {
        if (this.pageNumberToHistoryTab > 1) {
            this.pageNumberToHistoryTab -= 1;
            this.displayRecordPerPageToHistoryTab(this.pageNumberToHistoryTab);
        }
    }


    async handleChangeTime(event) {
        this.keyTransactionTimeOption = event.target.value;
        this.isValueChangeTime(this.keyTransactionTimeOption);
    }

    isValueChangeTime(keyTransactionTimeOption) {
        if (keyTransactionTimeOption === 'all_time') {
            this.keyTransactionTimeOption = '';
            this.filterTransactionData();
        } else if (keyTransactionTimeOption === 'setting') {
            this.openDateRangeModal();
        } else {
            this.setDate(keyTransactionTimeOption);
            this.filterTransactionData();
        }
    }

    async openDateRangeModal() {
        const customDateRangeTransactions = await SettingTheTimeRangeModal.open({});
        if (customDateRangeTransactions) {
            this.startDate = new Date(customDateRangeTransactions.startDate);
            this.endDate = new Date(customDateRangeTransactions.endDate);
            this.filterTransactionData();
        }
    }

    setDate(keyTransactionTimeOption) {
        const daysMap = {
            '7days': 7,
            '30days': 30,
            '90days': 90,
        };
        const amountOfDays = daysMap[keyTransactionTimeOption];
        if(!amountOfDays) {
            return this.showToast('Error', `Date not set`, 'error');;
        }
        
        this.startDate = new Date(); 
        this.endDate = new Date(this.startDate);
        this.endDate.setDate(this.startDate.getDate() - amountOfDays);
    }

    handleSearchSymbol(event) {
        this.symbolTransaction = event.target.value.toUpperCase();
        if (this.symbolTransaction) {
            this.filterTransactionData();
        }
    }


    handleChangeType(event) {
        this.typeTransaction = event.target.value;
        if (this.typeTransaction === 'buy_type') {
            this.typeTransaction = 'Buy';
        } else if (this.typeTransaction === 'sell_type') {
            this.typeTransaction = 'Sell';
        }else if(this.typeTransaction === 'all_type'){
            this.typeTransaction = '';
        }
        this.filterTransactionData();
    }

    filterTransactionData() {
        let interimFilteredData = [...this.transactions];

        if (this.symbolTransaction) {
           interimFilteredData = interimFilteredData.filter(transaction => transaction.Symbol__c === this.symbolTransaction);
        }

        if (this.typeTransaction) {
           interimFilteredData = interimFilteredData.filter(transaction => transaction.Type_Transaction__c === this.typeTransaction);
        }

        if (this.keyTransactionTimeOption && this.startDate && this.endDate) {
           interimFilteredData = interimFilteredData.filter(transaction => {
                const transactionDate = new Date(transaction.CreatedDate);
                return transactionDate >= this.endDate && transactionDate <= this.startDate;
            });
        }

        this.formatTransactionHistoryData(interimFilteredData);
    }

    handleReset() {
        this.formatTransactionHistoryData(this.transactions);
        this.cleanFilter();

        const timeSelect = this.template.querySelector('[data-id="time-select"]');
        const typeSelect = this.template.querySelector('[data-id="type-select"]');
        const symbolInput = this.template.querySelector('[data-id="symbol-input"]');

        if (timeSelect) timeSelect.value = 'all_time'; 
        if (typeSelect) typeSelect.value = 'all_type'; 
        if (symbolInput) symbolInput.value = ''; 
    }

    cleanFilter() {
        this.startDate = {};
        this.endDate = {};
        this.keyTransactionTypeOption = '';
        this.keyTransactionTimeOption = '';
        this.symbolTransaction = '';
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