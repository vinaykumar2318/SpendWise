const db = require('../data/mockDb');

// GET /budgets?month=YYYY-MM
exports.getBudgets = (req, res) => {
  const { month } = req.query;
  const targetMonth = month || new Date().toISOString().substring(0, 7);

  // Calculate actual spend dynamically for accuracy
  const categorySpend = {};
  db.transactions
    .filter(t => t.at.startsWith(targetMonth))
    .forEach(t => {
      categorySpend[t.category] = (categorySpend[t.category] || 0) + t.amountPaise;
    });

  const monthBudgets = db.categories.map(cat => {
    const existing = db.budgets.find(b => b.category === cat.id && b.month === targetMonth);
    const limitPaise = existing ? existing.limitPaise : 0;
    const spentPaise = categorySpend[cat.id] || 0;

    return {
      category: cat.id,
      categoryName: cat.name,
      month: targetMonth,
      limitPaise,
      spentPaise
    };
  });

  res.json({ budgets: monthBudgets });
};

// PUT /budgets?month=YYYY-MM
exports.setBudget = (req, res) => {
  const { category, limitPaise, month } = req.body;
  if (!category || limitPaise === undefined || !month) {
    return res.status(422).json({
      error: { code: 'UNPROCESSABLE_ENTITY', message: 'Category, limitPaise, and month are required' }
    });
  }

  let budget = db.budgets.find(b => b.category === category && b.month === month);
  if (budget) {
    budget.limitPaise = limitPaise;
  } else {
    budget = { category, month, limitPaise, spentPaise: 0 };
    db.budgets.push(budget);
  }

  res.json({ success: true, budget });
};