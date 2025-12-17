@IsTest
public class AccountRevenueServiceTest {

    @IsTest
    static void shouldRecalcCA_whenBulkActivateOrders_andWhenDeleteOrders() {

        // ---------- Arrange ----------
        Account acc = new Account(Name = 'H&M');
        insert acc;

        Id stdPbId = Test.getStandardPricebookId();

        Product2 p = new Product2(Name = 'Test Product', IsActive = true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id   = p.Id,
            UnitPrice    = 100,
            IsActive     = true
        );
        insert pbe;

        // 100 Orders en Draft
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 100; i++) {
            orders.add(new Order(
                Name          = 'O' + i,
                AccountId     = acc.Id,
                Status        = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id  = stdPbId
            ));
        }
        insert orders;

        // 1 OrderItem par Order => TotalAmount = 2 * 100 = 200
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

        // Bulk activation (simulate Data Loader update)
        for (Order o : orders) {
            o.Status = 'Activated';
        }

        // 10 Orders Draft à supprimer (pour couvrir after delete sans bloquer)
        List<Order> draftToDelete = new List<Order>();
        for (Integer i = 0; i < 10; i++) {
            draftToDelete.add(new Order(
                Name          = 'D' + i,
                AccountId     = acc.Id,
                Status        = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id  = stdPbId
            ));
        }
        insert draftToDelete;

        // ---------- Act (1 seul start/stop) ----------
        Test.startTest();

        update orders; // ✅ trigger after update
        AccountRevenueService.recalcRevenue(new Set<Id>{ acc.Id }); // ✅ test service direct
        delete draftToDelete; // ✅ trigger after delete (Draft)

        Test.stopTest();

        // ---------- Assert ----------
        Account refreshed = [
            SELECT Id, Chiffre_d_affaire__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            20000,
            refreshed.Chiffre_d_affaire__c,
            'Le CA doit être la somme des Orders Activated (100 * 200) et ne pas être impacté par la suppression des Draft.'
        );
    }
}