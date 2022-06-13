# SwiftUIDrawer

A description of this package.

## Use
    import SwiftUI
    import SwiftDrawer
    struct ContentView : View {
        var body: some View {
          Drawer()
            .setSlider(view: SliderView(type: .leftRear))
            .setSlider(view: Slider2View(type: .rightFront))
            .setMain(view: HomeView())
        }
    }

## Control
      @EnvironmentObject public var drawerControl: DrawerControl


      public func setSlider<Slider: SliderViewProtocol>(view: Slider,
                                                      widthType: SliderWidth = .percent(rate: 0.6),
                                                      shadowRadius: Length = 10)

      public func setMain<Main: View>(view: Main)
      public func show(type: SliderType, isShow: Bool)
      public func hideAllSlider()
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
