const { normalizeMerchantName } = require('../utils/merchantNormalizer');

// Categories
const categories = [
  { id: 'cat_food', name: 'Food & Dining', icon: 'fastfood', color: '#FF9800' },
  { id: 'cat_shopping', name: 'Shopping', icon: 'shopping_bag', color: '#E91E63' },
  { id: 'cat_bills', name: 'Bills & Utilities', icon: 'receipt_long', color: '#2196F3' },
  { id: 'cat_transport', name: 'Transport', icon: 'directions_car', color: '#9C27B0' },
  { id: 'cat_entertainment', name: 'Entertainment', icon: 'movie', color: '#4CAF50' },
];

// Seeded Transactions (amounts in Integer Paise)
let transactions = [
  {
    id: 'tx_001',
    merchantRaw: 'SWIGGY*9482_BANGALORE',
    merchantName: 'Swiggy',
    merchantKey: 'SWIGGY',
    category: 'cat_food',
    amountPaise: 45000, // ₹450.00
    at: '2026-09-20T12:30:00.000Z',
    mode: 'UPI'
  },
  {
    id: 'tx_002',
    merchantRaw: 'AMAZON*RETAIL_IND',
    merchantName: 'Amazon',
    merchantKey: 'AMAZON',
    category: 'cat_shopping',
    amountPaise: 129900, // ₹1,299.00
    at: '2026-09-19T16:15:00.000Z',
    mode: 'CARD'
  },
  {
    id: 'tx_003',
    merchantRaw: 'SWIGGY*8812_BANGALORE',
    merchantName: 'Swiggy',
    merchantKey: 'SWIGGY',
    category: 'cat_food',
    amountPaise: 32000, // ₹320.00
    at: '2026-09-18T20:00:00.000Z',
    mode: 'UPI'
  },
  {
    id: 'tx_004',
    merchantRaw: 'BESCOM_ELECTRICITY_PAY',
    merchantName: 'BESCOM Electricity',
    merchantKey: 'BESCOM',
    category: 'cat_bills',
    amountPaise: 245000, // ₹2,450.00
    at: '2026-09-15T10:00:00.000Z',
    mode: 'NET_BANKING'
  },
  {
    id: 'tx_005',
    merchantRaw: 'SWIGGY_REFUND_TX9482',
    merchantName: 'Swiggy',
    merchantKey: 'SWIGGY',
    category: 'cat_food',
    amountPaise: -15000, // -₹150.00 (Refund: Edge case #1)
    at: '2026-09-21T09:15:00.000Z',
    mode: 'UPI'
  }
];

// Budgets (month: 'YYYY-MM')
let budgets = [
  { category: 'cat_food', month: '2026-09', limitPaise: 1000000, spentPaise: 62000 },
  { category: 'cat_shopping', month: '2026-09', limitPaise: 1500000, spentPaise: 129900 },
  { category: 'cat_bills', month: '2026-09', limitPaise: 5000000, spentPaise: 245000 }
];

// Rules set by user recategorizations
let merchantRules = {};

module.exports = {
  categories,
  transactions,
  budgets,
  merchantRules
};