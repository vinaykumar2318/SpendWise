const db = require('../data/mockDb');
const { normalizeMerchantName } = require('../utils/merchantNormalizer');

// GET /transactions?month=YYYY-MM&category=&q=&cursor=&limit=
exports.getTransactions = (req, res) => {
  const { month, category, q, cursor, limit = 20 } = req.query;
  let filtered = [...db.transactions];

  if (month) {
    filtered = filtered.filter(t => t.at.startsWith(month));
  }
  if (category) {
    filtered = filtered.filter(t => t.category === category);
  }
  if (q) {
    const query = q.toLowerCase();
    filtered = filtered.filter(t => 
      t.merchantName.toLowerCase().includes(query) || 
      t.merchantRaw.toLowerCase().includes(query)
    );
  }

  // Sort by date descending
  filtered.sort((a, b) => new Date(b.at) - new Date(a.at));

  // Simple cursor pagination
  const pageSize = parseInt(limit, 10);
  const startIndex = cursor ? parseInt(cursor, 10) : 0;
  const paginated = filtered.slice(startIndex, startIndex + pageSize);
  const nextCursor = (startIndex + pageSize < filtered.length) ? (startIndex + pageSize).toString() : null;

  res.json({
    items: paginated,
    nextCursor
  });
};

// PATCH /transactions/:id
exports.recategorizeTransaction = (req, res) => {
  const { id } = req.params;
  const { category, applyToMerchant } = req.body;

  if (!category) {
    return res.status(422).json({
      error: { code: 'UNPROCESSABLE_ENTITY', message: 'Category is required' }
    });
  }

  const tx = db.transactions.find(t => t.id === id);
  if (!tx) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Transaction not found' }
    });
  }

  const oldCategory = tx.category;
  tx.category = category;

  let updatedCount = 1;

  if (applyToMerchant) {
    const key = tx.merchantKey || normalizeMerchantName(tx.merchantRaw);
    db.merchantRules[key] = category;

    // Apply to all past and future matches
    db.transactions.forEach(t => {
      const tKey = t.merchantKey || normalizeMerchantName(t.merchantRaw);
      if (tKey === key && t.id !== id) {
        t.category = category;
        updatedCount++;
      }
    });
  }

  res.json({
    success: true,
    transaction: tx,
    updatedCount,
    previousCategory: oldCategory
  });
};