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

    var body: some View {
        NavigationView {
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
                                Button(action: {
                                    deleteRoutine(routine)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle()) // Button 스타일을 명확히 지정합니다.
                            }
                            .contentShape(Rectangle()) // 전체 HStack을 터치할 수 있게 지정합니다.
                            .onTapGesture {
                                // 리스트를 눌렀을 때 다른 동작을 하게 하려면 여기서 처리합니다.
                                print("Routine tapped: \(routine.title)")
                            }
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
            .onAppear {
                Task {
                    await viewModel.fetchRoutines()
                }
            }
        }
    }

    func deleteRoutine(_ routine: Routine) {
        Task {
            do {
                try await viewModel.deleteRoutine(routine)
            } catch {
                print("Error deleting routine: \(error)")
            }
        }
    }
}

#Preview {
    RoutineManagementView(viewModel: RoutineViewModel())
}
