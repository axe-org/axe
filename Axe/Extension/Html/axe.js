function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}
function injectAxe(){
    if(window.axe) {return}
    axe = {}

    var is = {
        types: [
                "Number"
            ,   "Boolean"
            ,   "String"
            ,   "Object"
            ,   "Array"
            ,   "Date"
            ,   "RegEpx"
            ,   "Window"
            ,   "HTMLDocument"
        ]
    };
    is.types.forEach(function(type){
        is[type] = function(type){
            return function(obj){
                return Object.prototype.toString.call(obj) == "[object "+type+"]";
            }
        }(type);
    });

    function AXEData() {

    }
    // 这里输入的data 为 {type : "xxx",value:"xxx"}
    function parseAxeData(data) {
        if(data.type && data.value) {
            var ret = undefined;
            if(data.type === "Number"){
                ret = Number(data.value);
            }else if(data.type === "Boolean"){
                ret = data.value === "true";
            }else if(data.type === "String") {
                ret = data.value;
            }else if(data.type === "Array" || data.type === "Object") {
                ret = JSON.parse(data.value)
            }else if(data.type === "Model"){
                ret = JSON.parse(data.value)
            }else if(data.type === "Image" || data.type === "Data") {
                // 返回的 base64的字符串。
                ret = data.value;
            }else if(data.type === "Date") {
                ret = new Date()
                ret.setTime(data.value)
            }
            return ret;
        }
        return undefined;
    }

    AXEData.prototype = {
        datas : {},
        // 设置方法， 设置时要指明类型 
        setNumber : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.Number(value)) {
                    this.setObjectForKey(key,{
                        value : "" + value,
                        type : "Number"
                    })
                }
            }
        },
        setBoolean : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.Boolean(value)) {
                    this.setObjectForKey(key,{
                        value : "" + value,
                        type : "Boolean"
                    })
                }
            }
        },
        setString : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.String(value)) {
                    this.setObjectForKey(key,{
                        value : value,
                        type : "String"
                    })
                }
            }
        },
        setArray : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.Array(value)) {
                    this.setObjectForKey(key,{
                        value : JSON.stringify(value),
                        type : "Array"
                    });
                }
            }
        },
        // object 或者 称为字典类型。 与 model类型是有区别的。
        setObject : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.Object(value)) {
                    this.setObjectForKey(key,{
                        value : JSON.stringify(value),
                        type : "Object"
                    })
                }
            }
        },
        // model 与 map的区别在于， model 的空值，必须设置为 null ,否则原生会发生异常！！！
        setModel : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.Object(value)) {
                    this.setObjectForKey(key,{
                        value : JSON.stringify(value),
                        type : "Model"
                    });
                }
            }
        },
        // 设置 图片 ， 为图片数据的base64结果
        setImage : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.String(value)) {
                    this.setObjectForKey(key,{
                        value : value,
                        type : "Image"
                    });
                }
            }
        },
        // 设置 data 类型， 实际也是 base64字符串。
        setData : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.String(value)) {
                    this.setObjectForKey(key,{
                        value : value,
                        type : "Data"
                    });
                }
            }
        },
        // 设置 Date类型
        setDate : function(key,value) {
            if (key && value && is.String(key)) {
                if (is.Date(value)) {
                    this.setObjectForKey(key,{
                        value : "" + Date.parse(value),
                        type : "Date"
                    });
                }
            }
        },
        // 以上的设置方法，  对于  shared data 和  createData 是相同的，
        // 但是以下方法不同。 createData 使用以下3个实现。
        // 获取数据时， 不需要指明类型.
        // undefined 表示出错， 而 null 表示key 值不存在，为空。
        get : function(key) {
            if(is.String(key)) {
                item = this.datas[key];
                if (item) {
                    return parseAxeData(item);
                }else {
                    return null;
                }
            }
            return undefined;
        },
        // 删除，必须使用这个方法，而不是设置为空。
        removeItem : function(key) {
            if (key && is.String(key)) {
                this.datas[key] = undefined;
            }
        },
        setObjectForKey: function(key,obj) {
            // 这个是实际的写方法。
            this.datas[key] = obj;
        }
    }

    // 数据接口。
    var sharedData = new AXEData();
    // sharedData 基本 所有接口与 普通的data 接口相同， 只有

    sharedData.setObjectForKey = function(key,value) {
        value["key"] = key;
        setupWebViewJavascriptBridge(function(bridge){
            bridge.callHandler('axe_data_set', value);
        });
    }
    sharedData.removeItem = function(key) {
        if (key && is.String(key)) {
            setupWebViewJavascriptBridge(function(bridge){
                bridge.callHandler('axe_data_remove',key);
            });
        }
    }
    // 共享数据的 get方法，是异步的，需要使用回调来获取值。如 
    //  axe.data.get("login_status",function(data){console.log(data) }) 
    //  共享数据获得的 model 类型， 在 js 中是复制的， 直接修改不会改变共享数据中的值， 所以如果要做修改，就需要提交一下， 即调用 setModel 方法。
    sharedData.get = function(key , callback) { 
        if(! is.String(key) || typeof callback != "function") {
            return;
        }
        setupWebViewJavascriptBridge(function(bridge){
            bridge.callHandler('axe_data_get',key,function(data){
                // 如果是空值， 则是 null
                if(data) {
                    data = parseAxeData(data);
                }
                callback(data)
            });
        });
        
    }
    axe.data = {
        shared : sharedData,
        createData : function(){
            return new AXEData()
        }
    };

    // 路由接口。
    var router = function(url, param, callback){
        if(is.String(url)) {
            var payload = {};
            payload["url"] = url;
            if(param) {
                if(param.__proto__ !== AXEData.prototype) {
                    return;
                }
                payload["param"] = param.datas
            }
            if (callback) {
                if (typeof callback !=  "function") {
                    return;
                }
                payload["callback"] = true;
                setupWebViewJavascriptBridge(function(bridge){ 
                    bridge.callHandler('axe_router_route', payload,function(data) {
                        // 将data 转换为 AXEData.
                        if (data) {
                            axe_data = new AXEData()
                            // 该data 满足格式。
                            axe_data.datas = data
                            data = axe_data
                        }
                        callback(data);
                    });
                });
                
            }else {
                setupWebViewJavascriptBridge(function(bridge){ 
                    bridge.callHandler('axe_router_route', payload)
                });
            }
        }
    }
    // 在 h5模块中，已知 h5回调时的页面关闭由原生代码实现，所以这里只要调用回调即可。  
    var routerCallback = function(param) {
        if(param && param.__proto__ === AXEData.prototype) {
            setupWebViewJavascriptBridge(function(bridge){ 
                bridge.callHandler('axe_router_callback', param.datas)
            });
        }else {
            setupWebViewJavascriptBridge(function(bridge){ 
                bridge.callHandler('axe_router_callback')
            });
        }
    }
    // source 用来获取路由跳转而来的一些信息。 需要注意异步调用问题。
    // source.needCallback  Boolean 类型， 是否有回调。
    // source.payload       AXEData 类型， 附带的参数。
    var getSourceFunc = function( callback ) {
        if(window.axe.router.source) {
            callback(window.axe.router.source)
        }else {
            setupWebViewJavascriptBridge(function(bridge){ 
                bridge.callHandler('axe_router_source',undefined,function(data){
                    if(data){
                        var payload = data["payload"]
                        if (payload) {
                            var axe_data = new AXEData()
                            axe_data.datas = payload
                            data["payload"] = axe_data
                        }
                        data["needCallback"] = data["needCallback"] === "true";
                        window.axe.router.source = data
                    }else{
                        window.axe.router.source = undefined;
                    }
                    callback(window.axe.router.source)
                })
            });
        }
    }
    axe.router = {
        route : router,
        callback : routerCallback,
        getSource : getSourceFunc,
        source : undefined,
    };

    

    // 本地记录 事件与回调
    var registeredEvents = undefined
    // 事件接口。
    // 注册函数
    var registerFunc = function(eventName , callback) {
        if(is.String(eventName) && typeof callback ==  "function" ){
            if(!registeredEvents) {
                registeredEvents = {}
                //  注册回调
                setupWebViewJavascriptBridge(function(bridge){ 
                    bridge.registerHandler('axe_event_callback', function(data) {
                        // 将data 转换为 AXEData.
                        var name = data["name"];
                        var payload = data["payload"]
                        if (payload) {
                            axe_data = new AXEData()
                            // 该data 满足格式。
                            axe_data.datas = payload
                            payload = axe_data
                        }
                        var callbackList =  registeredEvents[name]
                        if (callbackList) {
                            // 如果有回调，则读取回调。
                            for (index in callbackList) {
                                callbackList[index](payload);
                            }
                        }
                    })
                });
            }
            var callbackList = registeredEvents[eventName]
            if (!callbackList) {
                callbackList = new Array()
                registeredEvents[eventName] = callbackList
            }
            callbackList.push(callback)
            setupWebViewJavascriptBridge(function(bridge){ 
                bridge.callHandler('axe_event_register', eventName);
            });
        }
    };
    // 取消注册函数 , 需要注意，这里取消监听，会直接删掉当前网页的这个 eventName的全部监听。
    var cancelRegisterFunc = function(eventName) {
        if(is.String(eventName)) {
            if(registeredEvents) {
                registeredEvents[eventName] = undefined;
                setupWebViewJavascriptBridge(function(bridge){ 
                    bridge.callHandler('axe_event_remove', eventName);
                });
            }
        }
    };
    // 发送事件通知
    var postEventFunc = function(eventName,data) {
        if(is.String(eventName)) {
            event = {}
            event["name"] = eventName
            if(data) {
                if(data.__proto__ !== AXEData.prototype) {
                    return;
                }
                event["data"] = data.datas;
            }
            setupWebViewJavascriptBridge(function(bridge){ 
                bridge.callHandler('axe_event_post',event);
            });
            
        }
    }
    axe.event = {
        postEvent : postEventFunc,
        registerListener : registerFunc,
        removeListener : cancelRegisterFunc,
    }
    // 完成初始化。
    window.axe = axe;
}

injectAxe();