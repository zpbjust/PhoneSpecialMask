//
//  VisualEffects.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI

// MARK: - Glass Morphism Effect
struct GlassMorphism: ViewModifier {
    var tint: Color = .white
    var opacity: Double = 0.1
    var blurRadius: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    tint.opacity(opacity)
                    
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                }
            )
    }
}

extension View {
    func glassMorphism(
        tint: Color = .white,
        opacity: Double = 0.1,
        blurRadius: CGFloat = 10
    ) -> some View {
        modifier(GlassMorphism(tint: tint, opacity: opacity, blurRadius: blurRadius))
    }
}

// MARK: - Visual Effect Blur
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 2)
                            .repeatForever(autoreverses: false)
                        ) {
                            phase = 1
                        }
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Bounce Animation
extension View {
    func bounceAnimation() -> some View {
        self.modifier(BounceAnimation())
    }
}

struct BounceAnimation: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = pressing
                }
            }, perform: { })
    }
}

// MARK: - Floating Animation
struct FloatingAnimation: ViewModifier {
    @State private var isFloating = false
    let amplitude: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -amplitude : amplitude)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    isFloating.toggle()
                }
            }
    }
}

extension View {
    func floating(amplitude: CGFloat = 10, duration: Double = 2) -> some View {
        modifier(FloatingAnimation(amplitude: amplitude, duration: duration))
    }
}

