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
                                        # <--------MAIN-------->


@app.route("/kopnenaVojska/")
def KopnenaVojska():
    return render_template('kopnenaVojska.html',)

test=""

# Route for handling the login page logic
@app.route('/sad', methods=['GET', 'POST'])
def login():
    vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    krusor = vojska.cursor()
    error = ""
    if request.method == 'POST':
        UpisIme = request.form['username']
        UpisLozinka = request.form['password']
        krusor.execute("select * from login where ime= '"+UpisIme+"' and md5('"+UpisLozinka+"') = lozinka;")
       
        if krusor.fetchone() == None:
            error = 'Kriva lozinka pokusaj ponovno!'
        else:

            Main= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
            MainKursor = Main.cursor()

            MainKursor.execute("select opis from sektor where id=1;")
            kopnenaVojskaText= str(MainKursor.fetchone())[2:-4]
   
            MainKursor.execute("select opis from sektor where id=2;")
            zrakoplovnaVojskaText=str(MainKursor.fetchone())[2:-4]

            MainKursor.execute("select opis from sektor where id=3;")
            pomorskaVojskaText=str(MainKursor.fetchone())[2:-4]

            MainKursor.execute("select opis from sektor where id=4;")
            vojnaPolicija=str(MainKursor.fetchone())[2:-4]

            return render_template('index.html',ime=request.form['username'],kopnenaVojskaText=kopnenaVojskaText,zrakoplovnaVojskaText=zrakoplovnaVojskaText,pomorskaVojskaText=pomorskaVojskaText,vojnaPolicija=vojnaPolicija)
    
            
    return render_template('login.html', error=error)





@app.route("/sauhdkuahsghdi7123z479123hj1jksdhusihadjkhsdfgliohjerofhj3489o5z923475z83475h") #for safety reasons tottaly not hackable
def index(methods=['kopnena']):
   
    Main= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    MainKursor = Main.cursor()

    MainKursor.execute("select opis from sektor where id=1;")
    kopnenaVojskaText= str(MainKursor.fetchone())[2:-4]
   
    MainKursor.execute("select opis from sektor where id=2;")
    zrakoplovnaVojskaText=str(MainKursor.fetchone())[2:-4]

    MainKursor.execute("select opis from sektor where id=3;")
    pomorskaVojskaText=str(MainKursor.fetchone())[2:-4]

    MainKursor.execute("select opis from sektor where id=4;")
    vojnaPolicija=str(MainKursor.fetchone())[2:-4]

    return render_template('index.html',ime="neznam",kopnenaVojskaText=kopnenaVojskaText,zrakoplovnaVojskaText=zrakoplovnaVojskaText,pomorskaVojskaText=pomorskaVojskaText,vojnaPolicija=vojnaPolicija)



@app.route('/', methods=['GET', 'POST'])
def profile():

    return render_template('profile.html')

if __name__ == "__main__":
    app.run(debug=True)


