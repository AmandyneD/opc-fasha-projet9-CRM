@IsTest
public class OrderBusinessLogicTest {

    @IsTest
    static void shouldRecalculateNetAmountForAllOrdersInBulk() {

        // Arrange
        Account acc = new Account(Name = 'Acc Test');
        insert acc;

        Id stdPbId = Test.getStandardPricebookId();

        // Produit + PricebookEntry standard (nécessaire pour créer des OrderItems)
        Product2 p = new Product2(Name = 'Test Product', IsActive = true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id   = p.Id,
            UnitPrice    = 100,
            IsActive     = true
        );
        insert pbe;

        // Crée 5 orders Draft, avec ShipmentCost
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 5; i++) {
            orders.add(new Order(
                Name          = 'O' + i,
                AccountId     = acc.Id,
                Status        = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id  = stdPbId,
                ShipmentCost__c = 10
            ));
        }
        insert orders;

        // Ajoute 1 ligne produit par order => TotalAmount devient réel (100 * 2 = 200)
        List<OrderItem> items = new List<OrderItem>();
        for (Order o : orders) {
            items.add(new OrderItem(
                OrderId          = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity         = 2,
                UnitPrice        = 100
            ));
        }
        insert items;

        // Récupère les Ids à recalculer
        Set<Id> orderIds = new Set<Id>();
        for (Order o : orders) orderIds.add(o.Id);

        // Act
        Test.startTest();
        OrderBusinessLogic.recalculateNetAmount(orderIds);
        Test.stopTest();

        // Assert
        List<Order> refreshed = [
            SELECT Id, TotalAmount, ShipmentCost__c, NetAmount__c
            FROM Order
            WHERE Id IN :orderIds
        ];

        System.assertEquals(5, refreshed.size(), 'On doit retrouver les 5 Orders.');

        for (Order o : refreshed) {
            Decimal total = (o.TotalAmount == null) ? 0 : o.TotalAmount;
            Decimal ship  = (o.ShipmentCost__c == null) ? 0 : o.ShipmentCost__c;

            System.assertEquals(
                total - ship,
                o.NetAmount__c,
                'NetAmount doit être recalculé pour chaque Order (bulk).'
            );
        }
    }
}