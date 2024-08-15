//
//  RoutineView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//


import SwiftUI

struct RoutineView: View {
    @ObservedObject var viewModel = RoutineViewModel()
    @State private var showingAddRoutineView = false
    @State private var showingManagementView = false
    @State private var selectedDailyRoutine: DailyRoutine?
    @State private var headerAppear = false
    @State private var completionRateAppear = false
    @State private var routineListAppear = false
    @State private var addButtonAppear = false
    
    init() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(Color.wh)
        navBarAppearance.shadowColor = UIColor.gray
        navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 24)]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("\(viewModel.currentDateString)")
                            .font(.pretendardBold(size: 22))
                            .foregroundColor(Color.black)
                        
                        Text("일과")
                            .font(.pretendardBold(size: 22))
                            .foregroundColor(Color.mainGreen)
                        
                        Spacer()
                        
                        NavigationLink(destination: RoutineManagementView(viewModel: viewModel)) {
                            Image("routine-edit-icon")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(20)
                    .frame(height: 65)
                    .background(Color.white)
                    .opacity(headerAppear ? 1 : 0)
                    .offset(y: headerAppear ? 0 : -20)
                    .animation(.easeOut(duration: 0.5), value: headerAppear)
                    
                    Divider()
                        .background(Color.gray3)
                    
                    // Completion Rate
                    VStack(alignment: .leading, spacing: 0) {
                        Group {
                            if viewModel.completionRate == 1.0 {
                                Text("축하 드려요🎉 일과를 모두 완료했어요!")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(Color.gray5)
                            } else if viewModel.completionRate == 0 {
                                Text("오늘도 힘차게 시작해 볼까요?")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(Color.gray5)
                            } else {
                                Text("나머지도 힘내서 달성해 봐요!")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(Color.gray5)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                        
                        Text("\(Int(viewModel.completionRate * 100))% 완료")
                            .font(.pretendardBold(size: 24))
                            .foregroundColor(Color.mainGreen)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        
                        ProgressView(value: viewModel.completionRate)
                            .progressViewStyle(CustomProgressViewStyle())
                    }
                    .background(Color.white)
                    .padding(.bottom, 10)
                    .opacity(completionRateAppear ? 1 : 0)
                    .offset(y: completionRateAppear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: completionRateAppear)
                    
                    // Routine List
                    if viewModel.dailyRoutines.isEmpty {
                        Text("오늘의 일과가 없습니다")
                            .font(.headline)
                            .foregroundColor(Color.gray1)
                            .padding()
                            .opacity(routineListAppear ? 1 : 0)
                            .offset(y: routineListAppear ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.4), value: routineListAppear)
                    } else {
                        List {
                            ForEach(viewModel.dailyRoutines) { dailyRoutine in
                                DailyRoutineRow(
                                    dailyRoutine: dailyRoutine,
                                    routine: viewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
                                )
                                .listRowBackground(Color.gray1)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    selectedDailyRoutine = dailyRoutine
                                }
                            }
                        }
                        .listStyle(.plain)
                        .opacity(routineListAppear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: routineListAppear)
                        .fullScreenCover(item: $selectedDailyRoutine) { dailyRoutine in
                            RoutineDetailView(dailyRoutine: dailyRoutine, viewModel: viewModel)
                        }
                    }
                    
                    Spacer()
                }
                .background(Color.gray1.edgesIgnoringSafeArea(.all))
                .onAppear {
                    Task {
                        await viewModel.fetchRoutines()
                        await viewModel.fetchDailyRoutines()
                    }
                    animateView()
                }
                
                // Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddRoutineView.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .clipShape(Circle())
                                .scaleEffect(addButtonAppear ? 1 : 0.5)
                                .opacity(addButtonAppear ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.6), value: addButtonAppear)
                        }
                        .padding()
                        .fullScreenCover(isPresented: $showingAddRoutineView, onDismiss: {
                            Task {
                                await viewModel.fetchRoutines()
                                await viewModel.fetchDailyRoutines()
                            }
                        }) {
                            RoutineAddView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
    }
    
    private func animateView() {
        withAnimation(.easeOut(duration: 0.5)) {
            headerAppear = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                completionRateAppear = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                routineListAppear = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                addButtonAppear = true
            }
        }
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    @State private var animationProgress: CGFloat = 0
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray1)
                .frame(height: 17)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray2, lineWidth: 1)
                )
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.mainGreen)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * (UIScreen.main.bounds.width - 40) * animationProgress, height: 16)
                .animation(.spring(response: 1, dampingFraction: 0.8).delay(0.3), value: animationProgress)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
        .onAppear {
            withAnimation(.spring(response: 1, dampingFraction: 0.8).delay(0.3)) {
                animationProgress = 1
            }
        }
    }
}

#Preview {
    RoutineView()
}

