function(doc) {
  // !code js/vendor/sammy-0.5.4.js
  if (doc.created_at) {
    emit(doc.created_at, doc);
  }
}
