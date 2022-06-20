//
//  SliderContainer.swift
//  DrawerDemo
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//


import SwiftUI
import Combine

struct SliderContainer<Content: SliderViewProtocol> : View {
    @ObservedObject public var control: DrawerControl
    @ObservedObject private var status: SliderStatus
    @GestureState private var isDragging: Bool = false
    @State var gestureState: GestureStatus = .idle
    @State var sliderOffsSet: CGFloat = 0.0
    
    let slider: AnyView
    let type: SliderType
    var body: some View {
        GeometryReader { proxy in
            self.generateBody(proxy: proxy)
        }
    }
    
    func generateBody(proxy: GeometryProxy) -> some View {
        let parentSize = proxy.size
        self.status.parentSize = parentSize
        
        switch self.status.type {
        case .leftFront,  .rightFront:
            let view = ZStack {
                AnyView(Color.white).frame(maxWidth:
                                            self.status.sliderWidth)
                .padding(EdgeInsets(top: -proxy.safeAreaInsets.top, leading: 0, bottom: -proxy.safeAreaInsets.bottom, trailing: 0))
                self.slider
                    .frame(maxWidth:
                            self.status.sliderWidth)
            }
                .shadow(radius: self.status.showRate > 0 ? self.status.shadowRadius : 0)
                .offset(x: self.status.sliderOffset() , y: 0)
                .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .global).updating($isDragging) { _, isDragging, _ in
                    isDragging = true
                }.onChanged({ (value) in
                    guard gestureState == .started || gestureState == .active else { return }
                    if self.status.type.isLeft && value.translation.width < 0 {
                        self.status.currentStatus = .moving(offset: value.translation.width)
                    } else if !self.status.type.isLeft && value.translation.width > 0 {
                        self.status.currentStatus = .moving(offset: value.translation.width)
                    }
                }).onEnded({ (value) in
                    if self.status.type.isLeft {
                        let sliderW = self.status.sliderWidth/2
                        if value.location.x < sliderW{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .hide)
                        }else{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .show)
                        }
                    } else {
                        let sliderW = self.status.sliderWidth/3
                        let offSet = value.translation.width-sliderW
                        if offSet >= 0{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .hide)
                        }else{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .show)
                        }
                    }
                    gestureState = .ended
                }))
                .onChange(of: gestureState) { state in
                    guard state == .started else { return }
                    gestureState = .active
                }
                .onChange(of: isDragging) { value in
                    if value, gestureState != .started {
                        gestureState = .started
                    } else if !value, gestureState != .ended {
                        gestureState = .cancelled
                        print("cancelled")
                    }
                }
            return AnyView.init(view)
        case .leftRear, .rightRear:
            let view = ZStack {
                AnyView(Color.white).frame(maxWidth:
                                            self.status.sliderWidth)
                .padding(EdgeInsets(top: -proxy.safeAreaInsets.top, leading: 0, bottom: -proxy.safeAreaInsets.bottom, trailing: 0))
                self.slider
                    .frame(maxWidth:
                            self.status.sliderWidth)
            }
                .offset(x: self.status.type.isLeft ? 0 : parentSize.width-self.status.sliderWidth, y: 0)
                .frame(maxWidth: self.status.sliderWidth)
                .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .global).updating($isDragging) { _, isDragging, _ in
                    isDragging = true
                }.onChanged({ (value) in
                    guard gestureState == .started || gestureState == .active else { return }
                    
                    if self.status.type.isLeft && value.translation.width < 0 {
                        let offSet  = self.status.sliderWidth+value.translation.width
                        self.status.currentStatus = .moving(offset: offSet)
                    } else if !self.status.type.isLeft && value.translation.width > 0 {
                        let offSet  = -self.status.sliderWidth+value.translation.width
                        self.status.currentStatus = .moving(offset: offSet)
                    }
                }).onEnded({ (value) in
                    gestureState = .ended
                    
                    let sliderW = self.status.sliderWidth/3
                    if self.status.type.isLeft {
                        let offSet = value.translation.width+sliderW
                        if offSet <= 0{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .hide)
                        }else{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .show)
                        }
                    } else if !self.status.type.isLeft {
                        let offSet = value.translation.width-sliderW
                        if offSet >= 0{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .hide)
                        }else{
                            self.control.updateSliderStatus(type: self.status.type, showStatus: .show)
                        }
                    }
                }))
                .onChange(of: gestureState) { state in
                    guard state == .started else { return }
                    gestureState = .active
                }
                .onChange(of: isDragging) { value in
                    if value, gestureState != .started {
                        gestureState = .started
                    } else if !value, gestureState != .ended {
                        gestureState = .cancelled
                    }
                }
            return AnyView(view)
        case .none:
            return AnyView(EmptyView())
        }
    }
    
    init(content: Content, drawerControl: DrawerControl) {
        self.slider = AnyView.init(content.environmentObject(drawerControl))
        self.type = content.type
        self.control = drawerControl
        self.status = drawerControl.status[content.type]!
    }
}

#if DEBUG
struct SliderContainer_Previews : PreviewProvider {
    static var previews: some View {
        self.generate()
    }
    
    static func generate() -> some View {
        let view = DemoSlider.init(type: .leftRear)
        let c = DrawerControl()
        c.setSlider(view: view)
        return SliderContainer(content: view, drawerControl: c)
    }
}
#endif

enum GestureStatus: Equatable {
    case idle
    case started
    case active
    case ended
    case cancelled
}
