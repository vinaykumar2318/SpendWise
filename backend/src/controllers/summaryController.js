const db = require('../data/mockDb');

// GET /summary?month=YYYY-MM
exports.getMonthSummary = (req, res) => {
  const { month } = req.query;
  const targetMonth = month || new Date().toISOString().substring(0, 7);

  const monthTxs = db.transactions.filter(t => t.at.startsWith(targetMonth));

  let totalPaise = 0;
  const byCategory = {};
  const dayMap = {};

  monthTxs.forEach(t => {
    // Net total (refunds are negative, reducing total)
    totalPaise += t.amountPaise;

    // By category
    byCategory[t.category] = (byCategory[t.category] || 0) + t.amountPaise;

    // By day
    const day = t.at.substring(0, 10);
    dayMap[day] = (dayMap[day] || 0) + t.amountPaise;
  });

  const byDay = Object.keys(dayMap).map(day => ({
    date: day,
    amountPaise: dayMap[day]
  })).sort((a, b) => a.date.localeCompare(b.date));

  res.json({
    month: targetMonth,
    totalPaise,
    byCategory,
    byDay
  });
};