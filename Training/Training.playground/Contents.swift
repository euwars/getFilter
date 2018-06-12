import CreateML
import Cocoa

let datasetPath = Bundle.main.path(forResource: "Dataset", ofType: "json")!
let dataTable = try! MLDataTable(contentsOf: URL(fileURLWithPath: datasetPath))
let parameters = MLTextClassifier.ModelParameters(validationData: nil, algorithm: MLTextClassifier.ModelAlgorithmType.crf(revision: 1), language: nil)
let model = try! MLTextClassifier(trainingData: dataTable, textColumn: "text", labelColumn: "label")
let metadata = MLModelMetadata(author: "Farzad Nazifi", shortDescription: "getFilter Spam/Ham classification", version: "2.0")
try! model.write(to: URL(fileURLWithPath: "/Users/farzadnazifi/gits/getFilter/Shared/GetFilterSpamClassification.mlmodel"), metadata: metadata)
