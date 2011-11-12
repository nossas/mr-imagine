IdeaView.prototype.afterRender = function() {
  var offset = this.el.offset()
  var top = offset.top
  var left = offset.left
  var width = this.el.width()
  var height = this.el.height()
  var canvas = Raphael(left, top, width, height)
  var circle = canvas.circle(20, 40, 20)
  circle.attr("fill", "#f00")
  circle.attr("stroke", "#fff")

}
