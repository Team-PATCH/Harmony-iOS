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
            VStack {
                // Header
                HStack {
                    Text("\(viewModel.currentDateString) 일과")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        showingManagementView.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                .padding()

                // Completion Rate
                VStack(alignment: .leading) {
                    Text("나머지도 힘내서 달성해 봐요!")
                        .foregroundColor(.gray)
                    HStack {
                        Text("\(Int(viewModel.completionRate * 100))% 완료")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                        Spacer()
                    }
                    ProgressView(value: viewModel.completionRate)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                        .padding(.top, 4)
                }
                .padding()

                // Routine List or No Routine Message
                if viewModel.dailyRoutines.isEmpty {
                    Text("오늘의 일과가 없습니다")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.dailyRoutines) { dailyRoutine in
                        HStack {
                            if dailyRoutine.completedPhoto != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.title)
                            }
                            VStack(alignment: .leading) {
                                Text(dailyRoutine.time, style: .time)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(viewModel.routines.first(where: { $0.id == dailyRoutine.routineId })?.title ?? "")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .onTapGesture {
                            selectedDailyRoutine = dailyRoutine
                        }
                    }
                    .listStyle(PlainListStyle())
                    .fullScreenCover(item: $selectedDailyRoutine) { dailyRoutine in
                        RoutineDetailView(dailyRoutine: dailyRoutine, viewModel: viewModel)
                    }
                }

                Spacer()

                // Add Button
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
                .sheet(isPresented: $showingAddRoutineView) {
                    RoutineAddView(viewModel: viewModel)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingManagementView) {
                RoutineManagementView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    RoutineView()
}
