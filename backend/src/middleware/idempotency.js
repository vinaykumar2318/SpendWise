const idempotencyCache = new Map();

function idempotencyMiddleware(req, res, next) {
  if (['POST', 'PATCH', 'PUT', 'DELETE'].includes(req.method)) {
    const key = req.headers['idempotency-key'];
    
    if (!key) {
      return res.status(400).json({
        error: {
          code: 'IDEMPOTENCY_KEY_MISSING',
          message: 'Idempotency-Key header is required for mutating requests',
          traceId: req.traceId
        }
      });
    }

    if (idempotencyCache.has(key)) {
      const cached = idempotencyCache.get(key);
      return res.status(cached.status).json(cached.body);
    }

    // Intercept res.json to store the response
    const originalJson = res.json.bind(res);
    res.json = (body) => {
      idempotencyCache.set(key, { status: res.statusCode, body });
      return originalJson(body);
    };
  }

  next();
}

module.exports = idempotencyMiddleware;