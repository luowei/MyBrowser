SogouMse.createNamespace('ms2e');

if(typeof SogouMse.ms2e.messageDespatcher !== 'undefined'){
	SogouMse.ms2e.messageDespatcher.clear();
}

SogouMse.ms2e.messageDespatcher = new function(){
    var messageQueue = [];
    var running = false;
    var timer = null;
    var despatchMessage = function() {
        window.location = messageQueue.pop();

        if(messageQueue.length){
            despatchNext();
        } else {
            timer = null;
            running = false;
        }
    }
    var despatchNext = function(){
        timer = setTimeout(despatchMessage,10);
        running = true;
    }
    this.sendMessageToLocal = function(message) {
        if (SogouMse.nativeBridge){
            SogouMse.nativeBridge.sendToNative(message);
        } else {
            messageQueue.unshift(message);
            if(!running){
                despatchNext();
            }
        }
    }
    this.stop = function() {
        if(timer)
            clearTimeout(timer);
    }
    this.clear = function(){
        this.stop();
        messageQueue = [];
    }
};

SogouMse.ms2e.emptyCallback = function(){};
SogouMse.ms2e.Tab = function(tabInfo) {
    this.id = typeof tabInfo.tabid !== 'undefined' ? tabInfo.tabid : null;
    this.title = typeof tabInfo.title !== 'undefined' ? tabInfo.title : null;
    this.url = typeof tabInfo.url !== 'undefined' ? tabInfo.url : null;
    this.isbackground = typeof tabInfo.isbackground !== 'undefined' ? tabInfo.isbackground : null;
    this.faviconurl = typeof tabInfo.faviconurl !== 'undefined' ? tabInfo.faviconurl : null;
    this.status = typeof tabInfo.status !== 'undefined' ? tabInfo.status : null;
    this.navitype = typeof tabInfo.navitype !== 'undefined' ? tabInfo.navitype : null;
    this.index = typeof tabInfo.tabindex !== 'undefined' ? tabInfo.tabindex : null;
    this.visiable = typeof tabInfo.visiable !== 'undefined' ? tabInfo.visiable : null;
}

SogouMse.ms2e.SogoumseExt = function(name,tabid) {
    // construction
    this.name = name;
    this.tabid = tabid; //if from tab, can be null
    this.callbacks = new function(){
        this.push = function(fun){
            var id =''+ ((new Date()).getTime())%100000;
            id += (fun.toString()).length%1000;
            id += Math.ceil(Math.random()*10000);
            id = parseInt(id);
            this[id]=fun;
            return id;
        };
        this.splice = function(id){
            var deleted = this[id];
            delete this[id];
            return deleted;
        }
    };
    this.quickLaunch = new QuickLaunch(this);
    this.tabs = new Tabs(this);
    this.extension = new Extension(this);
    this.browserUtility = new BrowserUtility(this);
    this.commonSniffer = new CommonSniffer(this);
    this.pingbackProxy = new PingbackProxy(this);

    //variables
    var sogoumseEmptyCallback = SogouMse.ms2e.emptyCallback;
    var sogoumseMessageDespatcher = SogouMse.ms2e.messageDespatcher;
    function Event(name, sogoumse) {
        this.name = name;
        this.sogoumse = sogoumse;
        this.addListener = function (callback) {
            callback = callback || sogoumseEmptyCallback;
            var index = this.sogoumse.callbacks.push(callback);
            var eventname = this.name;
            var extname = this.sogoumse.name;
            var l = "sogoumse://add" + eventname + "listener?ext=" + encodeURIComponent(extname) + "&callbackid=" + index;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
    }

    function Tabs(sogoumse) {
        // TODO: longtime connection
        this.sogoumse = sogoumse;
        if(sogoumse.tabid){
            this.onMessage = new Event("tabsonmessage", this.sogoumse);
        }
        this.sendMessage = function (tabid, message, callback) {
            callback = callback || sogoumseEmptyCallback;
            var index = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://tabsonmessage" + "?ext=" + encodeURIComponent(this.sogoumse.name) +
            "&message=" + encodeURIComponent(JSON.stringify(message)) + "&tabid="+tabid + "&callbackid="+index;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.onUpdated = new Event("tabsonupdate", this.sogoumse);
        this.onRemoved = new Event("tabsonremove", this.sogoumse);
        this.onCreated = new Event("tabsoncreate", this.sogoumse);
        this.onActived = new Event("tabsonactived", this.sogoumse);
        this.get = function (tabid, callback) {
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://gettab?ext=" + encodeURIComponent(this.sogoumse.name) + "&tabid=" + tabid +
            "&callbackid=" + id;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.reload = function (tabid, callback) {
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://reloadtab?ext=" + encodeURIComponent(this.sogoumse.name) + "&tabid=" + tabid +
            "&callbackid=" + id;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.update = function (tabid, updateProperties, callback){
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://updatetab?ext="+encodeURIComponent(this.sogoumse.name) + "&tabid=" + tabid +
            "&callbackid=" + id + "&properties="+encodeURIComponent(JSON.stringify(updateProperties));
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.remove = function (tabids, callback) {
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://removetabs?ext=" + encodeURIComponent(this.sogoumse.name) +
            "&tabids=" + encodeURIComponent(JSON.stringify(tabids)) +
            "&callbackid=" + id;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.excuteScript = function (tabid, injectDetail, callback) {
            callback = callback || sogoumseEmptyCallback;
            // callback format function (string result) {};
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://excutescript?ext="+encodeURIComponent(this.sogoumse.name) +
            "&tabid="+tabid+"&injectdetail="+encodeURIComponent(JSON.stringify(injectDetail))
            +"&callbackid="+id;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.injectCSS = function (tabid, injectDetail, callback) {
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback) ;
            var l = "sogoumse://injectcss?ext="+encodeURIComponent(sogoumse.name)+"&tabid="+tabid+
            "&injectdetail="+encodeURIComponent(JSON.stringify(injectDetail))+"&callbackid="+id;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.getCurrent = function (callback) {
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback) ;
            var l = "sogoumse://getcurrenttab?ext=" + encodeURIComponent(this.sogoumse.name) + "&callbackid=" + id;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };

        this.create = function (createProperties, callback) {
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback) ;
            var l = "sogoumse://createtab?ext="+encodeURIComponent(this.sogoumse.name)+"&properties="+encodeURIComponent(JSON.stringify(createProperties))+"&callbackid="+id;
            if(sogoumse.tabid){
                l = l+"&fromtabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.openUrl = function(url){
            var l = "sogoumse://tabopenurl?ext="+encodeURIComponent(this.sogoumse.name)+"&url="+encodeURIComponent(url);
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }

        this.layer = new function (){
            this.create = function (properties, callback){
                callback = callback || sogoumseEmptyCallback;
                var id = sogoumse.callbacks.push(callback) ;
                var l = "sogoumse://createtabslayer?ext="+encodeURIComponent(sogoumse.name)+"&properties="+encodeURIComponent(JSON.stringify(properties))+"&callbackid="+id;
                if(sogoumse.tabid){
                    l = l+"&fromtabid="+sogoumse.tabid;
                }
                sogoumseMessageDespatcher.sendMessageToLocal(l);
            };
            this.onMessage = new Event("layeronmessage", sogoumse);
            this.sendMessage = function (tabid, message, callback) {
                tabid = tabid ? tabid : sogoumse.tabid;
                callback = callback || sogoumseEmptyCallback;
                var index = sogoumse.callbacks.push(callback);
                var l = "sogoumse://layeronmessage" + "?ext=" + encodeURIComponent(sogoumse.name) +
                "&message=" + encodeURIComponent(JSON.stringify(message)) + "&tabid="+tabid + "&callbackid="+index;
                if(sogoumse.tabid){
                    l = l+"&fromtabid="+sogoumse.tabid;
                }
                sogoumseMessageDespatcher.sendMessageToLocal(l);
            };
            this.resize = function (properties, callback){
                callback = callback || sogoumseEmptyCallback;
                var id = sogoumse.callbacks.push(callback) ;
                var l = "sogoumse://resizetabslayer?ext="+encodeURIComponent(sogoumse.name)+"&properties="+encodeURIComponent(JSON.stringify(properties))+"&callbackid="+id;
                if(sogoumse.tabid){
                    l = l+"&fromtabid="+sogoumse.tabid;
                }
                sogoumseMessageDespatcher.sendMessageToLocal(l);
            };
            this.remove = function (tabid){
                tabid = tabid ? tabid : sogoumse.tabid;
                var l = "sogoumse://removetabslayer?ext="+encodeURIComponent(sogoumse.name)+"&tabid="+tabid;
                if(sogoumse.tabid){
                    l = l+"&fromtabid="+sogoumse.tabid;
                }
                sogoumseMessageDespatcher.sendMessageToLocal(l);
            }
        }

    };

    function Extension(sogoumse) {
        this.sogoumse = sogoumse;
        // callback format: function(json message, MessageSender sender)
        if(!sogoumse.tabid){
            this.onMessage = new Event("extensiononmessage", this.sogoumse);
        }
        this.sendMessage = function (message, callback) {
            callback = callback || sogoumseEmptyCallback;
            var index = this.sogoumse.callbacks.push(callback) ;
            var l = "sogoumse://extensiononmessage" + "?ext=" + encodeURIComponent(this.sogoumse.name) + "&message=" + encodeURIComponent(JSON.stringify(message)) + "&callbackid="+index;
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
    }

    function QuickLaunch(sogoumse) {
        this.sogoumse = sogoumse;
        this.onClicked = new Event("quicklaunchclicked", this.sogoumse);
        this.showRedDot = function(show){
            var l = "sogoumse://showreddot?ext="+encodeURIComponent(this.sogoumse.name)+"&show="+show;
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
        this.add = function(info){
            var l = "sogoumse://addquicklaunch?ext="+encodeURIComponent(this.sogoumse.name) +"&info=" + encodeURIComponent(JSON.stringify(info));
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
    }

    function BrowserAction(sogoumse) {
        this.sogoumse = sogoumse;
        this.getBadgeText = function (callback) {}; // callback format function (string result) {};
        this.setBadgeText = function (badgeText){};
        this.getTitle = function (callback) {}; // callback format function (string result) {};
        this.setTitle = function (title, callback){}; // callback format function (string result) {};
        this.setIcon = function (iconurl, callback){}; // callback format function (string result) {};
        this.enable = function (){}; // Different to chrome, the enalbe/disable is apply to all tabs.
        this.disable = function (){}; // Different to chrome, the enalbe/disable is apply to all tabs.
        this.onClick = new Event("browseractiononclick", this.sogoumse);
    }

    function BrowserUtility(sogoumse) {
        this.sogoumse = sogoumse;
        this.browserUUID = function (callback) {
            // browserUUID callback: function (uuid) {}
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://getUUID?ext="+encodeURIComponent(this.sogoumse.name)+"&callbackid="+id;
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.showTip = function(message){
            var  l = "sogoumse://showtip?ext="+encodeURIComponent(this.sogoumse.name)+"&message="+encodeURIComponent(message);
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
        this.showDRScanner = function (callback) {
            // callback format function (string result) {};
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://showDrcode?ext="+encodeURIComponent(this.sogoumse.name)+"&callbackid="+id;
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.signature = function (code, callback){
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://extGetSignature?ext="+encodeURIComponent(this.sogoumse.name)+
                "&callbackid="+id + "&code="+encodeURIComponent(code);
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.browserInfo = function (callback){
            callback = callback || sogoumseEmptyCallback;
            var id = this.sogoumse.callbacks.push(callback);
            var l = "sogoumse://getbrowserinfo?ext="+encodeURIComponent(this.sogoumse.name)+"&callbackid="+id;
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.shareWithInfo = function(info, callback){
            callback = callback || sogoumseEmptyCallback;
            var id = sogoumse.callbacks.push(callback);
            var l = "sogoumse://sharewithinfo?ext="+encodeURIComponent(sogoumse.name)+"&callbackid="+id
            + "&info=" + encodeURIComponent(JSON.stringify(info));
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
        this.getSupportedShareType = function(callback){
            if (!callback || typeof callback !== 'function'){
                return;
            }
            var id = sogoumse.callbacks.push(callback);
            var l = "sogoumse://getsupportedsharetype?ext="+encodeURIComponent(sogoumse.name)+"&callbackid="+id;
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
        this.sendToCilpBoard = function (text, callback){
            callback = callback || sogoumseEmptyCallback;
            if (typeof callback !== 'function' || typeof text !== 'string'){
                return;
            }
            var id = sogoumse.callbacks.push(callback);
            var l = "sogoumse://sendToCilpBoard?ext="+encodeURIComponent(sogoumse.name)+"&string="+encodeURIComponent(text)+"&callbackid="+id;
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
    }
    function PingbackProxy(sogoumse) {
        this.sogoumse = sogoumse;
        this.sendPingback = function (key){
            var l = "sogoumse://sendPingback?ext="+encodeURIComponent(this.sogoumse.name)+"&key="+encodeURIComponent(key);
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
        this.sendInstantPingback = function(key, value){
            var l = "sogoumse://sendInstancePingback?ext="+encodeURIComponent(this.sogoumse.name)+"&key="+encodeURIComponent(key) + "&value=" + encodeURIComponent(value);
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
    }
    function CommonSniffer(sogoumse) {
        this.sogoumse = sogoumse;
        this.downloadAll = function (array) {
            var l = "sogoumse://downloadAll?ext="+encodeURIComponent(this.sogoumse.name)+"&resources="+encodeURIComponent(JSON.stringify(array));
            if(sogoumse.tabid){
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        };
        this.download = function (array) {
            var l = "sogoumse://downloadOne?ext="+encodeURIComponent(this.sogoumse.name)+"&resources="+encodeURIComponent(JSON.stringify(array));
            if(sogoumse.tabid) {
                l = l+"&tabid="+sogoumse.tabid;
            }
            sogoumseMessageDespatcher.sendMessageToLocal(l);
        }
    }
}

SogouMse.ms2e.MessageSender = function(tab, id) {
    this.tab = tab;
    this.id = id;
    this.url = tab ? (tab.url ? tab.url : null) : null;
}
SogouMse.ms2e.excuteScript = function(ext, code){
    for(var i = 0; i < this.sogoumse_exts.length; i++){
        var sogoumse = this.sogoumse_exts[i].sogoumse;
        if (sogoumse.name === ext){
            return this.sogoumse_exts[i].excuteScript(code);
        }
    }
}