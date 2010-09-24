(function($, Sammy) {

  Sammy = Sammy || {};

  Sammy.Couch = function(app, dbname) {

    // set the default dbname form the URL
    dbname = dbname || window.location.pathname.split('/')[1];

    var db = function() {
      if (!dbname) {
        throw("Please define a db to load from");
      }
      return this._db = this._db || $.couch.db(dbname);
    };

    var timestamp = function() {
      return new Date().getTime();
    };

    this.db = db();

    this.createModel = function(type, options) {
      options = $.extend({
        defaultDocument: function() {
          return {
            type: type,
            updated_at: timestamp()
          };
        },
        errorHandler: function(response) {
          app.trigger('error.' + type, {error: response});
        }
      }, options || {});

      var mergeCallbacks = function(callback) {
        var base = {error: options.errorHandler};
        if ($.isFunction(callback)) {
          return $.extend(base, {success: callback});
        } else {
          return $.extend(base, callback || {});
        }
      };

      var mergeDefaultDocument = function(doc) {
        return $.extend({}, options.defaultDocument(), doc);
      };

      var model = {
        timestamp: timestamp,

        extend: function(obj) {
          $.extend(model, obj);
        },

        all: function(callback) {
          return app.db.allDocs($.extend(mergeCallbacks(callback), {
            include_docs: true
          }));
        },

        get: function(id, options, callback) {
          if ($.isFunction(options)) {
            callback = options;
            options  = {};
          }
          return app.db.openDoc(id, $.extend(mergeCallbacks(callback), options));
        },

        create: function(doc, callback) {
          return model.save(mergeDefaultDocument(doc), callback);
        },

        save: function(doc, callback) {
          if ($.isFunction(model.beforeSave)) {
            doc = model.beforeSave(doc);
          }
          return app.db.saveDoc(doc, mergeCallbacks(callback));
        },

        update: function(id, doc, callback) {
          model.get(id, function(original_doc) {
            doc = $.extend(original_doc, doc);
            model.save(doc, callback);
          });
        },

        view: function(name, options, callback) {
          if ($.isFunction(options)) {
            callback = options;
            options  = {};
          }
          return app.db.view([dbname, name].join('/'), $.extend(mergeCallbacks(callback), options));
        },

        viewDocs: function(name, options, callback) {
          if ($.isFunction(options)) {
            callback = options;
            options  = {};
          }
          var wrapped_callback = function(json) {
            var docs = [];
            for (var i=0;i<json['rows'].length;i++) {
              docs.push(json['rows'][i]['doc']);
            }
            callback(docs);
          };
          options = $.extend({
            include_docs: true
          }, mergeCallbacks(wrapped_callback), options);
          return app.db.view([dbname, name].join('/'), options);
        }
      };
      return model;
    };

    this.helpers({
      db: db()
    });
  };

})(jQuery, window.Sammy);
