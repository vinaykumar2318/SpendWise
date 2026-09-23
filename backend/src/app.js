const express = require('express');
const cors = require('cors');
const { randomUUID } = require('crypto');

const idempotencyMiddleware = require('./middleware/idempotency');
const transactionController = require('./controllers/transactionController');
const summaryController = require('./controllers/summaryController');
const budgetController = require('./controllers/budgetController');

const app = express();

app.use(cors());
app.use(express.json());

// Trace ID middleware
app.use((req, res, next) => {
  req.traceId = randomUUID();
  res.setHeader('X-Trace-ID', req.traceId);
  next();
});

// Apply Idempotency Middleware
app.use(idempotencyMiddleware);

// Routes
app.get('/transactions', transactionController.getTransactions);
app.patch('/transactions/:id', transactionController.recategorizeTransaction);

app.get('/summary', summaryController.getMonthSummary);

app.get('/budgets', budgetController.getBudgets);
app.put('/budgets', budgetController.setBudget);

// Default 404 handler with required error shape
app.use((req, res) => {
  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: 'Endpoint not found',
      traceId: req.traceId
    }
  });
});

module.exports = app;