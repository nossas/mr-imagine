/*!
  * $script.js Async loader & dependency manager
  * https://github.com/ded/script.js
  * (c) Dustin Diaz, Jacob Thornton 2011
  * License: MIT
  */
!function(a,b){typeof define=="function"?define(b):typeof module!="undefined"?module.exports=b():this[a]=b()}("$script",function(){function s(a,b,c){for(c=0,j=a.length;c<j;++c)if(!b(a[c]))return m;return 1}function t(a,b){s(a,function(a){return!b(a)})}function u(a,b,c){function o(a){return a.call?a():f[a]}function p(){if(!--m){f[l]=1,j&&j();for(var a in h)s(a.split("|"),o)&&!t(h[a],o)&&(h[a]=[])}}a=a[n]?a:[a];var e=b&&b.call,j=e?b:c,l=e?a.join(""):b,m=a.length;return setTimeout(function(){t(a,function(a){if(k[a])return l&&(g[l]=1),k[a]==2&&p();k[a]=1,l&&(g[l]=1),v(!d.test(a)&&i?i+a+".js":a,p)})},0),u}function v(a,d){var e=b.createElement("script"),f=m;e.onload=e.onerror=e[r]=function(){if(e[p]&&!/^c|loade/.test(e[p])||f)return;e.onload=e[r]=null,f=1,k[a]=2,d()},e.async=1,e.src=a,c.insertBefore(e,c.firstChild)}var a=this,b=document,c=b.getElementsByTagName("head")[0],d=/^https?:\/\//,e=a.$script,f={},g={},h={},i,k={},l="string",m=!1,n="push",o="DOMContentLoaded",p="readyState",q="addEventListener",r="onreadystatechange";return!b[p]&&b[q]&&(b[q](o,function w(){b.removeEventListener(o,w,m),b[p]="complete"},m),b[p]="loading"),u.get=v,u.order=function(a,b,c){(function d(e){e=a.shift(),a.length?u(e,d):u(e,b,c)})()},u.path=function(a){i=a},u.ready=function(a,b,c){a=a[n]?a:[a];var d=[];return!t(a,function(a){f[a]||d[n](a)})&&s(a,function(a){return f[a]})?b():!function(a){h[a]=h[a]||[],h[a][n](b),c&&c(d)}(a.join("|")),u},u.noConflict=function(){return a.$script=e,this},u})


/*
 * Ramify external API loader
 * Should be the only file included from external projects
 */
var RAMIFY = {
  sid: null,
  session: null,
  init: function(options){
    this.options = options || {};
    if(this.options.sid){
      RAMIFY.sid = this.options.sid;
    }
    this.loadJS();
  },

  loadJS: function(){
    $script(RAMIFY.scriptURI('jquery-1.6.1.min'), RAMIFY.onJQueryLoad);
  },

  scriptURI: function(path){
    return RAMIFY.options.host + '/javascripts/' + path + '.js';
  },

  onJQueryLoad: function(){
    $script(RAMIFY.scriptURI('jquery.ba-postmessage'), 'base');
    $script.ready('base', RAMIFY.onBaseLoad);
  },

  onBaseLoad: function(){
    RAMIFY.$ = jQuery;
    jQuery.noConflict(true);
    $script(RAMIFY.scriptURI('store'), 'store');
  },


  logout: function(callback){
    $script.ready('store', function(){
      RAMIFY.$.get('/destroy_ramify_session', null, null, 'json')
        .success(function(data){
          RAMIFY.sid = data.sid;
          RAMIFY.getSession().set('logged', false);
          callback();
        })
        .error(function(data){
          callback();
        });
    });
  },

  login: function(callback){
    $script.ready('store', function(){
      if(!RAMIFY.getSession().get('logged')){
        RAMIFY.$.get('/create_ramify_session', null, null, 'json')
        .success(function(data){
          RAMIFY.sid = data.sid;
          RAMIFY.getSession().set('logged', true);
          callback();
        })
        .error(function(data){
        });
      }
      else{
        callback();
      }
    });
  },

  getSession: function(){
    if(!RAMIFY.session){
      RAMIFY.session = new Store('ramify_session');
    }
    return RAMIFY.session;
  },

  loadFrame: function(){
    $script.ready('store', function(){
      RAMIFY.$.receiveMessage(function(e){
        if(e.data == 'login'){
          $('#member_panel a:last').trigger('click');
        }
      }, RAMIFY.host );
      var iframe = RAMIFY.$("<iframe>").attr({
        'src' : RAMIFY.options.host + (RAMIFY.options.path || '/') + '?' + ['iframe=true', 'sid=' + (RAMIFY.sid || '')].join('&'),
        'width' : '950',
        'height' : '800',
        'frameborder': '0',
        'name' : 'ramify-content'
      });
      RAMIFY.$("#main").append(iframe);
    });
  },

};
