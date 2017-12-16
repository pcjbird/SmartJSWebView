window.SmartJS = {
    
__messageCount: 0,
    
__callbackDeferreds: {},
    
asyncCallback: function(callbackID, isSuccess, valueOrReason) {
    var d;
    
    d = SmartJS.__callbackDeferreds[callbackID];
    if (isSuccess)
    {
        d.resolve(decodeURIComponent(valueOrReason[0]));
    }
    else
    {
        d.reject(decodeURIComponent(valueOrReason[0]));
    }
    return delete SmartJS.__callbackDeferreds[callbackID];
},
    
__callbacks: {},
    
invokeCallback: function (cbID, removeAfterExecute){
    var args = Array.prototype.slice.call(arguments);
    args.shift();
    args.shift();
    
    for (var i = 0, l = args.length; i < l; i++){
        args[i] = decodeURIComponent(args[i]);
    }
    
    var cb = SmartJS.__callbacks[cbID];
    if (removeAfterExecute){
        SmartJS.__callbacks[cbID] = undefined;
    }
    return cb.apply(null, args);
},
    
call: function (obj, functionName, args){
    var formattedArgs = [];
    for (var i = 0, l = args.length; i < l; i++){
        if (typeof args[i] == "function"){
            formattedArgs.push("f");
            var cbID = "__cb" + (+new Date);
            SmartJS.__callbacks[cbID] = args[i];
            formattedArgs.push(cbID);
        }else{
            formattedArgs.push("s");
            formattedArgs.push(encodeURIComponent(args[i]));
        }
    }
    
    var argStr = (formattedArgs.length > 0 ? ":" + encodeURIComponent(formattedArgs.join(":")) : "");
    
    var target = window.webkit;
    if(undefined == target)
    {
        var iframe = document.createElement("IFRAME");
        iframe.setAttribute("src", "easy-js:" + obj + ":" + encodeURIComponent(functionName) + argStr);
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
        
        var ret = SmartJS.retValue;
        SmartJS.retValue = undefined;
        
        if (ret){
            return decodeURIComponent(ret);
        }
    }
    else
    {
        var callbackID, d, message;
        callbackID = SmartJS.__messageCount;
        message = {
        className: obj,
        functionName: encodeURIComponent(functionName),
        arguments: argStr,
        callbackID: callbackID
        };
        d = new Deferred;
        SmartJS.__callbackDeferreds[callbackID] = d;
        target = window.webkit.messageHandlers.SmartJS;
        target.postMessage(message);
        SmartJS.__messageCount++;
        return d.promise();
    }
},
    
inject: function (obj, methods){
    window[obj] = {};
    var jsObj = window[obj];
    
    for (var i = 0, l = methods.length; i < l; i++){
        (function (){
         var method = methods[i];
         var jsMethod = method.replace(new RegExp(":", "g"), "");
         jsObj[jsMethod] = function (){
         return SmartJS.call(obj, method, Array.prototype.slice.call(arguments));
         };
         })();
    }
}
};
