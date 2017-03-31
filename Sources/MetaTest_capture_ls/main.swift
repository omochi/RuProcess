import RuProcess
import RuString

import Foundation

let lsret = String.ru.decode(data: try Process.capture(command: ["ls", "-1"]))

let lslines = lsret.ru.strip().ru.lines().map { $0.ru.strip() }

for (i, x) in lslines.enumerated() {
    print("[\(i)] = \(x)")
}

