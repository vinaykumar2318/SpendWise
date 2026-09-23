function normalizeMerchantName(rawName) {
  if (!rawName) return "UNKNOWN";
  
  return rawName
    .toUpperCase()
    .replace(/[*_#-].*/g, "")       // Remove everything after standard delimiters like *, _, #, -
    .replace(/[0-9]/g, "")          // Remove numeric codes
    .trim();
}

module.exports = { normalizeMerchantName };