describe("RAMIFY", function(){
  beforeEach(function(){
    RAMIFY.host = 'http://localhost';
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

    it("should call loadJS passing loadFrame as callback", function(){
      expect(RAMIFY.loadJS).toHaveBeenCalledWith(jasmine.any(Function));
    });
  });

  describe("styleURI", function(){
    it("should concatenate the host, CSS path, and .css to the parameter", function(){
      expect(RAMIFY.styleURI('test')).toEqual('http://localhost/stylesheets/test.css');
    });
  });

  describe("scriptURI", function(){
    it("should concatenate the host, JS path, and .js to the parameter", function(){
      expect(RAMIFY.scriptURI('test')).toEqual('http://localhost/javascripts/test.js');
    });
  });

  describe("loadJS", function(){
    var callback = function(){};
    // Now we're calling the LoadFrameCallback, instead of LoadStyleSheets
    var loadFramesCallback = null;

    beforeEach(function(){
      // We need to spy on some global functions here, so no var for them
      jQuery = {noConflict: function(){}};
      $script = jasmine.createSpy('$script');
      $script.ready = function(){};

      spyOn($script, "ready");
      spyOn(jQuery, "noConflict");
      loadFramesCallback = jasmine.createSpy('loadFrame');

      $script.ready.andCallFake(function(name, callback){ callback(); });
      RAMIFY.loadJS(loadFramesCallback);
    });

    it("should call $script to load ramify's jquery", function(){
      expect($script).toHaveBeenCalledWith('http://localhost/javascripts/jquery-1.6.1.min.js', jasmine.any(Function));
    });

    it("should bundle jquery.ba-postmessage into base after loading jQuery", function(){
      $script.andCallFake(function(scriptName, callback){ if($.isFunction(callback)) callback(); });
      RAMIFY.loadJS(loadFramesCallback);
      expect($script).toHaveBeenCalledWith('http://localhost/javascripts/jquery.ba-postmessage.js', 'base');
    });

    it("should call $script ready callback for base", function(){
      expect($script.ready).toHaveBeenCalledWith('base', jasmine.any(Function));
    });

    it("should setup jquery in base ready callback", function(){
      expect(RAMIFY.$).toEqual(jQuery);
      expect(jQuery.noConflict).toHaveBeenCalledWith(true);
    });

    it("should call the callback parameter after loading jQuery", function(){
      expect(loadFramesCallback).toHaveBeenCalled();
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
    });

    it("should append iframe to target element with path", function(){
      RAMIFY.loadFrame('/ideias/iframe');
      expect(iframe.attr).toHaveBeenCalledWith({
        'src': 'http://localhost/ideias/iframe',
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
        'src': 'http://localhost',
        'width': '950',
        'height': '800',
        'frameborder': '0',
        'name': 'ramify-content'
      });
      expect(RAMIFY.$).toHaveBeenCalledWith('#main');
      expect(target.append).toHaveBeenCalledWith(iframe);
    });
  });

  /**
  describe("loadStylesheets", function(){
    var stylesheet = $('<link>');
    var head = $('<head>');
    beforeEach(function(){
      spyOn(RAMIFY, "$").andCallFake(function(selector){ return (selector == '<link>' ? stylesheet : head) });
      spyOn(stylesheet, "attr").andCallThrough();
      spyOn(head, "append");
      RAMIFY.loadStylesheets();
    });

    it("should append screen.css to the document head", function(){
      expect(RAMIFY.$).toHaveBeenCalledWith('<link>');
      expect(stylesheet.attr).toHaveBeenCalledWith({
        'href': 'http://localhost/stylesheets/screen.css',
        'rel': 'stylesheet',
        'media': 'screen',
        'type': 'text/css'
      });
      expect(RAMIFY.$).toHaveBeenCalledWith('head');
      expect(head.append).toHaveBeenCalledWith(stylesheet);
    });
  }); **/
});
