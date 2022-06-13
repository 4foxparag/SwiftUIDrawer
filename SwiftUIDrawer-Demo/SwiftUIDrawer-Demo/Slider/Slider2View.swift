//
//  Slider2View.swift
//  SwiftDrawer_Example
//
//  Created by Parag Patill on 10/06/22.
//  Copyright © 2022 PTech. All rights reserved.
//

import SwiftUI
import SwiftUIDrawer

struct Slider2View : View, SliderProtocol {
    var body: some View {
        VStack{
            Text("Slider 2 View!")
            Spacer()
        }
    }
    let type: SliderType
    init(type: SliderType) {
        self.type = type
    }

}

#if DEBUG
struct Slider2View_Previews : PreviewProvider {
    static var previews: some View {
        Slider2View(type: .rightRear)
    }
}
#endif
