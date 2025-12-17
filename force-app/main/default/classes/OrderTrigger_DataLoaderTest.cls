@IsTest
public class OrderTrigger_DataLoaderTest {

    @IsTest
    static void shouldUpdateNetAmount_forAllOrders_whenBulkUpdateOccurs() {
        Account acc = new Account(Name='HM');
        insert acc;

        Id stdPbId = Test.getStandardPricebookId();

        Product2 p = new Product2(Name='P', IsActive=true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id   = p.Id,
            UnitPrice    = 100,
            IsActive     = true
        );
        insert pbe;

        // 5 orders
        List<Order> orders = new List<Order>();
        for (Integer i=0; i<5; i++) {
            orders.add(new Order(
                Name='DL-' + i,
                AccountId=acc.Id,
                Status='Draft',
                EffectiveDate=Date.today(),
                Pricebook2Id=stdPbId,
                ShipmentCost__c=0
            ));
        }
        insert orders;

        // 1 item par order => Total réel
        List<OrderItem> items = new List<OrderItem>();
        for (Order o : orders) {
            items.add(new OrderItem(
                OrderId=o.Id, PricebookEntryId=pbe.Id, Quantity=2, UnitPrice=100
            ));
        }
        insert items;

        // Simulation Data Loader : update en masse
        for (Order o : orders) o.ShipmentCost__c = 10;

        Test.startTest();
        update orders; // c’est ça qui reproduit le bug “seule la première”
        Test.stopTest();

        // Assert
        List<Order> refreshed = [
            SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c
            FROM Order
            WHERE Id IN :orders
        ];
        for (Order o : refreshed) {
            System.assertEquals(o.TotalAmount - o.ShipmentCost__c, o.NetAmount__c,
                'NetAmount doit être correct pour CHAQUE Order lors d’un bulk update (Data Loader).');
        }
    }
}