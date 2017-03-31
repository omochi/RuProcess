import RuProcess
import RuString

let lsret = try Process.capture(command: ["ls", "-1"])
for (i, x) in lsret.split(separator: "\n").enumerated() {
    print("[\(i)] = \(x)")
}
