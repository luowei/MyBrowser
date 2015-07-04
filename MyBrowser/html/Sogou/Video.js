var SogouGlobal = {
    hasPageLoaded: false,
    CHANGE_IMAGE: 'changeVideoWithImage',
    ADD_OVERLAY: 'addOverlay',
    iphoneR: /iPhone\s+OS\s+(\d+)_\d+/,
    // 判断操作系统是否ios, 以及版本号是多少
    printLog: function(msg) {
        console && console.log('sogou ios : ' + msg);
    },
    hostname: '',
    hostName: function(refresh) {
        if (!refresh && this.hostname) {
            return this.hostname;
        }
        var host = location.host.toLowerCase();
        if (host.indexOf('56.com') >= 0) { this.hostname = '56'; }
        else if (host.indexOf('wx.qq.com') >= 0) { this.hostname = 'weixin'; }
        else if (host.indexOf('sohu.com') >= 0) { this.hostname = 'sohu'; }
        else if (host.indexOf('iqiyi.com') >= 0) { this.hostname = 'iqiyi'; }
        else if (host.indexOf('letv.com') >= 0) { this.hostname = 'letv'; }
        else if (host.indexOf('1905.com') >= 0) { this.hostname = 'dianying'; }
        else if (host.indexOf('v.qq.com') >= 0) { this.hostname = 'vqq'; }
        else if (host.indexOf('pptv.com') >= 0) { this.hostname = 'pptv'; }
        else if (host.indexOf('hunantv.com') >= 0) { this.hostname = 'hunantv'; }
        else if (host.indexOf('pps.tv') >= 0) { this.hostname = 'pps'; }
        else if (host.indexOf('kankan.com') >= 0) { this.hostname = 'kankan'; }
        else if (host.indexOf('t.m.cctv.com') >= 0) { this.hostname = 'cctv'; }
        else if (host.indexOf('cntv.cn') >= 0) { this.hostname = 'cntv'; }
        else if (host.indexOf('baofeng.com') >= 0) { this.hostname = 'baofeng'; }
        else if (host.indexOf('wasu.cn') >= 0) { this.hostname = 'wasu'; }
        else if (host.indexOf('fun.tv') >= 0) { this.hostname = 'fun'; }
        else if (host.indexOf('ku6.com') >= 0) { this.hostname = 'ku6'; }
        else if (host.indexOf('youku.com') >= 0) { this.hostname = 'youku'; }
        else if (host.indexOf('tudou.com') >= 0) { this.hostname = 'tudou'; }
        return this.hostname;
    },
    ios: function() {
    // 目前只判断ios的版本号
        var userAgent = navigator.userAgent;
        var ires = userAgent.match(this.iphoneR);
        if (ires && ires[1]) {
            return +ires[1];
        } else {
            return false;
        }
    },
    inFrame: function() {
        // 目前个别网站的主要视频是在页面中iframe所包含的页面内播放的，有：
        // pptv
        // weixin
        return this.hostName() === 'weixin'
            || this.hostName() === 'pptv';
    },
    playList: {
        'sohu': 'sohu.com',
        'iqiyi': 'iqiyi.com',
        'dianying': '1905.com',
        'vqq': 'v.qq.com',
        'hunantv': 'hunantv.com',
        'pps': 'pps.tv',
        'cntv': 'cntv.cn',
        'baofeng': 'baofeng.com',
        'wasu': 'wasu.cn',
        'fun': 'fun.tv',
        'ku6': 'ku6.com',
        'youku': 'youku.com',
        'pptv': 'pptv.com',
        'cctv': 'm.cctv.com',
        // 'letv': 'letv.com',
        // 'kankan': 'kankan.com',
        //'tudou': 'tudou.com',
        '56': '56.com'
    },
    willPlay: function() {
        var hostname = this.hostName();
        return this.playList[hostname];
    },
    getFunction: function() {
        var name = this.hostName();
        if (name === 'ku6'
                || name === 'kankan'
                || name === 'cntv'
                || name === 'cctv'
                || name === 'baofeng'
                || name === 'hunantv'
                || name === 'fun'
                || name === 'wasu'
                || name === 'dianying') {
            if (this.ios() && this.ios() <= 7) {
                return this.CHANGE_IMAGE;
            } else {
                return this.ADD_OVERLAY;
            }
        }
        if (name === 'pptv') {
            return this.ADD_OVERLAY;
        }
        return null;
    },
    sendEvent: function(obj, type) {
        var eventObj = document.createEvent('HTMLEvents');
        eventObj.initEvent(type, true, true);
        obj.dispatchEvent(eventObj);
    },
    hookVideos: function() {
        if (!this.willPlay()) {
            // 不在hook白名单中，则不进行hook
            return true;
        }
        var i = 0,
            j = 0,
            len = 0,
            flen = 0,
            videos = [],
            iframes = [];
        if (this.inFrame()) {
            iframes = document.getElementsByTagName('iframe');
            flen = iframes.length;
            for (; j < flen; j ++) {
                //videos = videos.contact(iframes[i].contentWindow.document.getElementsByTagName('video'));
                videos = iframes[j].contentWindow.document.getElementsByTagName('video');
                len = videos.length;
                for(; i < len; i ++) {
                    var vh = new VideoHooker(videos[i], i);
                    vh.hook();
                }
            }
        } else {
            videos = document.getElementsByTagName('video');
            len = videos.length;
            for(; i < len; i ++) {
                var vh = new VideoHooker(videos[i], i);
                vh.hook();
            }
        }
    },
    observer: null,
    hookVideoWithObserver: function() {
        if (this.observer) {
            // 已经添加observer，则返回true
            return true;
        }
        var MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
        if (!MutationObserver) {
            // 表明该版本的ios不支持MutationObserver
            return false;
        }
        var self = this;
        //alert(document.getElementsByTagName('video')[0].src);
        this.observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                switch(mutation.type) {
                case 'attributes':
                    if (mutation.target.tagName === 'VIDEO') {
                        //var video = mutation.target;
                        //alert(video.src);
                        self.hookVideos();
                    }
                    break;
                case 'childList':
                    if (mutation.addNodes) {
                        var nodes = mutation.addedNodes;
                        var nlen = nodes.length;
                        if (nlen <= 0) {
                            // qbLog("no added nodes");
                            return;
                        };
                        for (var i = 0; i < nlen; i ++) {
                            var node = nodes[i];
                            if (node.tagName === 'VIDEO') {
                                node.parse();
                                var vh = new VideoHooker(node, i);
                                vh.hook();
                            }
                        }
                    }
                    break;
                }
            });
        });
        // 观察目标为整个body元素
        var target = document.body;
        // 配置观察选项:
        var config = {
            attributes: true,
            attributeFilter: ["src"],
            childList: true,
            subtree: true
        };
        this.observer.observe(target, config);
        return true;
    },
    hookId: null,
    clearHookId: null,
    hookVideoWithInterval: function() {
        var self = this;
        self.hookVideos();
        if (!self.hookId) {
            self.hookId = window.setInterval(function() {
                self.hookVideos();
            }, 200);
        }
        if (!self.clearHookId) {
            self.clearHookId = window.setTimeout(function() {
                window.clearInterval(self.hookId);
            }, 3000);
        }
    }
};

var bridge = function() {
    this.sendMsg = function (msg) {
        this.send('semobvideo://msg/' + msg);
    };
    this.send = function (dst) {
        SogouGlobal.printLog(dst);
        var bridge = document.createElement('iframe');
        bridge.id = 'id-bridge-iframe';
        bridge.setAttribute('style', 'display:none');
        bridge.setAttribute('height', '0px');
        bridge.setAttribute('width', '0px');
        bridge.setAttribute('frameloader', '0');
        bridge.src = dst;
        document.body.appendChild(bridge);
        document.body.removeChild(bridge);
    }
};
window.bridge = bridge;

var VideoHooker = function(video, i) {
    this._video = video;
    this._index = i;

    this._clickLoaded = false;
    // for sohu视频
    // 用于sohu视频页面的问题
    // 这两个网站中，视频的video标签在完成时没有src代码，但是当点击播放按钮后，src被填充，这时如果直接hook会产生问题，需要等待src加载完成
    // 故而引入clickLoaded，如果第一次点击播放时无src，则将clickLoaded置为true。
    // 用于v.load后播放

    //this._isPlaying = false;
};

VideoHooker.prototype = {
    hook: function() {
        //this._video.autoplay = false;
        if (this._video.hasHook) {
            return false;
        }
        this._video.hasHook = true;
        this.setPlay();
        this._setHook();
        if (SogouGlobal.hostName() === 'youku') {
            this.setYouku();
        }
    },
    _bind: function() {},
    _setHook: function() {
        var funName = SogouGlobal.getFunction();
        funName && this[funName]();
    },
    setPlay: function() {
        var self = this;
        var v = this._video;
        v.is_Loaded = 0;
        v.is_Playing = 0;
        v.is_loadstart = false;
        v.addEventListener("play", function() {}, false);
        v.addEventListener("loadstart", function() {
            v.is_loadstart = true
        }, false);
        v.addEventListener("loadeddata", function() {}, false);
        v.addEventListener("click", function() {}, false);
        v.orgPlay = this._video.play;
        v.play = function() {
            SogouGlobal.printLog('v.play - ' + this.src);
            if (this.src === "") {
                self.clickLoaded = true;
                return false;
            }
            v.isPlaying++;
            if (!v.is_loadstart && v.isLoaded > 0) {
                //v.orgPlay();
            }
            if (v.is_Loaded > 0 && v.is_Playing != v.is_Loaded) {
                return;
            }
            if (SogouGlobal.hostName() === 'letv' && !this.hasAdPlayed) {
                this.hasAdPlayed = true;
                SogouGlobal.sendEvent(v, 'ended');
                window.setTimeout(function(){
                    //$('video').trigger('ended');
                    self.before();
                    self.newPlay();
                    self.after();
                }, 1000);
            } else {
                //console.log('play');
                self.before();
                self.newPlay();
                self.after();
            }
        };
        v.orgLoad = this._video.load;
        v.load = function() {
            v.isLoaded++;
            if (this.autoplay || self.clickLoaded) {
                self.clickLoaded = false;//使用一次后，点击取消
                self.before();
                self.newLoad();
                self.after();
            }
        };
    },
    indexOf: function(v) {
        var doc = document;
        var vs = doc.getElementsByTagName('video');
        var len = vs.length;
        for (var i = 0; i < len; ++i) {
            if (vs[i] == v) {
                return i;
            }
        }
        var pageUrl = doc.URL;
        if (SogouGlobal.inFrame()) {
            var frames = doc.getElementsByTagName("iframe");
            var flen = frames.length;
            for (var j = 0; j < flen; j++) {
                var m = frames[j];
                if (typeof(m.src) != "undefined" && /(pptv)\.com/i.test(m.src)) {
                    var conDoc = m.contentDocument;
                    var g = conDoc.getElementsByTagName("video");
                    var glen = g.length;
                    for (var index = 0; index < glen; index++) {
                        if (g[index] == v) {
                            return index;
                        }
                    }
                }
            }
        }
        return -1;
    },
    before: function() {

    },
    after: function() {
        var self = this;
        self._video.readyState = 4;
//        self._video.timeupdateCount = 100;

        // for letv
//        var sendTimeupdate = function () {
//            if (self._video.timeupdateCount > 0){
//                self._video.timeupdateCount --;
//                //SogouGlobal.sendEvent(self._video, 'timeupdate');
//                setTimeout(sendTimeupdate, 1000);
//            }
//        };
//        sendTimeupdate();
        //setTimeout(sendTimeupdate, 1000);
//        window.setInterval(function(){
//            var eventObj = document.createEvent('HTMLEvents');
//            eventObj.initEvent('timeupdate', false, true);
//            self._video.dispatchEvent(eventObj);
//        }, 1000);
    },
    newPlay: function() {
        new bridge().send('semobvideo://play?index=' + this.indexOf(this._video));
    },
    newLoad: function() {
        new bridge().send('semobvideo://load?index=' + this.indexOf(this._video));
    },
    addOverlay: function() {
        var v = this._video;
        if (v.style.display == "none") {
            return;
        };
        if (!v.hasOverlay) {
            var parent = v.parentNode;
            if (parent && parent.style.display != "none") {
                parent.style.position = "relative";
                var overlay = document.createElement("div");
                overlay.id = "sogouvideo-overlay-" + this._index;
                overlay.style.cssText = "width:100%;height:100%;position:absolute;top:0;background-color:rgba(0,0,0,0) !important;";
                parent.appendChild(overlay);
                overlay.style.zIndex = 999;
                overlay.addEventListener("click", function() {
                    v.play();
                }, false);
            };
            v.hasOverlay = true;
        }
    },
    changeVideoWithImage: function() {
        var video = this._video;
        var imgs = video.getElementsByTagName('img');
        var imgSrc = '';
        var i = 0, len = imgs.length;
        for (; i < len; i ++) {
            if (imgs[i].src) {
                imgSrc = imgs[i].src;
            }
        }
        var parentNode = video.parentNode;
        parentNode.style.position = 'relative';
        //var img = document.createElement('img');
        if (SogouGlobal.hostName() === 'dianying') {
            // hack for 电影网
            parentNode.style.width = '100%';
            parentNode.style.height = '100%';
            //imgSrc = video.getAttribute('poster');
        }
        var iDiv = document.createElement('div');
        iDiv.id = 'sogou-imgdiv-' + this._index;
        iDiv.style.position = 'absolute';
        iDiv.style.top = 0;
        iDiv.style.left = 0;
        iDiv.style.width = "100%";
        iDiv.style.height = "100%";
        if (imgSrc) {
            iDiv.style.backgroundImage = 'url(' + imgSrc + ')';
        } else {
            window.setTimeout(function() {
                var imgSrc = video.getAttribute('poster');
                iDiv.style.backgroundImage = 'url(' + imgSrc + ')';
            }, 100);
        }
        iDiv.style.backgroundRepeat = 'no-repeat';
        iDiv.style.backgroundPositionX = 'center';
        iDiv.style.backgroundPositionY = 'center';
        iDiv.style.backgroundColor = '#000';
        iDiv.style.backgroundSize = 'contain';
        iDiv.style.zIndex = 999;
        var player = document.createElement('div');
        player.style.position = 'absolute';
        player.style.top = '50%';
        player.style.left = '50%';
        player.style.width = '80px';
        player.style.height = '80px';
        player.style.margin = '-40px';
        player.style.borderRadius = '40px';
        player.style.backgroundColor = 'rgba(33, 33, 33, 0.5)';
        var picon = document.createElement('div');
        picon.style.id = 'picon';
        picon.style.position = 'absolute';
        picon.style.top = '20px';
        picon.style.left = '25px';
        picon.style.width = 0;
        picon.style.height = 0;
        picon.style.borderTop = '20px solid transparent';
        picon.style.borderLeft = '40px solid #ddd';
        picon.style.borderBottom = '20px solid transparent';
        //img.src = imgSrc;
        //iDiv.appendChild(img);
        player.appendChild(picon);
        iDiv.appendChild(player);
        parentNode.appendChild(iDiv);
        video.style.display = 'none';
        window.setInterval(function(){
            video.style.display = 'none';
        }, 300);
        iDiv.onclick = function() {
            video.play();
            return false;
        };
    },
    setYouku: function() {
        var self = this;
        if (SogouGlobal.ios() <= 7) {
            var youkuId = window.setInterval(function() {
                self._video.style.display = 'none';
            }, 250);
            window.setTimeout(function() {
                clearInterval(youkuId);
            }, 3000);
        }
        YKU.Player.prototype.switchFullScreen = function () {};
        playerWidth = function (){
            var a = $(window).width(), b = $(window).height();
            $(".yk-player .yk-player-inner").css({
                width: a + "px",
                height: 9 * a / 16 + "px"
            });
        };
        autoFullscreen = function (){};
        onSwitchFullScreen = function () {
            clearInterval(window.timers);
            setTimeout("playerWidth()", 500);
            setTimeout("playerWidth()", 1E3);
            $("body").removeClass("fullscreen");
            $("body").removeAttr("style");
            $(".yk-m").removeAttr("style");
            playerWidth();
            tabFixed.unfixed();
        };
        onPlayerCompleteH5 = function (a) {};
        onPlayerReadyH5 = function () {};
        window.youkuCheckTimer = setInterval(function (){
            clearInterval(window.timers);
        }, 500);
    }
};

if (!SogouGlobal.hasPageLoaded) {
    SogouGlobal.hookVideoWithInterval();
    document.addEventListener('DOMContentLoaded', function() {
        SogouGlobal.hookVideoWithObserver()
    }, true);
    SogouGlobal.hasPageLoaded = true;
}
