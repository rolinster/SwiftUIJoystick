//
//  JoystickBuilder.swift
//  SwiftUIJoystick
//
//  Created by Michael Ellis on 12/4/21.
//

import SwiftUI

/// A convenience SwiftUI struct to make a Joystick control
public struct JoystickBuilder<background: View, foreground: View>: View {
    
    /// The width/height of the joystick control area, for a circular Joystick this is the diameter
    private(set) public var size: CGSize
    /// The shape of the hitbox for the position output of the Joystick Thumb position
    private(set) public var controlShape: JoystickShape
    
    @ObservedObject private(set) public var joystickMonitor: JoystickMonitor
    @State private(set) public var thumbPosition: CGPoint = .zero
    /// The view displayed as the Joystick background, which also holds a Joystick DragGesture recognizer
    @ViewBuilder public var controlBackground: () -> background
    /// The view displayed as the Joystick Thumb Control, which also holds a Joystick DragGesture recognizer
    @ViewBuilder public var controlThumb: () -> foreground
    /// Determines whether or not the Joystick Thumb control goes back to the center point when released
    private let locksInPlace: Bool
    /// Determines if the Joystick prevents movement in the X or Y axis
    /// When a rectangle with unequal width and height is supplied, movement will be prevented in the axis with the smaller value
    private let lockOneAxis: Bool

    /// Creates a custom joystick with two views that are passed to it
    ///
    ///     parameter position: Will output the valid position of the thumb on the Joystick, from 0 to width
    ///     parameter size: Width/Height of the joystick control area, for a circular Joystick this is the diameter
    ///     parameter shape: Shape of the hitbox for the position output of the Joystick Thumb position
    ///     parameter background: The view displayed as the Joystick background
    ///     parameter foreground: The view displayed as the Joystick Thumb Control
    ///     parameter locksInPlace: Determines if the thumb control returns to the center point when released
    ///     parameter lockOneAxis: Determines if the Joystick prevents movement in the X or Y axis
    public init(monitor: JoystickMonitor, size: CGSize, shape: JoystickShape, @ViewBuilder background: @escaping () -> background, @ViewBuilder foreground: @escaping () -> foreground, locksInPlace locks: Bool, lockOneAxis lockAxis: Bool) {
        self.joystickMonitor = monitor
        self.size = size
        self.controlShape = shape
        self.controlBackground = background
        self.controlThumb = foreground
        self.locksInPlace = locks
        self.lockOneAxis = lockAxis
    }
    
    /// Creates a custom joystick with two views that are passed to it
    ///
    ///     parameter position: Will output the valid position of the thumb on the Joystick, from 0 to width
    ///     parameter width: Width of the joystick control area, for a circular Joystick this is the diameter
    ///     parameter shape: Shape of the hitbox for the position output of the Joystick Thumb position
    ///     parameter background: The view displayed as the Joystick background
    ///     parameter foreground: The view displayed as the Joystick Thumb Control
    ///     parameter locksInPlace: Determines if the thumb control returns to the center point when released
    public init(monitor: JoystickMonitor, width: CGFloat, shape: JoystickShape, @ViewBuilder background: @escaping () -> background, @ViewBuilder foreground: @escaping () -> foreground, locksInPlace locks: Bool) {
        
        self.init(monitor: monitor, size: CGSize(width: width, height: width), shape: shape, background: background, foreground: foreground, locksInPlace: locks, lockOneAxis: false)
    }
    
    public var body: some View {
        controlBackground()
            .frame(width: self.size.width, height: self.size.height)
            .joystickGestureRecognizer(thumbPosition: self.$thumbPosition, monitor: self.joystickMonitor, size: self.size, shape: self.controlShape, locksInPlace: self.locksInPlace, lockOneAxis: self.lockOneAxis)
            .overlay(
                controlThumb()
                    .frame(width: self.size.width / 4, height: self.size.height / 4)
                    .position(x: self.thumbPosition.x, y: self.thumbPosition.y)
                    .joystickGestureRecognizer(thumbPosition: self.$thumbPosition, monitor: self.joystickMonitor, size: self.size, shape: self.controlShape, locksInPlace: self.locksInPlace, lockOneAxis: self.lockOneAxis)
            )
            .onAppear(perform: {
                let midPointX = self.size.width / 2
                let midPointY = self.size.height / 2
                self.thumbPosition = CGPoint(x: midPointX, y: midPointY)
            })
    }
}
