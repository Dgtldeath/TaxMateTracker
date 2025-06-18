//
//  OnboardingView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/15/25.
//


import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to TaxMate Tracker",
            subtitle: "Your Free Tax Deduction Assistant",
            description: "Track business expenses, mileage, and income for self-employed tax filing. Everything you need for Schedule C is here.",
            imageName: "doc.text.fill",
            gradientColors: [AppTheme.primaryNavy, AppTheme.accentGreen]
        ),
        OnboardingPage(
            title: "AI-Powered Tax Advice",
            subtitle: "Get Instant Deductibility Analysis",
            description: "Ask our AI if any expense is tax deductible. Get professional-level guidance powered by IRS regulations and tax code.",
            imageName: "sparkles",
            gradientColors: [AppTheme.accentGreen, AppTheme.primaryNavy]
        ),
        OnboardingPage(
            title: "Earn & Spend Coins",
            subtitle: "Start with 3 Free AI Analyses",
            description: "Each AI analysis costs 1 coin. Purchase 15 more coins for just $0.99 to keep getting expert tax advice all year long.",
            imageName: "circle.fill",
            gradientColors: [AppTheme.primaryNavy.opacity(0.8), AppTheme.accentGreen.opacity(0.8)]
        )
    ]
    
    var body: some View {
        ZStack {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom page indicators and controls
            VStack {
                Spacer()
                
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Action Buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut) {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                        if currentPage == pages.count - 1 {
                            // Mark onboarding as completed
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                            dismiss()
                        } else {
                            withAnimation(.easeInOut) {
                                currentPage += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(25)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            
            // Dismiss button
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                }
                Spacer()
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: page.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: page.imageName)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // Content
                VStack(spacing: 16) {
                    Text(page.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(page.subtitle)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    Text(page.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let gradientColors: [Color]
}
