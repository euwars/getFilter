import Kitura

do {
    let gf = try GetFilter()
    let server = Kitura.addHTTPServer(onPort: 8080, with: gf.router)
    print("Running")
    Kitura.run()
} catch let err {
    print(err)
}
