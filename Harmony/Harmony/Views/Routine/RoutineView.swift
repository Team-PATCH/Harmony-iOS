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

    var body: some View {
        NavigationView {
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

                    Button(action: {
                        showingManagementView.toggle()
                    }) {
                        Image("routine-edit-icon")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .padding(20)
                .frame(height: 65)
                .background(Color.white)

                Divider()
                    .background(Color.gray3)

                // Completion Rate
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.completionRate == 1.0 {
                        Text("축하 드려요🎉 일과를 모두 완료했어요!")
                            .font(.pretendardMedium(size: 18))
                            .foregroundColor(Color.gray5)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 5)
                    } else {
                        Text("나머지도 힘내서 달성해 봐요!")
                            .font(.pretendardMedium(size: 18))
                            .foregroundColor(Color.gray5)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 5)
                    }
                    
                    Text("\(Int(viewModel.completionRate * 100))% 완료")
                        .font(.pretendardBold(size: 24))
                        .foregroundColor(Color.mainGreen)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    
                    ProgressView(value: viewModel.completionRate)
                        .progressViewStyle(CustomProgressViewStyle())
                }
                .background(Color.white)

                // Routine List
                if viewModel.dailyRoutines.isEmpty {
                    Text("오늘의 일과가 없습니다")
                        .font(.headline)
                        .foregroundColor(Color.gray1)
                        .padding()
                } else {
                    List(viewModel.dailyRoutines) { dailyRoutine in
                        DailyRoutineRow(
                            dailyRoutine: dailyRoutine,
                            routine: viewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
                        )
                        .listRowBackground(Color.gray1)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            selectedDailyRoutine = dailyRoutine
                        }
                    }
                    .listStyle(.plain)
                    .fullScreenCover(item: $selectedDailyRoutine) { dailyRoutine in
                        RoutineDetailView(dailyRoutine: dailyRoutine, viewModel: viewModel)
                    }
                }

                Spacer()

                // Add Button
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
                            .shadow(radius: 2)
                    }
                    .padding()
                    .sheet(isPresented: $showingAddRoutineView, onDismiss: {
                        Task {
                            await viewModel.fetchRoutines()
                            await viewModel.fetchDailyRoutines()
                        }
                    }) {
                        RoutineAddView(viewModel: viewModel)
                    }
                }
            }
            .background(Color.gray1.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingManagementView) {
                 RoutineManagementView(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.fetchRoutines()
                    await viewModel.fetchDailyRoutines()
                }
            }
        }
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray2)
                .frame(height: 17)

            RoundedRectangle(cornerRadius: 10)
                .fill(Color.mainGreen)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * (UIScreen.main.bounds.width - 40), height: 17)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }
}

#Preview {
    RoutineView()
}
