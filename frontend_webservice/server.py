from flask import Flask, render_template,url_for, request,redirect
import mysql.connector
#mycursor.execute("select ime_staze from staza;")

#sve=mycursor.fetchmany(size=4) kolicina podataka
#sve=mycursor.fetchone() jedan red 
#sve=mycursor.fetchall() #samo sve uzme... 
app = Flask(__name__)
                                        # <--------MAIN-------->



# Route for handling the login page logic
@app.route('/', methods=['GET', 'POST'])
def login():
    vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    krusor = vojska.cursor()
    error = ""

    if request.method == 'POST':
     
            

        UpisIme = request.form['username']
        UpisLozinka = request.form['password']
        krusor.execute("select * from login where md5(concat('"+UpisIme+"','"+UpisLozinka+"')) = lozinka;")
                        
       
        if krusor.fetchone() == None:
            error = 'Kriva lozinka pokusaj ponovno!'
        else:
            MainKursor = vojska.cursor()

            MainKursor.execute("select opis from sektor where id=1;")
            kopnenaVojskaText= str(MainKursor.fetchone())[2:-4]
   
            MainKursor.execute("select opis from sektor where id=2;")
            zrakoplovnaVojskaText=str(MainKursor.fetchone())[2:-4]

            MainKursor.execute("select opis from sektor where id=3;")
            pomorskaVojskaText=str(MainKursor.fetchone())[2:-4]

            MainKursor.execute("select opis from sektor where id=4;")
            vojnaPolicija=str(MainKursor.fetchone())[2:-4]
            Loggedin=True
            #return redirect('/profile')
            return url_for('index.html',ime=request.form['username'],kopnenaVojskaText=kopnenaVojskaText,zrakoplovnaVojskaText=zrakoplovnaVojskaText,pomorskaVojskaText=pomorskaVojskaText,vojnaPolicija=vojnaPolicija)
    
    return render_template('Login.html')




@app.route('/profile', methods=['GET', 'POST'])
def profile():

    return render_template('profile.html')






if __name__ == "__main__":
    app.run(debug=True)


