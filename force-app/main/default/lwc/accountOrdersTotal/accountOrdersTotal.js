import { LightningElement, api } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/AccountOrderTotalsController.getSumOrdersByAccount';

export default class Orders extends LightningElement {
    @api recordId;
    sumOrdersOfCurrentAccount = 0;

    connectedCallback() {
        this.fetchSumOrders();
    }

    fetchSumOrders() {
        getSumOrdersByAccount({ accountId: this.recordId })
            .then(result => {
                this.sumOrdersOfCurrentAccount = Number(result) || 0;
            })
            .catch(error => {
                console.error(error);
                this.sumOrdersOfCurrentAccount = 0;
            });
    }

    get hasOrders() {
        return (Number(this.sumOrdersOfCurrentAccount) || 0) > 0;
    }
}