//
//  RoutineView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct RoutineView: View {
    @ObservedObject var viewModel = RoutineViewModel()

    var body: some View {
        VStack {
            // Header
            HStack {
                Text("\(viewModel.currentDateString) 일과")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
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
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.mainGreen))
                    .padding(.top, 4)
            }
            .padding()

            // Routine List
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
            }
            .listStyle(PlainListStyle())

            Spacer()

            // Add Button
            Button(action: {
                // Add routine action
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
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("일과", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.black)
            }
        }
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineView()
    }
}

#Preview {
    RoutineView()
}
