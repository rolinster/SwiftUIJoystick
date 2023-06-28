//
//  ExampleUse.swift
//  SwiftUIJoystick
//
//  Created by Michael Ellis on 12/4/21.
//

import SwiftUI
import SwiftUIJoystick

struct ExampleUse: View {
    
    /// For the Custom Joystick example
    @StateObject private var monitor = JoystickMonitor()
    
    
    var body: some View {
        VStack {
            Text("Example easy to customize rectangular Joystick")
            Joystick(monitor: monitor, size: CGSize(width: 120, height: 40))
            Text("Example easy to customize Joystick")
            Joystick(monitor: monitor, size: CGSize(width: 40, height: 120))
            Text("XY Point = (x: \(monitor.xyPoint.x.formattedString), y: \(monitor.xyPoint.y.formattedString))")
                .fixedSize()
            Text("Polar Point = (radians: \(monitor.polarPoint.degrees.formattedString), y: \(monitor.polarPoint.distance.formattedString)")
                .fixedSize()
            
                JoystickBuilder(
                    monitor: monitor,
                    size: CGSize(width: 40, height: 120),
                    shape: .rect,
                    background: {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .overlay(Circle().stroke(Color.black)
                                            .shadow(color: Color.white, radius: 5))
                            
                        }
                    },
                    foreground: {
                        Circle()
                            .fill(RadialGradient(colors: [.white, .gray], center: .center, startRadius: 1, endRadius: 30))
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .shadow(color: Color.white, radius: 5)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .shadow(color: Color.white, radius: 5)
                                    .blur(radius: 1)
                            )
                    },
                    locksInPlace: false, lockOneAxis: false)
        }
    }
}

public extension CGFloat {
    var formattedString: String {
        String(format: "%.2f", self)
    }
}
