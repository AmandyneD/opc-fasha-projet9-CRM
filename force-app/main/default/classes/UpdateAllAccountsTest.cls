@IsTest
public class UpdateAllAccountsTest {

    @IsTest
    static void shouldRecalcRevenueForAccountsWithActivatedOrders() {
        // Arrange
        Account acc = new Account(Name = 'Test Account Batch');
        insert acc;

        // Standard Pricebook + product + entry
        Id stdPbId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id   = prod.Id,
            UnitPrice    = 100,
            IsActive     = true
        );
        insert pbe;

        // Create Order 1 (Draft) -> should NOT be counted
        Order draftOrder = new Order(
            Name = 'Draft Order',
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = stdPbId
        );
        insert draftOrder;

        // Create Order 2 (Activated) -> should be counted
        Order activatedOrder = new Order(
            Name = 'Activated Order',
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = stdPbId
        );
        insert activatedOrder;

        // Add at least one OrderItem (required to activate order in many orgs)
        OrderItem oi = new OrderItem(
            OrderId = activatedOrder.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 150
        );
        insert oi;

        // Activate the order after adding products
        activatedOrder.Status = 'Activated';
        update activatedOrder;

        // Force wrong CA value to prove batch corrects it
        acc.Chiffre_d_affaire__c = 0;
        update acc;

        // Act
        Test.startTest();
        Id jobId = Database.executeBatch(new UpdateAllAccounts(), 1);
        Test.stopTest();

        // Assert job completed
        AsyncApexJob job = [
            SELECT Status, NumberOfErrors
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];
        System.assertEquals('Completed', job.Status, 'Le batch doit se terminer correctement');
        System.assertEquals(0, job.NumberOfErrors, 'Le batch ne doit pas générer d’erreurs');

        // Assert CA updated (Draft ignored, Activated counted)
        Account refreshed = [
            SELECT Chiffre_d_affaire__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        // Ici, le CA attendu dépend de ton service :
        // - si AccountRevenueService somme TotalAmount, alors TotalAmount = somme des OrderItems (2 * 150 = 300)
        // - si tu sommes NetAmount__c, adapte en conséquence.
        System.assertEquals(300, refreshed.Chiffre_d_affaire__c,
            'Le CA doit être recalculé uniquement à partir des commandes Activated');
    }
}