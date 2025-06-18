//
//  AddEntryView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI

struct AddEntryView: View {
    @State private var showingIncomeSheet = false
    @State private var showingExpenseSheet = false
    @State private var animateButtons = false
    @State private var animateBackground = false
    
    var body: some View {
        
            ZStack {
                // Animated Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.primaryNavy.opacity(0.1),
                        AppTheme.accentGreen.opacity(0.05),
                        AppTheme.primaryNavy.opacity(0.1)
                    ]),
                    startPoint: animateBackground ? .topLeading : .bottomTrailing,
                    endPoint: animateBackground ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .animation(
                    Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                    value: animateBackground
                )
                
                Group {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        addEntryViewContent
                            .navigationTitle("Add Entry")
                    }
                    else {
                        NavigationView {
                            addEntryViewContent
                                .navigationTitle("Add Entry")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
                
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    animateButtons = true
                }
                withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                    animateBackground = true
                }
            }
            .sheet(isPresented: $showingIncomeSheet) {
                AddIncomeFormView()
            }
            .sheet(isPresented: $showingExpenseSheet) {
                AddExpenseFormView()
            }
        
    }
    
    @ViewBuilder
    private var addEntryViewContent : some View {
        ScrollView {
            VStack(spacing: 40) {
                // Header Section
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.accentGreen, AppTheme.primaryNavy],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animateButtons ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: animateButtons
                        )
                    
                    Text("Add Financial Entry")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.primaryNavy)
                    
                    Text("Track your business income and expenses for tax deductions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(animateButtons ? 1 : 0)
                .offset(y: animateButtons ? 0 : -20)
                
                // Action Buttons
                VStack(spacing: 24) {
                    // Add Income Button
                    Button(action: {
                        impactFeedback()
                        showingIncomeSheet = true
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentGreen.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.accentGreen)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Add Side Income")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Freelance work, consulting, gig economy")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(AppTheme.accentGreen)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: AppTheme.accentGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppTheme.accentGreen.opacity(0.5), AppTheme.accentGreen.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PressedButtonStyle())
                    .scaleEffect(animateButtons ? 1 : 0.8)
                    .opacity(animateButtons ? 1 : 0)
                    
                    // Add Expense Button
                    Button(action: {
                        impactFeedback()
                        showingExpenseSheet = true
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Add Business Expense")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Office supplies, software, business meals")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.5), Color.red.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PressedButtonStyle())
                    .scaleEffect(animateButtons ? 1 : 0.8)
                    .opacity(animateButtons ? 1 : 0)
                }
                .padding(.horizontal, 20)
                
                // Quick Stats or Tips Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                            .font(.title3)
                        
                        Text("Pro Tips")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        TipRowView(
                            icon: "camera.fill",
                            tip: "Always capture receipts for business expenses",
                            color: .blue
                        )
                        
                        TipRowView(
                            icon: "calendar",
                            tip: "Log expenses as they happen for better accuracy",
                            color: .purple
                        )
                        
                        TipRowView(
                            icon: "sparkles",
                            tip: "Use AI analysis to check if expenses are deductible",
                            color: AppTheme.accentGreen
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .scaleEffect(animateButtons ? 1 : 0.9)
                .opacity(animateButtons ? 1 : 0)
                
                Spacer(minLength: 50)
            }
            .padding(.top, 20)
        }
    }
    
    private func impactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Custom Button Style
struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Tip Row Component
struct TipRowView: View {
    let icon: String
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Floating Action Buttons (Alternative approach)
struct FloatingActionButtons: View {
    let onIncomeAction: () -> Void
    let onExpenseAction: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Income FAB
            Button(action: onIncomeAction) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Income")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(AppTheme.accentGreen)
                        .shadow(color: AppTheme.accentGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(PressedButtonStyle())
            
            // Expense FAB
            Button(action: onExpenseAction) {
                HStack(spacing: 8) {
                    Image(systemName: "minus.circle.fill")
                    Text("Expense")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.red)
                        .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(PressedButtonStyle())
        }
    }
}
