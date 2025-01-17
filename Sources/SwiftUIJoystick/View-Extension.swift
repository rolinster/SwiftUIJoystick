//
//  View-Extension.swift
//  SwiftUIJoystick
//
//  Created by Michael Ellis on 12/4/21.
//

import SwiftUI

public extension View {
    
    /// Convenience modifier for adding a Joystick recognizer
    /// Creates a custom joystick with the following configuration
    ///
    ///     parameter joystickMonitor: An object used to monitor the valid position of the thumb on the Joystick
    ///     parameter size: Width/Height of the joystick control area, for a circular Joystick this is the diameter
    ///     parameter shape: (.rect || .circle) - Shape of the hitbox for the position output of the Joystick Thumb position
    ///     parameter background: The view displayed as the Joystick background
    ///     parameter foreground: The view displayed as the Joystick Thumb Control
    ///     parameter locksInPlace: default false - Determines if the thumb control returns to the center point when released
    ///     parameter lockOneAxis: Determines if the Joystick prevents movement in the X or Y axis
    func joystickGestureRecognizer(thumbPosition: Binding<CGPoint>, monitor: JoystickMonitor, size: CGSize, shape: JoystickShape, locksInPlace locks: Bool = false, lockOneAxis: Bool = false) -> some View {
        modifier(JoystickGestureRecognizer(thumbPosition: thumbPosition, monitor: monitor, size: size, type: shape, locksInPlace: locks, lockOneAxis: lockOneAxis))
    }
    
}
