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

    it("should call loadJS passing loadStylesheets as callback", function(){
      expect(RAMIFY.loadJS).toHaveBeenCalledWith(RAMIFY.loadStylesheets);
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
    var loadStylesCallback = null;

    beforeEach(function(){
      // We need to spy on some global functions here, so no var for them
      jQuery = {noConflict: function(){}};
      $script = jasmine.createSpy('$script');
      $script.ready = function(){};

      spyOn($script, "ready");
      spyOn(jQuery, "noConflict");
      loadStylesCallback = jasmine.createSpy('loadStylesheets');

      $script.ready.andCallFake(function(name, callback){ callback(); });
      RAMIFY.loadJS(loadStylesCallback);
    });

    it("should call $script to load ramify's jquery", function(){
      expect($script).toHaveBeenCalledWith(['http://localhost/javascripts/jquery-1.6.1.min.js'], 'base');
    });

    it("should call $script ready callback for base", function(){
      expect($script.ready).toHaveBeenCalledWith('base', jasmine.any(Function));
    });

    it("should setup jquery in base ready callback", function(){
      expect(RAMIFY.$).toEqual(jQuery);
      expect(jQuery.noConflict).toHaveBeenCalledWith(true);
    });

    it("should call the callback parameter after loading jQuery", function(){
      expect(loadStylesCallback).toHaveBeenCalled();
    });
  });

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
  });
});