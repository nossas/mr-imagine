var ApplicationRouter = Backbone.Router.extend({

  routes: {
    "": "closePopups",
    "login": "login",
    "sign_up": "signUp",
    "new_idea": "newIdea"
  },
  
  closePopups: function() {
    this.closeLayoutPopups()
  },
  
  closeLayoutPopups: function() {
    app.newIdeaView.close()
    app.loginView.close()
    app.userMenuView.close()
  },
  
  login: function() {
    app.loginView.render()
  },
  
  signUp: function() {
    app.loginView.returnTo("/" + app.locale + "/my_profile")
    app.loginView.render()
  },
  
  newIdea: function() {
    if(this.requireLogin())
      app.newIdeaView.render()
  },
  
  requireLogin: function() {
		if(app.currentUser) {
			return true
		} else {
      window.location.hash = '';
      $.postMessage('login', window.outerFrame);
		}
	}
})
