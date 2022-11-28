from flask import Flask, render_template,url_for, request,redirect
import mysql.connector


# Database
db= mysql.connector.connect(host='localhost',database='formula1',user='root',password='root')
mycursor = db.cursor()

#mycursor.execute("Select isplacen_novac from sponzor_u_sezoni")
#cijene=mycursor.fetchall()
mycursor.execute("select ime_staze from staza;")


#sve=mycursor.fetchmany(size=4) kolicina podataka

#sve=mycursor.fetchone() jedan red 

sve=mycursor.fetchall() #samo sve uzme... 
app = Flask(__name__)


@app.route("/")
def index():
    return render_template('index.html',test=123*123)

@app.route("/kopnenaVojska/")
def KopnenaVojska():
    return render_template('kopnenaVojska.html',sve=sve)



# Route for handling the login page logic
@app.route('/login/', methods=['GET', 'POST'])
def login():
    error = ""
    if request.method == 'POST':
        if request.form['username'] != 'admin' or request.form['password'] != 'admin':
            error = 'Invalid Credentials. Please try again.'
        else:
            return  "letss gooo" #redirect(url_for('index'))
    return render_template('login.html', error=error)

if __name__ == "__main__":
    app.run(debug=True)


