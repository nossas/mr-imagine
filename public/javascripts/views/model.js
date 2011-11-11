var ModelView = Backbone.View.extend({
  initialize: function(){
    this.render()
  },

  beforeRender: function() {
  },

  afterRender: function() {
  },

  render: function() {
    this.beforeRender()
    this.el.html(Mustache.to_html(this.template.html(), this.model))
    this.afterRender()
    return this
  }
})
