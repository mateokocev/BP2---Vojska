from flask import Flask, render_template,url_for, request,redirect
import mysql.connector
#sve=mycursor.fetchmany(size=4) kolicina podataka
#sve=mycursor.fetchone() jedan red 
#sve=mycursor.fetchall() #samo sve uzme... 
app = Flask(__name__)
                                        # <--------MAIN-------->

global name
name= "Čovječe"


# Get data
def BP_OSOBLJE(sql):
    vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    return str(MainKursor.fetchone())[2:-3]
    




# Route for handling the login page logic
@app.route('/', methods=['GET', 'POST'])
def login():
    vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    krusor = vojska.cursor()
    error = ""

    if request.method == 'POST':
        global name
        global UpisLozinka
        name = request.form['username']
        UpisLozinka = request.form['password']

        krusor.execute("select * from login where md5(concat('"+name+"','"+UpisLozinka+"')) = lozinka;")
                        
       
        if krusor.fetchone() == None:
            error = 'Kriva lozinka pokusaj ponovno!'

        else:

            kopnenaVojskaText=     BP_OSOBLJE("select opis from sektor where id=1;")
            zrakoplovnaVojskaText= BP_OSOBLJE("select opis from sektor where id=2;")
            pomorskaVojskaText=    BP_OSOBLJE("select opis from sektor where id=3;")
            vojnaPolicija=         BP_OSOBLJE("select opis from sektor where id=4;")
            
            return render_template('index.html',ime=name,kopnenaVojskaText=kopnenaVojskaText,zrakoplovnaVojskaText=zrakoplovnaVojskaText,pomorskaVojskaText=pomorskaVojskaText,vojnaPolicija=vojnaPolicija)
    
    return render_template('Login.html')



@app.route('/profile', methods=['GET', 'POST'])
def profile():
  

    vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    MainKursor = vojska.cursor()
    MainKursor.execute("select osoblje.ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa from login,osoblje where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"';")
    osoblje=MainKursor.fetchone()
    
    

    return render_template('profile.html',osoblje=osoblje)
        


@app.errorhandler(404)
def page_not_found(error):
    return render_template('404.html',err="404 error ",note="programur profesional",desc="What are you looking for here silly?",ime=name,)



@app.errorhandler(505)  #Exception
def page_not_found(error):
    
    return render_template('404.html',err="PlEaSe ReFrEsH eVeRyThInG",note=error,desc="brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr",ime=name,)    

if __name__ == "__main__":
    app.run(debug=True)


