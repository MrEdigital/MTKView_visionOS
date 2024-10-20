# MTKView_visionOS

![language](https://img.shields.io/badge/language-swift-orange.svg)
![CI Status](https://img.shields.io/badge/build-passing-success.svg)
[![Twitter](https://img.shields.io/badge/twitter-@ericreedy-blue.svg)](http://twitter.com/ericreedy)

## Description

A simple recreation of the MTKView from iOS/macOS, intended for use in visionOS.  It works exactly the same, and allows for 2D Metal drawing within a (presumably) windowed application.

## Why

This was, for some reason, a missing feature.  I'm assuming they will one day add it, at which point this can retire, but then again, the last time I did that was an Apple Watch web browser back in 2018, and for some reason that's still needed, so who knows.

## Potential Uses

1. You can use this straight away in a visionOS app exactly as you would, normally, an MTKView in iOS or macOS.
2. You can create a shared typelias, and bridge this across all 3 platforms with only a little extra work.

## Installation

Just drop the Swift file into your project and compile.

There's also an included "ScreenAlias.swift" that typealiases `NSScreen` for macOS, `UIScreen` for iOS0, and defines a basic struct for visionOS, allowing for cross-compatibility on screen scale checks.  If you'd rather not, you will need to handle the usage of `Screen.scale` in the main file.  For visionOS, the value should only ever be 1.

## Usage

See tutorials that make use of Metal and MTKView.

## Support

I'm making use of this as-is in one of my projects currently, and it seems to be stable and complete, so I'm not expecting any additional changes from my end at this point.

If, however, you find a need for a particular change, a suggestion to make it better, then certainly feel free to open a pull request and I will review.  Thanks in advance, if you do.

## License

This project is available under [The MPL-2.0 License](https://www.mozilla.org/en-US/MPL/2.0/).  
Copyright © 2024, [Eric Reedy](mailto:eric@madcapstudios.com). See [LICENSE](LICENSE) file.
