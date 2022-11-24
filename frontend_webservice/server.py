from flask import Flask, render_template
import mysql.connector


# Database
db= mysql.connector.connect(host='localhost',database='formula1',user='root',password='root')
mycursor = db.cursor()
mycursor.execute("show databases")
for i in mycursor:
    print(i)



app = Flask(__name__)


@app.route("/")
def index():
    return render_template('index.html',test=3*23)

if __name__ == "__main__":
    app.run(debug=True)


#