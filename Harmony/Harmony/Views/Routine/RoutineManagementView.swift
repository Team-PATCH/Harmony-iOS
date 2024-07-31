//
//  RoutineManagementView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct RoutineManagementView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @State private var showingAddRoutineView = false
    @State private var showingEditRoutineView = false
    @State private var selectedRoutine: Routine?

    var body: some View {
        VStack {
            if viewModel.routines.isEmpty {
                Text("아직 일과가 없습니다.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.routines) { routine in
                        HStack {
                            Image(systemName: "rectangle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .background(Color.gray)
                                .cornerRadius(8)
                                .padding(.trailing, 8)
                            VStack(alignment: .leading) {
                                Text(routine.title)
                                    .font(.headline)
                                Text("\(viewModel.daysAsString(for: routine)) / \(routine.time)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Menu {
                                Button(action: {
                                    selectedRoutine = routine
                                    showingEditRoutineView = true
                                }) {
                                    Text("일과 수정")
                                }
                                Button(action: {
                                    Task {
                                        await deleteRoutine(routine)
                                    }
                                }) {
                                    Text("일과 삭제")
                                        .foregroundColor(.red)
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            .buttonStyle(PlainButtonStyle()) // Button 스타일을 명확히 지정합니다.
                        }
                        .contentShape(Rectangle()) // 전체 HStack을 터치할 수 있게 지정합니다.
                    }
                }
                .listStyle(PlainListStyle())
            }

            Spacer()

            Button(action: {
                showingAddRoutineView.toggle()
            }) {
                Text("+ 추가하기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
            }
            .sheet(isPresented: $showingAddRoutineView, onDismiss: {
                Task {
                    await viewModel.fetchRoutines()
                    await viewModel.fetchDailyRoutines()
                }
            }) {
                RoutineAddView(viewModel: viewModel)
            }
        }
        .navigationBarTitle("일과 관리", displayMode: .inline)
        .sheet(item: $selectedRoutine) { routine in
            RoutineEditView(viewModel: viewModel, routine: routine)
        }
        .onAppear {
            Task {
                await viewModel.fetchRoutines()
            }
        }
    }

    func deleteRoutine(_ routine: Routine) async {
        do {
            try await viewModel.deleteRoutine(routine)
        } catch {
            print("Error deleting routine: \(error)")
        }
    }
}

#Preview {
    RoutineManagementView(viewModel: RoutineViewModel())
}
