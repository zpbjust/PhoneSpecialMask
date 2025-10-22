//
//  WelcomeView.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showWelcome = true
    @State private var animateIcon = false
    @State private var animateText = false
    @State private var animateButton = false
    
    var body: some View {
        if showWelcome {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        .black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated Background Elements
                GeometryReader { geometry in
                    ForEach(0..<8) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.1),
                                        Color.purple.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: CGFloat.random(in: 100...200))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .blur(radius: 50)
                    }
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Icon
                    ZStack {
                        // Glow Effect
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                            .scaleEffect(animateIcon ? 1.2 : 1.0)
                        
                        // Icon Background
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.3, blue: 0.8),
                                        Color(red: 0.2, green: 0.1, blue: 0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        // Icon Content
                        Image(systemName: "sparkles")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(animateIcon ? 360 : 0))
                    }
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .opacity(animateIcon ? 1.0 : 0.0)
                    
                    // App Name
                    VStack(spacing: 12) {
                        Text("Special Phone Mask")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(animateText ? 1.0 : 0.0)
                            .offset(y: animateText ? 0 : 20)
                        
                        Text("让锁屏更简洁美观")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(animateText ? 1.0 : 0.0)
                            .offset(y: animateText ? 0 : 20)
                    }
                    
                    Spacer()
                    
                    // Features
                    VStack(spacing: 20) {
                        FeatureRow(icon: "photo.stack.fill", title: "16 张精选壁纸", description: "直接使用")
                        FeatureRow(icon: "face.smiling.fill", title: "9 套创意贴纸", description: "自由搭配")
                        FeatureRow(icon: "wand.and.stars", title: "轻松定制", description: "简单操作")
                    }
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 30)
                    
                    Spacer()
                    
                    // Start Button
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showWelcome = false
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text("开始使用")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.4, blue: 1.0),
                                    Color(red: 0.5, green: 0.2, blue: 0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                    .scaleEffect(animateButton ? 1.0 : 0.8)
                    .opacity(animateButton ? 1.0 : 0.0)
                }
            }
            .onAppear {
                // Animate icon
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                    animateIcon = true
                }
                
                // Animate text
                withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                    animateText = true
                }
                
                // Animate button
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.0)) {
                    animateButton = true
                }
                
            }
            .transition(.opacity)
        } else {
            HomeView()
                .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    WelcomeView()
}

