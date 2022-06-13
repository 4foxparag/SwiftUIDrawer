//
//  MainContainer.swift
//  DrawerDemo
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//


import SwiftUI
import Combine
struct MainContainer<Content: View> : View {
    @ObservedObject private var drawerControl: DrawerControl
    
    @ObservedObject private var leftStatus: SliderStatus
    @ObservedObject private var rightStatus: SliderStatus
    
    @State private var gestureCurrent: CGFloat = 0
    
    let main: AnyView
    private var maxMaskAlpha: CGFloat
    private var maskEnable: Bool
    var anyCancel: AnyCancellable?
    var body: some View {
        GeometryReader { proxy in
            self.generateBody(proxy: proxy)
        }
        //.animation(.default)
    }
    
    init(content: Content,
         maxMaskAlpha: CGFloat = 0.25,
         maskEnable: Bool = true,
         drawerControl: DrawerControl) {
        
        self.main = AnyView.init(content.environmentObject(drawerControl))
        self.maxMaskAlpha = maxMaskAlpha
        self.maskEnable = maskEnable
        self.drawerControl = drawerControl
        
        self.leftStatus = drawerControl.status[.leftRear] ?? (drawerControl.status[.leftFront] ?? SliderStatus(type: .none))
        
        self.rightStatus = drawerControl.status[.rightRear] ?? (drawerControl.status[.rightFront] ?? SliderStatus(type: .none))
        
    }
    
    func generateBody(proxy: GeometryProxy) -> some View {
        
        let haveRear = self.leftStatus.type != .none || self.rightStatus.type != .none
        
        let maxRadius = haveRear ? max(self.leftStatus.shadowRadius, self.rightStatus.shadowRadius) : 0
        
        
        let parentSize = proxy.size
        if haveRear {
            leftStatus.parentSize = parentSize
            rightStatus.parentSize = parentSize
        }
        
        return ZStack {
            self.main
            if maskEnable {
                if self.leftStatus.currentStatus.isShow ||
                    self.rightStatus.currentStatus.isShow{
                    Color.black.opacity(Double(drawerControl.maxShowRate*self.maxMaskAlpha))
                        .animation(.easeIn(duration: 0.15))
                        .onTapGesture {
                            self.drawerControl.hideAllSlider()
                        }
                        .padding(EdgeInsets(top: -proxy.safeAreaInsets.top, leading: 0, bottom: -proxy.safeAreaInsets.bottom, trailing: 0))
                }
            }
        }
        .offset(x:self.offset, y: 0)
        .shadow(radius: maxRadius)
        .gesture(DragGesture().onChanged({ (value) in
            let will = self.offset + (value.translation.width-self.gestureCurrent)
            
            if self.leftStatus.type != .none{
                let range = 0...self.leftStatus.sliderWidth

                if value.startLocation.x < CGFloat(100.0) && !drawerControl.isRightShowing
                {
                    switch self.leftStatus.type{
                    case .leftRear:
                        /*
                        let range = 0...self.leftStatus.sliderWidth
                        if range.contains(will){
                            self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .moving(offset: will))
                        }
                        */
                        
                        self.updateOffsetBy(range: range, will: will, sliderStatus: self.leftStatus)
                        
                    case .leftFront:
                        let newTranslation = value.translation.width-self.leftStatus.sliderWidth
                        if newTranslation < 0{
                            self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .moving(offset: newTranslation))
                        }
                    default:
                        return
                    }
                }else{
                    if drawerControl.isLeftShowing{
                        switch self.leftStatus.type{
                        case .leftRear:
                            self.updateOffsetBy(range: range, will: will, sliderStatus: self.leftStatus)
                        case .leftFront:
                            let newTranslation = value.translation.width-self.leftStatus.sliderWidth
                            if newTranslation < 0{
                                self.leftStatus.currentStatus = .moving(offset: newTranslation)
                            }
                        default:
                            return
                        }
                        self.gestureCurrent = value.translation.width
                    }
                }
            }
            
            if self.rightStatus.type != .none{
                if value.startLocation.x > CGFloat(proxy.size.width-100.0) && !drawerControl.isLeftShowing{
                    
                    switch self.rightStatus.type{
                    case .rightRear:
                        let range = (-self.rightStatus.sliderWidth)...0
                        if range.contains(will) {
                            self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .moving(offset: will))
                        }
                    case .rightFront:
                        let newTranslation = value.translation.width+self.rightStatus.sliderWidth
                        if newTranslation > 0 {
                            self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .moving(offset: newTranslation))
                        }
                    default:
                        return
                    }
                }else{
                    if drawerControl.isRightShowing{
                        switch self.rightStatus.type{
                        case .rightRear:
                            let range = (-self.rightStatus.sliderWidth)...0
                            if range.contains(will) {
                                self.rightStatus.currentStatus = .moving(offset: will)
                            }
                        case .rightFront:
                            let newTranslation = value.translation.width+self.rightStatus.sliderWidth
                            if newTranslation > 0 {
                                self.rightStatus.currentStatus = .moving(offset: newTranslation)
                            }
                        default:
                            return
                        }
                        self.gestureCurrent = value.translation.width
                    }
                }
            }
        }).onEnded({ (value) in
            let will = self.offset + (value.translation.width-self.gestureCurrent)
            
            if self.leftStatus.type != .none{
                if value.startLocation.x < CGFloat(100.0) && !drawerControl.isRightShowing{
                    let range = 0...self.leftStatus.sliderWidth
                    switch self.leftStatus.type{
                    case .leftRear:
                        if will-range.lowerBound > range.upperBound-will{
                            self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .show)
                        }else{
                            self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .hide)
                        }
                    case .leftFront:
                        if will-range.lowerBound > range.upperBound-will{
                            self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .show)
                        }else{
                            self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .hide)
                        }
                    default:
                        return
                    }
                }else{
                    if drawerControl.isLeftShowing{
                        let range = 0...self.leftStatus.sliderWidth
                        
                        switch self.leftStatus.type{
                        case .leftRear:
                            if will-range.lowerBound > range.upperBound-will{
                                self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .show)
                            }else{
                                self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .hide)
                            }
                        case .leftFront:
                            if will-range.lowerBound > range.upperBound-will{
                                self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .show)
                            }else{
                                self.drawerControl.updateSlider(type: self.leftStatus.type, showStatus: .hide)
                            }
                        default:
                            return
                        }
                    }
                }
            }
            
            if self.rightStatus.type != .none,
               value.startLocation.x > CGFloat(proxy.size.width-100.0) && !drawerControl.isLeftShowing{
                let range = (-self.rightStatus.sliderWidth)...0
                switch self.rightStatus.type{
                case .rightRear:
                    if will-range.lowerBound < range.upperBound-will
                    {
                        self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .show)
                    }else{
                        self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .hide)
                    }
                case .rightFront:
                    if will-range.lowerBound < range.upperBound-will {
                        self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .show)
                    }else{
                        self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .hide)
                    }
                default:
                    return
                }
            }else{
                if drawerControl.isRightShowing{
                    let range = (-self.rightStatus.sliderWidth)...0
                    switch self.rightStatus.type{
                    case .rightRear:
                        if will-range.lowerBound < range.upperBound-will
                        {
                            self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .show)
                        }else{
                            self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .hide)
                        }
                    case .rightFront:
                        if will-range.lowerBound < range.upperBound-will {
                            self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .show)
                        }else{
                            self.drawerControl.updateSlider(type: self.rightStatus.type, showStatus: .hide)
                        }
                    default:
                        return
                    }
                }
            }
            self.gestureCurrent = 0
        }))
    }
    
    func updateOffsetBy(range: ClosedRange<CGFloat>, will: CGFloat, sliderStatus: SliderStatus){
        if range.contains(will){
            self.drawerControl.updateSlider(type: sliderStatus.type, showStatus: .moving(offset: will))
        }
    }
    
    var offset: CGFloat {
        switch (self.leftStatus.currentStatus, self.rightStatus.currentStatus){
        case (.hide, .hide):
            return 0
        case (.show, .hide):
            switch (self.leftStatus.type){
            case .leftRear: return self.leftStatus.sliderOffset()
            default: return 0
            }
        case (.hide, .show):
            switch (self.rightStatus.type){
            case .rightRear: return self.rightStatus.sliderOffset()
            default: return 0
            }
        default:
            if self.leftStatus.currentStatus.isMoving {
                switch (self.leftStatus.type){
                case .leftRear: return self.leftStatus.sliderOffset()
                default: return 0
                }
            } else if self.rightStatus.currentStatus.isMoving {
                switch (self.rightStatus.type){
                case .rightRear: return self.rightStatus.sliderOffset()
                default: return 0
                }
            }
        }
        return 0
        
    }
    
    var maxShowRate: CGFloat {
        return max(self.leftStatus.showRate, self.rightStatus.showRate)
    }
}

#if DEBUG
struct MainContainer_Previews : PreviewProvider {
    static var previews: some View {
        self.generate()
    }
    
    static func generate() -> some View {
        let view = DemoSlider.init(type: .leftRear)
        let c = DrawerControl()
        c.setSlider(view: view)
        return MainContainer.init(content: DemoMain(), drawerControl: c)
    }
}
#endif
