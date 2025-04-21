//
//  NativeImage.swift
//  Runner
//
//  Created by LittleSheep on 2025/4/21.
//

import Flutter
import UIKit
import Kingfisher

class FLNativeImageFactory : NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeImage(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class FLNativeImage : NSObject, FlutterPlatformView {
    private var _view: ImageView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = ImageView(frame: frame)
        super.init()
        
        let argsMap = args as! [AnyHashable: Any]
        let source = argsMap["src"] as! String
        let blurHash = argsMap["blur"] as? String
        
        if let url = URL(string: source) {
            _view.setImage(from: url, blurHash: blurHash)
        }
    }
    
    func view() -> UIView {
        return _view
    }
}
