import SwiftUI

struct RequestsButtonView: View {
    let requestsCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                if requestsCount > 0 {
                    Text("\(requestsCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 5, y: -5)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        RequestsButtonView(requestsCount: 3, action: {})
    }
}

