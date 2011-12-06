describe("RAMIFY", function(){
  beforeEach(function(){
    RAMIFY.options = {host: 'http://localhost'};
    $script = jasmine.createSpy('$script');
    $script.ready = jasmine.createSpy('$script');
  });

  describe("$script", function(){
    it("should have $script available", function(){
      expect($script).toEqual(jasmine.any(Function));
    });
  });

  describe(".init", function(){
    beforeEach(function(){
      spyOn(RAMIFY, "loadJS");
      RAMIFY.init();
    });

    it("should put parameter in options object", function(){
      RAMIFY.init('options object');
      expect(RAMIFY.options).toEqual('options object');
    });

    it("should put sid parameter in RAMIFY.sid", function(){
      RAMIFY.init({sid: 'test sid'});
      expect(RAMIFY.sid).toEqual('test sid');
    });

    it("should call loadJS", function(){
      expect(RAMIFY.loadJS).toHaveBeenCalledWith();
    });
  });

  describe("#scriptURI", function(){
    it("should concatenate the host, JS path, and .js to the parameter", function(){
      expect(RAMIFY.scriptURI('test')).toEqual('http://localhost/javascripts/test.js');
    });
  });

    describe("#loadJS", function(){
      beforeEach(function(){
        RAMIFY.loadJS();
      });

      it("should call $script to load ramify's jquery to call onJQueryLoad", function(){
        expect($script).toHaveBeenCalledWith('http://localhost/javascripts/jquery-1.6.1.min.js', RAMIFY.onJQueryLoad);
      });
  });


  describe("#onJQueryLoad", function(){
    it("should call $script to load jquery.ba-postmessage to call onBaseLoad", function(){
      RAMIFY.onJQueryLoad();
      expect($script).toHaveBeenCalledWith('http://localhost/javascripts/jquery.ba-postmessage.js', 'base');
      expect($script.ready).toHaveBeenCalledWith('base', RAMIFY.onBaseLoad);
    });
  });

  describe("#onBaseLoad", function(){
    beforeEach(function(){
      spyOn(jQuery, "noConflict");
      RAMIFY.onBaseLoad();
    });

    it("should setup JQuery no conflict before loadFrame", function(){
      expect(RAMIFY.$).toEqual(jQuery);
      expect(jQuery.noConflict).toHaveBeenCalledWith(true);
    });
    it("should call $script to load store.js", function(){
      expect($script).toHaveBeenCalledWith('http://localhost/javascripts/store.js', 'store');
    });
  });


  describe("#getSession", function(){
    beforeEach(function(){
      RAMIFY.getSession();
    });
    it("should create Session with Store if it isn't created yet", function(){
      var store = new Store("ramify_session");
      expect(RAMIFY.session).toEqual(store);
      expect(RAMIFY.getSession()).toEqual(store);
    });
  });

  describe("#loadFrame", function(){
    var iframe = $("<iframe>");
    var target = $("#main");

    beforeEach(function(){
      spyOn(RAMIFY, "$").andCallFake(function(selector) { return (selector == "<iframe>" ? iframe : target) });

      //TODO: Test receiveMessage
      RAMIFY.$.receiveMessage = function(){};
      spyOn(RAMIFY.$, "receiveMessage");

      spyOn(iframe, "attr").andCallThrough();
      spyOn(target, "append");
      RAMIFY.options = {host: 'http://test', path: '/ideias/iframe'};
      RAMIFY.sid = 'session_id';
      $script.ready.andCallFake(function(bundle, callback){ callback(); });
      RAMIFY.loadFrame();
    });

    it("should call only when base is ready", function(){
      expect($script.ready).toHaveBeenCalledWith('store', jasmine.any(Function));
    });

    it("should append iframe to target element with host and path from options", function(){
      expect(iframe.attr).toHaveBeenCalledWith({
        'src': 'http://test/ideias/iframe?iframe=true&sid=session_id',
        'width': '950',
        'height': '800',
        'frameborder': '0',
        'name': 'ramify-content'
      });
    });

    it("should append iframe to target element", function(){
      expect(RAMIFY.$).toHaveBeenCalledWith("<iframe>");
      expect(iframe.attr).toHaveBeenCalledWith({
        'src': 'http://test/ideias/iframe?iframe=true&sid=session_id',
        'width': '950',
        'height': '800',
        'frameborder': '0',
        'name': 'ramify-content'
      });
      expect(RAMIFY.$).toHaveBeenCalledWith('#main');
      expect(target.append).toHaveBeenCalledWith(iframe);
    });
  });
});
