@IsTest
public class AccountRevenueServiceTest {

    @IsTest
    static void shouldRecalcCA_whenBulkActivateOrders() {

        // Dataset : 100 Draft avec items (TotalAmount > 0)
        TestDataFactory.OrderDataset ds =
            TestDataFactory.createOrdersWithItems(100, 'Draft', 100, 2, null);

        // Bulk activation
        for (Order o : ds.orders) o.Status = 'Activated';

        Test.startTest();
        update ds.orders;
        Test.stopTest();

        Account refreshed = [
            SELECT Chiffre_d_affaire__c
            FROM Account
            WHERE Id = :ds.acc.Id
        ];

        System.assertEquals(100 * 100 * 2, refreshed.Chiffre_d_affaire__c);
    }
}