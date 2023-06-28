//
//  JoystickRecognizer.swift
//  SwiftUIJoystick
//
//  Created by Michael Ellis on 12/4/21.
//

import SwiftUI

/// A convenience SwiftUI ViewModifier to make a view behave like a Joystick
public struct JoystickGestureRecognizer: ViewModifier {
    
    @ObservedObject public var joystickMonitor: JoystickMonitor
    /// The size of the control area in which the drag gesture is monitored and reported, is diameter for a circular Joystick
    private var size: CGSize
    /// The shape of the hitbox for the position output of the Joystick Thumb position
    private var shapeType: JoystickShape
    /// The center point of the Joystick where it goes to rest when not being used in `locksInPlace` is false
    private let midPoint: CGPoint
    /// Determines whether or not the Joystick Thumb control goes back to the center point when released
    private let locksInPlace: Bool
    /// Determines if the Joystick prevents movement in the X or Y axis
    /// When a rectangle with unequal width and height is supplied, movement will be prevented in the axis with the smaller value
    private let lockOneAxis: Bool
    @Binding private(set) public var thumbPosition: CGPoint
    
    /// Creates a custom joystick with the following configuration
    ///
    ///     parameter joystickMonitor: An object used to monitor the valid position of the thumb on the Joystick
    ///     parameter width: Width of the joystick control area, for a circular Joystick this is the diameter
    ///     parameter type: Shape of the hitbox for the position output of the Joystick Thumb position
    ///     parameter background: The view displayed as the Joystick background
    ///     parameter foreground: The view displayed as the Joystick Thumb Control
    ///     parameter locksInPlace: Determines if the thumb control returns to the center point when released
    ///     parameter lockOneAxis: Determines if the Joystick prevents movement in the X or Y axis
    public init(thumbPosition: Binding<CGPoint>, monitor: JoystickMonitor, size: CGSize, type: JoystickShape, locksInPlace locks: Bool, lockOneAxis lockAxis: Bool) {
        self.joystickMonitor = monitor
        self._thumbPosition = thumbPosition
        self.size = size
        self.midPoint = CGPoint(x: size.width / 2, y: size.height / 2)
        self.shapeType = type
        self.locksInPlace = locks
        self.lockOneAxis = lockAxis && (size.width != size.height)
    }
    
    /// Produce the correct shape of Joystick
    public func body(content: Content) -> some View {
        switch self.shapeType {
        case .rect:
            rectBody(content)
        case .circle:
            circleBody(content)
        }
    }
    
    /// Restricts movement to area within the x-axis
    internal func getValidThumbCoordinateX(for value: inout CGFloat, maxSize: CGFloat) {
        if lockOneAxis && (size.width < size.height) {
            value = self.midPoint.x
        } else if value <= 0 {
            value = 0
        } else if value > maxSize {
            value = maxSize
        }
    }

    /// Restricts movement to area within the y-axis
    internal func getValidThumbCoordinateY(for value: inout CGFloat, maxSize: CGFloat) {
        if lockOneAxis && (size.height < size.width) {
            value = self.midPoint.y
        } else if value <= 0 {
            value = 0
        } else if value > maxSize {
            value = maxSize
        }
    }

    internal func validateCoordinate(_ emitPoint: inout CGPoint) {
        emitPoint = emitPoint * 2
        if emitPoint.x > size.width {
            emitPoint.x = size.width
        } else if emitPoint.x < -size.width {
            emitPoint.x = -size.width
        }
        if emitPoint.y > size.height {
            emitPoint.y = size.height
        } else if emitPoint.y < -size.height {
            emitPoint.y = -size.height
        }
    }
    
    /// Sets the coordinates of the user's thumb to the JoystickMonitor, which emits an object change since it is an observable
    internal func emitPosition(for xyPoint: CGPoint) {
        var emitPoint = xyPoint
        validateCoordinate(&emitPoint)
        self.joystickMonitor.xyPoint = emitPoint
        self.joystickMonitor.polarPoint = emitPoint.getPolarPoint(from: self.midPoint)
    }
    
    /// Provides a Rectangular area in which the Joystick control can move within and report values for
    ///
    /// - parameter content: The view for which to apply the Joystick listener/DragGesture
    public func rectBody(_ content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        var thumbX = value.location.x
                        var thumbY = value.location.y
                        self.getValidThumbCoordinateX(for: &thumbX, maxSize: self.size.width)
                        self.getValidThumbCoordinateY(for: &thumbY, maxSize: self.size.height)
                        self.thumbPosition = CGPoint(x: thumbX, y: thumbY)
                        let position = value.location - self.midPoint
                        self.emitPosition(for: position)
                    })
                    .onEnded({ value in
                        if !locksInPlace {
                            self.thumbPosition = self.midPoint
                            self.emitPosition(for: .zero)
                        }
                    })
                    .exclusively(
                        before:
                            LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
                            .onEnded({ _ in
                                if !locksInPlace {
                                    self.thumbPosition = self.midPoint
                                    self.emitPosition(for: .zero)
                                }
                            })
                    )
            )
    }
    
    /// Provides a Circular area in which the Joystick control can move within and report values forr
    ///
    /// - parameter content: The view for which to apply the Joystick listener/DragGesture
    public func circleBody(_ content: Content) -> some View {
        content
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged() { value in
                        let distance = self.midPoint.distance(to: value.location)
                        if distance > self.size.width / 2 {
                            // Limit to radius
                            let k = (self.size.width / 2) / distance
                            let position = (value.location - self.midPoint) * k
                            // Order matters
                            self.thumbPosition = position + self.midPoint
                            self.emitPosition(for: position)
                        } else {
                            self.thumbPosition = value.location
                            let position = value.location - self.midPoint
                            self.emitPosition(for: position)
                        }
                    }
                    .onEnded({ value in
                        if !locksInPlace {
                            self.thumbPosition = self.midPoint
                            self.emitPosition(for: .zero)
                        }
                    })
                    .exclusively(
                        before:
                            LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
                            .onEnded({ _ in
                                if !locksInPlace {
                                    self.thumbPosition = self.midPoint
                                    self.emitPosition(for: .zero)
                                }
                            })
                    )
            )
    }
}

