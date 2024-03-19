//
//  MTKView_visionOS.swift
//
//  Created by Eric Reedy on 2/3/24.
//  Copyright © 2024 Eric Reedy. All rights reserved.
//

#if os(visionOS)

import Foundation
import MetalKit
import SceneKit

/// Allows an object to render into the `MTKView_visionOS` view and respond to resize events.
///
public protocol MTKViewDelegate_visionOS: AnyObject {

    /// Called whenever the drawableSize of the view will change
    ///
    /// Delegate can recompute view and projection matricies or regenerate any buffers to be
    /// compatible with the new view size or resolution
    ///
    func mtkView(_ view: MTKView_visionOS, drawableSizeWillChange size: CGSize)

    /// Called on the delegate when it is asked to render into the view
    ///
    func drawInMTKView(_ view: MTKView_visionOS)
}

/// A custom implementation of `MTKView` intended to be used on visionOS as a stopgap until it
/// is officially supported.  `MTKView` is a View for rendering Metal content.
///
public class MTKView_visionOS: UIView {

    /// The delegate handling common view operations
    ///
    public weak var delegate: MTKViewDelegate_visionOS?

    /// A boolean indicating the readiness of the view to begin rendering into its layer.
    ///
    /// This is managed internally, but can be set explicitly for the sake of cross-platform
    /// typealias management.
    ///
    public var isReady: Bool = false

    /// A boolean indicating whether or not the underlying layer should re-render on the next
    /// frame.
    ///
    public var needsRedraw: Bool = true

    /// The `MTLDevice` used to create Metal objects.
    ///
    /// This must be explicitly set by the application unless it was passed into the
    /// initializer. Defaults to nil.
    ///
    public let device: MTLDevice?

    /// The drawable to be used for the current frame.
    ///
    /// currentDrawable is updated at the end -draw (i.e. after the delegate's drawInMTKView
    /// method is called).
    ///
    public var currentDrawable: CAMetalDrawable? {
        return metalLayer.nextDrawable()
    }

    /// The pixelFormat for the drawable's texture.
    ///
    /// Defaults to `.rgba8Unorm`.
    ///
    public let colorPixelFormat: MTLPixelFormat

    /// The clear color value used to generate the currentRenderPassDescriptor.
    ///
    /// Defaults to `MTLClearColorMake(0,0,0,1)`.
    ///
    public var clearColor: MTLClearColor = MTLClearColorMake(0,0,0,1)

    /// A render pass descriptor generated from the currentDrawable's texture and the view's
    /// depth, stencil, and sample buffers and clear values.
    ///
    /// This is a convience property.  The view does not use this descriptor and there is no
    /// requirement for an app to use this descriptor.
    ///
    public var currentRenderPassDescriptor: MTLRenderPassDescriptor? {
        guard let drawable = currentDrawable else { return nil }

        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].clearColor = clearColor
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].loadAction = .clear

        return descriptor
    }

    /// Forces the underlying layer to be formed from the CAMetalLayer class.
    ///
    public override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }

    /// A reference to the underlying Metal layer.
    ///
    /// Force unwrapped because the `layerClass` specification should ensure its type.
    ///
    public var metalLayer: CAMetalLayer {
        return self.layer as! CAMetalLayer
    }

    /// Used to continually render the layer in sync with the display.
    ///
    private var displayLink: CADisplayLink?

    /// A convenience initializer for this class.  This calls `init(frame:device:colorPixelFormat:)`,
    /// providing a default frame of `.zero` and device of `MTLCreateSystemDefaultDevice()`.
    ///
    /// - parameter colorPixelFormat: The pixelFormat for the drawable's texture.
    ///                               Defaults to `.rgba8Unorm`
    ///
    public convenience init(colorPixelFormat: MTLPixelFormat = .rgba8Unorm) {
        self.init(frame: .zero, device: MTLCreateSystemDefaultDevice(), colorPixelFormat: colorPixelFormat)
    }

    /// The base initializer for this class.
    ///
    /// - parameter frame: The initial frame of the view.
    /// - parameter device: The `MTLDevice` used to create Metal objects.
    /// - parameter colorPixelFormat: The pixelFormat for the drawable's texture.
    ///                               Defaults to `.rgba8Unorm`
    ///
    public init(frame frameRect: CGRect,
                device: MTLDevice?,
                colorPixelFormat: MTLPixelFormat = .rgba8Unorm)
    {
        self.device = device
        self.colorPixelFormat = colorPixelFormat
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.device = MTLCreateSystemDefaultDevice()
        self.colorPixelFormat = .rgba8Unorm
        super.init(coder: coder)
        commonInit()
    }

    /// A common initialization function used for setup.
    ///
    private func commonInit() {
        self.metalLayer.device = device
        self.metalLayer.pixelFormat = colorPixelFormat

        updateViewSizeBufferIfNeeded()

        displayLink = CADisplayLink(target: self, selector: #selector(renderLoop))
        displayLink?.add(to: .main, forMode: .default)

        isReady = true
        needsRedraw = true
    }

    /// This function is called every frame, updating the view size buffer, performing rendering,
    /// and dispathcing associated delegate callbacks, as needed.
    ///
    @objc private func renderLoop() {
        self.updateViewSizeBufferIfNeeded()
        if needsRedraw {
            delegate?.drawInMTKView(self)
            draw(bounds)
            needsRedraw = false
        }
    }

    /// Updates the view size buffer so long as the view `isReady`, and the drawable size has changed.
    ///
    public func updateViewSizeBufferIfNeeded() {
        guard isReady, drawableSize != bounds.size else { return }
        drawableSize = bounds.size
        updateViewSizeBuffer()
    }
    private var drawableSize: CGSize = .zero

    /// Updates the view size buffer and informs the `delegate` of the implending change.
    ///
    public func updateViewSizeBuffer() {
        let scale = Screen.scale
        let drawableSize = bounds.size * scale
        delegate?.mtkView(self, drawableSizeWillChange: drawableSize)
        metalLayer.drawableSize = drawableSize
    }
}

#endif
