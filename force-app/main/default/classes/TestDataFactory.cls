@IsTest
public class TestDataFactory {

    // ----------------------------
    // ACCOUNTS
    // ----------------------------
    public static Account createAccount(String name) {
        return new Account(Name = (String.isBlank(name) ? 'Test Account' : name));
    }

    public static Account insertAccount(String name) {
        Account a = createAccount(name);
        insert a;
        return a;
    }

    // ----------------------------
    // PRODUCTS + PRICEBOOK ENTRY (Standard)
    // ----------------------------
    public static Product2 insertActiveProduct(String name) {
        Product2 p = new Product2(
            Name = (String.isBlank(name) ? 'Test Product' : name),
            IsActive = true
        );
        insert p;
        return p;
    }

    public static PricebookEntry insertStandardPricebookEntry(Product2 p, Decimal unitPrice) {
        Id stdPbId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id   = p.Id,
            UnitPrice    = unitPrice,
            IsActive     = true
        );
        insert pbe;
        return pbe;
    }

    // ----------------------------
    // ORDERS
    // ----------------------------
    public static Order createOrder(Id accountId, Id pricebookId, String status, Date effectiveDate, Decimal shipmentCost) {
        Order o = new Order(
            Name          = 'Test Order ' + String.valueOf(Crypto.getRandomInteger()),
            AccountId     = accountId,
            Status        = (String.isBlank(status) ? 'Draft' : status),
            EffectiveDate = (effectiveDate == null ? Date.today() : effectiveDate),
            Pricebook2Id  = pricebookId
        );
        if (shipmentCost != null) {
            o.ShipmentCost__c = shipmentCost;
        }
        return o;
    }

    public static List<Order> insertOrders(Id accountId, Integer count, String status, Decimal shipmentCost) {
        Id stdPbId = Test.getStandardPricebookId();

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < count; i++) {
            orders.add(createOrder(accountId, stdPbId, status, Date.today(), shipmentCost));
        }
        insert orders;
        return orders;
    }

    // ----------------------------
    // ORDER ITEMS
    // ----------------------------
    public static List<OrderItem> insertOneItemPerOrder(List<Order> orders, PricebookEntry pbe, Decimal qty, Decimal unitPrice) {
        List<OrderItem> items = new List<OrderItem>();
        for (Order o : orders) {
            items.add(new OrderItem(
                OrderId          = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity         = qty,
                UnitPrice        = unitPrice
            ));
        }
        insert items;
        return items;
    }

    // ----------------------------
    // HELPER: Build a common dataset quickly
    // ----------------------------
    public class OrderDataset {
        public Account acc;
        public Product2 product;
        public PricebookEntry pbe;
        public List<Order> orders;
    }

    /**
     * Crée un dataset typique :
     * - 1 Account
     * - 1 Product + PBE standard
     * - N Orders (Draft ou Activated)
     * - 1 OrderItem par Order (pour avoir TotalAmount > 0)
     */
    public static OrderDataset createOrdersWithItems(Integer orderCount, String orderStatus, Decimal unitPrice, Decimal qty, Decimal shipmentCost) {
        OrderDataset ds = new OrderDataset();

        ds.acc = insertAccount('Test Account');
        ds.product = insertActiveProduct('Test Product');
        ds.pbe = insertStandardPricebookEntry(ds.product, unitPrice);

        ds.orders = insertOrders(ds.acc.Id, orderCount, orderStatus, shipmentCost);
        insertOneItemPerOrder(ds.orders, ds.pbe, qty, unitPrice);

        return ds;
    }
}