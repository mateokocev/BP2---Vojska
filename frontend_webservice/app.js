const http = require('http')
const fs = require('fs')
const contentDisposition = require('content-disposition')
const port = 3000

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html' })
    fs.readFile('./src/index.html', function(error, data) {
        if (error) {
            res.writeHead(404)
            res.writeHead('Error: File not found')
        } else {
            res.write(data)
        }
        res.end()
    })
})

server.listen(port, function(error) {
    if (error) {
        console.log('Error: ', error)
    } else {
        console.log('Link: ' + 'http://localhost:3000/')
    }

})