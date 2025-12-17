@IsTest
public class AccountRevenueService_TriggerFilterTest {

    @IsTest
    static void shouldRecalcOnlyWhenStatusChangesToOrFromActivated() {

        // Arrange
        Account acc = new Account(Name = 'H&M');
        insert acc;

        Id stdPbId = Test.getStandardPricebookId();

        Product2 p = new Product2(Name='Test Product', IsActive=true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = p.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Order Draft + 1 OrderItem => TotalAmount = 200
        Order o = new Order(
            Name='O1',
            AccountId=acc.Id,
            Status='Draft',
            EffectiveDate=Date.today(),
            Pricebook2Id=stdPbId
        );
        insert o;

        insert new OrderItem(
            OrderId=o.Id,
            PricebookEntryId=pbe.Id,
            Quantity=2,
            UnitPrice=100
        );

        // Force un recalcul initial (pour partir d'un état propre)
        AccountRevenueService.recalcRevenue(new Set<Id>{acc.Id});
        Account acc0 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(0, acc0.Chiffre_d_affaire__c, 'Draft ne doit pas impacter le CA.');

        // Act 1: update sans changer le status => PAS de recalcul attendu (CA reste 0)
        o.Name = 'O1 renamed';
        update o;

        Account acc1 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(0, acc1.Chiffre_d_affaire__c, 'Update sans changement de Status ne doit pas recalculer le CA.');

        // Act 2: Draft -> Activated => DOIT recalculer (CA = 200)
        o.Status = 'Activated';
        update o;

        Account acc2 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(200, acc2.Chiffre_d_affaire__c, 'Passage à Activated doit recalculer le CA.');

        // Act 3: Activated -> Draft => DOIT recalculer (CA revient à 0)
        o.Status = 'Draft';
        update o;

        Account acc3 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(0, acc3.Chiffre_d_affaire__c, 'Sortie de Activated doit recalculer le CA.');
    }
}