describe("RAMIFY", function(){
  beforeEach(function(){
    RAMIFY.options = {host: 'http://localhost'};
    $script = jasmine.createSpy('$script');
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

    it("should call loadJS", function(){
      expect(RAMIFY.loadJS).toHaveBeenCalledWith();
    });
  });

  describe("#scriptURI", function(){
    it("should concatenate the host, JS path, and .js to the parameter", function(){
      expect(RAMIFY.scriptURI('test')).toEqual('http://localhost/javascripts/test.js');
    });
  });

  describe("#onJQueryLoad", function(){
    it("should call $script to load jquery.ba-postmessage to call onBaseLoad", function(){
      RAMIFY.onJQueryLoad();
      expect($script).toHaveBeenCalledWith('http://localhost/javascripts/jquery.ba-postmessage.js', RAMIFY.onBaseLoad);
    });
  });

  describe("#onBaseLoad", function(){
    beforeEach(function(){
      spyOn(RAMIFY, "loadFrame");
      spyOn(jQuery, "noConflict");
    });

    it("should setup JQuery no conflict before loadFrame", function(){
      $script.andCallFake(function(){
        expect(RAMIFY.$).toEqual(jQuery);
        expect(jQuery.noConflict).toHaveBeenCalledWith(true);
      });
      RAMIFY.onBaseLoad();
    });

    it("should call loadFrame", function(){
      RAMIFY.onBaseLoad();
      expect(RAMIFY.loadFrame).toHaveBeenCalled();
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

  describe("loadFrame", function(){
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
    });

    it("should append iframe to target element with host and path from options", function(){
      RAMIFY.loadFrame();
      expect(iframe.attr).toHaveBeenCalledWith({
        'src': 'http://test/ideias/iframe',
        'width': '950',
        'height': '800',
        'frameborder': '0',
        'name': 'ramify-content'
      });
    });

    it("should append iframe to target element", function(){
      RAMIFY.loadFrame();
      expect(RAMIFY.$).toHaveBeenCalledWith("<iframe>");
      expect(iframe.attr).toHaveBeenCalledWith({
        'src': 'http://test/ideias/iframe',
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
