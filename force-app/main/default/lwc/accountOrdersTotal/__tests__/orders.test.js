import { createElement } from 'lwc';
import AccountOrdersTotal from 'c/accountOrdersTotal';

describe('c-account-orders-total', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it('renders without crashing', () => {
    const element = createElement('c-account-orders-total', { is: AccountOrdersTotal });
    element.recordId = '001000000000001AAA';
    document.body.appendChild(element);

    expect(element).toBeTruthy();
  });
});