//
//  HomeView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var routineViewModel = RoutineViewModel()
    @State private var isShowingMemoryCardCreate = false
    @State private var isShowingMemoryCardView = false
    @State private var selectedDailyRoutine: DailyRoutine?
    @State private var hasMemoryCard: Bool = false // 추억카드 존재 여부 상태 추가
    @State private var memoryCardImage: UIImage? // 추억카드 이미지
    @State private var isShowingRoutineAdd = false // 새로운 일과 추가 여부 상태 추가
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    if hasMemoryCard {
                        // 추억카드가 있을 때
                        VStack(alignment: .center, spacing: 20) {
                            Text("오늘의 ")
                                .font(.pretendardBold(size: 24)) +
                            Text("추억카드가 ")
                                .font(.pretendardBold(size: 24))
                                .foregroundColor(.mainGreen) +
                            Text(UserDefaultsManager.shared.isVIP() ? "도착했어요!" : "공유됐어요!")
                                .font(.pretendardBold(size: 24))
                            Text("어떤 추억인지 확인해 볼까요?")
                                .font(.pretendardMedium(size: 18))
                                .foregroundColor(.gray4)
                            ZStack(alignment: .topTrailing) {
                                if let image = memoryCardImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 200)
                                        .onTapGesture {
                                            isShowingMemoryCardView = true
                                        }
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray1)
                    } else {
                        // 추억카드가 없을 때
                        if UserDefaultsManager.shared.isMember() {
                            VStack(alignment: .center, spacing: 20) {
                                Text("할머니의 ")
                                    .font(.pretendardBold(size: 24)) +
                                Text("추억을 ")
                                    .font(.pretendardBold(size: 24))
                                    .foregroundColor(.mainGreen) +
                                Text("들어볼까요?")
                                    .font(.pretendardBold(size: 24))
                                Text("아래를 클릭해 카드를 보내드려요.")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(.gray4)
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray1)
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                                .foregroundColor(Color.gray3)
                                        )
                                    
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray3)
                                }
                                .onTapGesture {
                                    isShowingMemoryCardCreate = true
                                }
                            }
                            .padding()
                            .background(Color.gray1)
                        } else {
                            VStack(alignment: .center, spacing: 20) {
                                Image("letter-box")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                Text("오늘의 ")
                                    .font(.pretendardBold(size: 24)) +
                                Text("추억카드가 ")
                                    .font(.pretendardBold(size: 24))
                                    .foregroundColor(.mainGreen) +
                                Text("아직 없어요.")
                                    .font(.pretendardBold(size: 24))
                                Text("새로운 추억카드를 기다려보아요.")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(.gray4)
                            }
                            .padding()
                            .background(Color.gray1)
                        }
                    }
                    
                    VStack(alignment: .center, spacing: 10) {
                        HStack {
                            Text(currentDate())
                                .font(.pretendardMedium(size: 22))
                                .foregroundColor(Color.mainGreen)
                            Text("의 일과")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                            Spacer() // HStack의 모든 요소를 왼쪽으로 정렬
                        }
                        
                        VStack(alignment: .leading) {
                            Text("나머지도 힘내서 달성해 봐요!")
                                .foregroundColor(.gray)
                            HStack {
                                Text("\(Int(routineViewModel.completionRate * 100))% 완료")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            CustomProgressView(value: routineViewModel.completionRate)
                        }
                        .padding(.vertical)
                        
                        if routineViewModel.dailyRoutines.isEmpty {
                            VStack(alignment: .center, spacing: 20) {
                                Text("아직 일과가 없어요.")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(.gray4)
                                Text("새로운 일과를 만들어 볼까요?")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(.gray4)
                                Button(action: {
                                    isShowingRoutineAdd = true
                                }) {
                                    Text("일과 만들러 가기")
                                        .font(.pretendardSemiBold(size: 20))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.mainGreen)
                                        .cornerRadius(999)
                                }
                            }
                            .padding()
                        } else {
                            ForEach(routineViewModel.dailyRoutines.prefix(4)) { dailyRoutine in
                                DailyRoutineRow(
                                    dailyRoutine: dailyRoutine,
                                    routine: routineViewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
                                )
                                .onTapGesture {
                                    selectedDailyRoutine = dailyRoutine
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                }
            }
            .background(Color.gray1.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("harmony-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .foregroundColor(.black)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            UINavigationBar.appearance().backgroundColor = .white
            if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .onAppear {
            UINavigationBar.appearance().backgroundColor = .white
        }
        .sheet(isPresented: $isShowingMemoryCardCreate) {
            MemoryCardCreateView(isPresented: $isShowingMemoryCardCreate)
        }
        .fullScreenCover(item: $selectedDailyRoutine) { dailyRoutine in
            RoutineDetailView(dailyRoutine: dailyRoutine, viewModel: routineViewModel)
        }
        .fullScreenCover(isPresented: $isShowingRoutineAdd) { // 새로운 일과 추가 화면으로 이동
            RoutineAddView(viewModel: routineViewModel)
        }
        .onAppear {
            Task {
                await routineViewModel.fetchRoutines()
                await routineViewModel.fetchDailyRoutines()
            }
            checkMemoryCardStatus() // 추억카드 상태 확인
        }
    }
    
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: Date())
    }
    
    private func checkMemoryCardStatus() {
        // 실제 추억카드 상태 확인 로직으로 대체 필요
        // 예시: 추억카드가 없는 상태로 설정
        hasMemoryCard = false
        memoryCardImage = nil // 추억카드 이미지 초기화
        
        // 예시: 추억카드가 있을 경우
        // hasMemoryCard = true
        // memoryCardImage = UIImage(named: "sampleImage") // 실제 추억카드 이미지로 변경
    }
}

struct CustomProgressView: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray2)
                    .frame(height: 17)
                Rectangle()
                    .fill(Color.mainGreen)
                    .frame(width: CGFloat(value) * geometry.size.width, height: 17)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(height: 17)
    }
}

#Preview {
    HomeView()
}




