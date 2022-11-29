from flask import Flask, render_template,url_for, request,redirect
import mysql.connector


# Database
#db= mysql.connector.connect(host='localhost',database='formula1',user='root',password='root')
#mycursor = db.cursor()

#mycursor.execute("select ime_staze from staza;")


#sve=mycursor.fetchmany(size=4) kolicina podataka

#sve=mycursor.fetchone() jedan red 

#sve=mycursor.fetchall() #samo sve uzme... 



app = Flask(__name__)

@app.route("/sauhdkuahsghdi7123z479123hj1jksdhusihadjkhsdfgliohjerofhj3489o5z923475z83475h") #for safety reasons tottaly not hackable
def index():
    return render_template('index.html',test=123*123)

@app.route("/kopnenaVojska/")
def KopnenaVojska():
    return render_template('kopnenaVojska.html')






                # login connecting to DataBase vojska
vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
krusor = vojska.cursor()





# Route for handling the login page logic
@app.route('/', methods=['GET', 'POST'])
def login():
    error = ""
    if request.method == 'POST':
        UpisIme=request.form['username']
        UpisLozinka=request.form['password']


        krusor.execute("select * from login where ime= '"+UpisIme+"' and md5('"+UpisLozinka+"') = lozinka;")
       
        if krusor.fetchone() == None:
            error = 'Kriva lozinka pokusaj ponovno!'
        else:
            return redirect(url_for('index'))
    return render_template('login.html', error=error)

if __name__ == "__main__":
    app.run(debug=True)


