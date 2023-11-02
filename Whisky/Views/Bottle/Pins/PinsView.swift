//
//  PinsView.swift
//  Whisky
//
//  This file is part of Whisky.
//
//  Whisky is free software: you can redistribute it and/or modify it under the terms
//  of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Whisky is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with Whisky.
//  If not, see https://www.gnu.org/licenses/.
//

import SwiftUI
import WhiskyKit

struct PinsView: View {
    var bottle: Bottle
    @State var pin: PinnedProgram
    @State var program: Program?
    @State var image: NSImage?
    @State var showRenameSheet = false
    @State var name: String = ""
    @State var opening: Bool = false
    @Binding var loadStartMenu: Bool
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Group {
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                } else {
                    Image(systemName: "app.dashed")
                        .resizable()
                }
            }
            .frame(width: 45, height: 45)
            .scaleEffect(opening ? 2 : 1)
            .opacity(opening ? 0 : 1)
            Spacer()
            Text(name + "\n")
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 90, height: 90)
        .padding(10)
        .overlay {
            HStack {
                Spacer()
                Image(systemName: "play.fill")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 16, height: 16)
            }
            .frame(width: 45, height: 45)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
        }
        .contextMenu {
            Button("button.run") {
                runProgram()
            }
            Divider()
            Button("program.config") {
                if let program {
                    path.append(program)
                }
            }
            Divider()
            Button("button.rename") {
                showRenameSheet.toggle()
            }
            Button("pin.unpin") {
                bottle.settings.pins.removeAll(where: { $0.url == pin.url })
                for program in bottle.programs where program.url == pin.url {
                    program.pinned = false
                }
                loadStartMenu.toggle()
            }
        }
        .onTapGesture(count: 2) {
            runProgram()
        }
        .sheet(isPresented: $showRenameSheet) {
            PinRenameView(name: $name)
        }
        .onAppear {
            name = pin.name
            Task.detached {
                program = bottle.programs.first(where: { $0.url == pin.url })
                if let program {
                    if let peFile = program.peFile {
                        image = peFile.bestIcon()
                    }
                }
            }
        }
        .onChange(of: name) {
            if let index = bottle.settings.pins.firstIndex(where: { $0.url == pin.url }) {
                bottle.settings.pins[index].name = name
            }
        }
    }

    func runProgram() {
        withAnimation(.easeIn(duration: 0.25)) {
            opening = true
        } completion: {
            withAnimation(.easeOut(duration: 0.1)) {
                opening = false
            }
        }

        if let program {
            Task {
                await program.run()
            }
        }
    }
}