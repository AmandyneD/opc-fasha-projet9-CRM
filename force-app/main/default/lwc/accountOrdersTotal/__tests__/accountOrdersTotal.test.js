import { createElement } from "lwc";
import AccountOrdersTotal from "c/accountOrdersTotal";
import getSumOrdersByAccount from "@salesforce/apex/AccountOrderTotalsController.getSumOrdersByAccount";

jest.mock(
  "@salesforce/apex/AccountOrderTotalsController.getSumOrdersByAccount",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// ✅ plus fiable que Promise.resolve() pour laisser le temps au DOM de re-render
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

describe("c-account-orders-total", () => {
  let consoleErrorSpy;

  beforeEach(() => {
    // évite le bruit "Apex error" dans la console pendant les tests
    consoleErrorSpy = jest.spyOn(console, "error").mockImplementation(() => {});
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
    consoleErrorSpy.mockRestore();
  });

  it("affiche le total quand Apex renvoie une somme > 0", async () => {
    getSumOrdersByAccount.mockResolvedValue(250);

    const element = createElement("c-account-orders-total", {
      is: AccountOrdersTotal
    });
    element.recordId = "001000000000001AAA";
    document.body.appendChild(element);

    // ✅ 2 ticks : promesse Apex + re-render
    await flushPromises();
    await flushPromises();

    const text = element.shadowRoot.textContent;
    expect(text).toMatch(/Total des commandes/i);

    const formatted = element.shadowRoot.querySelector("lightning-formatted-number");
    expect(formatted).not.toBeNull();

    // selon les stubs, value peut être undefined → on check aussi l’attribut
    expect(formatted.value ?? formatted.getAttribute("value")).toBe(250);
  });

  it("affiche une erreur quand Apex renvoie 0", async () => {
    getSumOrdersByAccount.mockResolvedValue(0);

    const element = createElement("c-account-orders-total", { is: AccountOrdersTotal });
    element.recordId = "001000000000001AAA";
    document.body.appendChild(element);

    await flushPromises();
    await flushPromises();

    const text = element.shadowRoot.textContent;
    expect(text).toMatch(/Erreur/i);
  });

  it("affiche une erreur si Apex rejette", async () => {
    getSumOrdersByAccount.mockRejectedValue(new Error("Apex error"));

    const element = createElement("c-account-orders-total", { is: AccountOrdersTotal });
    element.recordId = "001000000000001AAA";
    document.body.appendChild(element);

    await flushPromises();
    await flushPromises();

    const text = element.shadowRoot.textContent;
    expect(text).toMatch(/Erreur/i);
  });
});