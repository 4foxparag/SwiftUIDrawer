//
//  DrawerControl.swift
//  SwiftDrawer
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//


import Foundation
import SwiftUI
import Combine
public class DrawerControl: ObservableObject {
//    public let objectDidChange = PassthroughSubject<DrawerControl, Never>()
    
    private var statusObserver = [AnyCancellable]()
    private(set) var status = [SliderType: SliderStatus]() {
        didSet {
            statusObserver.forEach {
                $0.cancel()
            }
            statusObserver.removeAll()
            status.forEach { (info) in
                let observer = info.value.objectDidChange.sink { [weak self](s) in
                    let maxRate = self?.status.sorted { (s0, s1) -> Bool in
                        s0.value.showRate > s1.value.showRate
                        }.first?.value.showRate ?? 0
                    if self?.maxShowRate == maxRate {
                        return
                    }
                    self?.maxShowRate = maxRate
                }
                statusObserver.append(observer)
            }
        }
    }
    @Published
    private(set) var sliderView = [SliderType: AnyView]()
    @Published
    private(set) var main: AnyView?
    @Published
    private(set) var maxShowRate: CGFloat = .zero{
        didSet{
            //print("maxShowRate = \(Double(self.maxShowRate*0.25))")
        }
    }

    //Handel the side view opacity
    var isRightShowing: Bool = false
    var isLeftShowing: Bool = false
    
    //show type slider
    public var leftSliderType: SliderType = .none
    public var rightSliderType: SliderType = .none
    
    public func setSlider<Slider: SliderViewProtocol>(view: Slider,
                                                      widthType: SliderWidth = .percent(rate: 0.6),
                                                      shadowRadius: CGFloat = 10) {
        let status = SliderStatus(type: view.type)
        
        status.maxWidth = widthType
        status.shadowRadius = shadowRadius
        self.status[view.type] = status
        self.sliderView[view.type] = AnyView(SliderContainer(content: view, drawerControl: self))
        
        switch view.type{
        case .leftRear, .leftFront:
            self.leftSliderType = view.type
        case .rightRear, .rightFront:
            self.rightSliderType = view.type
        case .none:
            self.rightSliderType = .none
            self.leftSliderType = .none
        }
    }

    public func setMain<Main: View>(view: Main, hideSlideView isHide: Bool = true) {
        let container = MainContainer(content: view, drawerControl: self)
        //self.main = AnyView(container)
        withAnimation(.linear(duration: 0.5)) {
            self.main = AnyView(container)
        }
        
        //Hide Slide view on set Main view
        if isHide{
            if self.isLeftShowing{
                self.isLeftShowing = false
                self.status[leftSliderType]?.currentStatus = .hide
            }
            
            if self.isRightShowing{
                self.isRightShowing = false
                self.status[rightSliderType]?.currentStatus = .hide
            }
        }
            
    }
    
    public func show(type: SliderType, isShow: Bool) {
        
        let haveMoving = self.status.first { $0.value.currentStatus.isMoving } != nil
        if haveMoving {
            return
        }
        
        /*
        switch type {
        case .leftRear, .leftFront:
            self.isLeftShowing = isShow
            self.isRightShowing = false
        case .rightRear, .rightFront:
            self.isLeftShowing = false
            self.isRightShowing = isShow
        case .none:
            self.isLeftShowing = false
            self.isRightShowing = false
        }
        self.status[type]?.currentStatus = isShow ? .show: .hide
        */
        
        self.updateSlider(type: type, showStatus: isShow ? .show: .hide)
    }
    
    public func hideAllSlider() {
        self.status.forEach {
            $0.value.currentStatus = .hide
        }
        self.isLeftShowing = false
        self.isRightShowing = false
    }
    
    func updateSlider(type:SliderType, showStatus:ShowStatus)
    {
        switch type {
        case .leftRear, .leftFront:
            self.isLeftShowing = showStatus.isHide ? false : true
            self.isRightShowing = false
        case .rightRear, .rightFront:
            self.isRightShowing = showStatus.isHide ? false : true
            self.isLeftShowing = false
        case .none:
            self.isLeftShowing = false
            self.isRightShowing = false
        }
        self.status[type]?.currentStatus = showStatus
    }
}
