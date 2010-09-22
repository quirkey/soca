function(doc) {
  emit([doc.type, doc.updated_at], doc._id);
}
