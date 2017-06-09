// This file contains the source for the Javascript side of the
// WebViewJavascriptBridge. It is plaintext, but converted to an NSString
// via some preprocessor tricks.
//
// Previous implementations of WebViewJavascriptBridge loaded the javascript source
// from a resource. This worked fine for app developers, but library developers who
// included the bridge into their library, awkwardly had to ask consumers of their
// library to include the resource, violating their encapsulation. By including the
// Javascript as a string resource, the encapsulation of the library is maintained.

#import "WebViewJavascriptBridge_JS.h"

NSString * WebViewJavascriptBridge_js() {
	#define __wvjb_js_func__(x) #x
	
	// BEGIN preprocessorJSCode
	static NSString * preprocessorJSCode = @__wvjb_js_func__(
;(function() {
        if (window.ios) {
            return;
        }
        window.ios = {
        send: send,
        _handleMessageFromObjC: _handleMessageFromObjC
        };
        var responseCallbacks = {};
        var uniqueId = 1;
        
        function send(data) {
            _doSend({
            methodName: data.methodName,
            data: data.data
            }, data.responseCallback);
        }
        
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            // iOS7 JavascriptCore
            try {
                ios_old.setValue(message);
            } catch (e) {
                console.log(e);
            }
            // iOS8+ WKWebView
            try {
                window.webkit.messageHandlers["ios_smh"].postMessage(message);
            } catch (e) {
                console.log(e);
            }
        }
        
        function _dispatchMessageFromObjC(messageJSON) {
            setTimeout(function _timeoutDispatchMessageFromObjC() {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                        return;
                    }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                }
            });
        }
        
        function _handleMessageFromObjC(messageJSON) {
            _dispatchMessageFromObjC(messageJSON);
        }
    })();
	); // END preprocessorJSCode

	#undef __wvjb_js_func__
	return preprocessorJSCode;
};
