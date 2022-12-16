from flask import Flask, render_template,url_for, request,redirect
from random import randrange
import mysql.connector
#sve=mycursor.fetchmany(size=4) kolicina podataka
#sve=mycursor.fetchone() jedan red 
#sve=mycursor.fetchall() #samo sve uzme... 
app = Flask(__name__)
                                        # <--------MAIN-------->

global name
name= "Čovječe"


# Get data
def BP_DataRow(sql):
    vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    return MainKursor.fetchone()

def BP_DataAll(sql):
    vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    return MainKursor.fetchall()
    

def RandomImageGenerator():
    x= str(randrange(5))
    return "/static/img/profPictures/"+x+".png"





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
            osoblje=BP_DataRow("select osoblje.ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa from login,osoblje where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"';")
            if osoblje[2] != "Razvodnik":
                dozvola = None
            else :
                dozvola = osoblje[2]
            VojskaText = BP_DataAll("select opis from sektor;")
            print(VojskaText)
            global randimg
            randimg = RandomImageGenerator()
            
            print(randimg)
            return render_template('index.html',randimg=randimg,ime=name,VojskaText=VojskaText,cin = dozvola)
    
    return render_template('Login.html')



@app.route('/profile', methods=['GET', 'POST'])
def profile():
    
    osoblje=BP_DataRow("select osoblje.ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa from login,osoblje where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"';")
    sektor = BP_DataRow("select sektor.naziv from login,osoblje,sektor where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"' and osoblje.prezime='"+UpisLozinka+"' and id_sektor = sektor.id;")

  

    if sektor[0]== "Hrvatska ratna mornarica":
        cin = str(osoblje[2]) +"_p"

    elif sektor[0]== "Hrvatsko ratno zrakoplovstvo":
        cin = str(osoblje[2]) +"_z"

    else:
        cin = str(osoblje[2])

    return render_template('profile.html',randimg=randimg,osoblje=osoblje,sektor=sektor,cin=cin)
        


@app.route('/kopnena', methods=['GET', 'POST'])
def kopnenaVojska():
    data = BP_DataAll('select naziv,vrsta_ture,date(vrijeme_pocetka),date(vrijeme_kraja) from tura;')
    
    return render_template('testnewdesign.html',data=data,len=len(data))

@app.route('/database', methods=['GET', 'POST'])
def database():
    if request.method == 'GET':
        status="postano"
    else:
        status="nije postano"
  
   
    return render_template('database.html',status=status)


#@app.route('/kopnena/<data>')  #Exception
def informacije (data):
    misije = BP_DataAll("select misija.naziv,misija.ishod,DATE(misija.vrijeme_pocetka),misija.trosak_misije,DATE(misija.vrijeme_kraja) from tura,misija where tura.id = misija.id_tura;")
    osoblje = BP_DataAll("select osoblje.ime,osoblje.prezime,osoblje.cin,osoblje.krvna_grupa,misija.naziv from osoblje ,osoblje_na_misiji,misija where osoblje.id = osoblje_na_misiji.id_osoblje and misija.id = osoblje_na_misiji.id_misija;")
    return render_template('informacije.html',data=data,misije=misije,len=len(misije),osoblje=osoblje, len2=len(osoblje))





@app.route('/kopnena/<misija>')  #Exception
def KopnenaNew (misija):
    data = BP_DataAll('select naziv,vrsta_ture,date(vrijeme_pocetka),date(vrijeme_kraja) from tura;')
    
    MisijenaTuri= BP_DataAll("select * from tura,misija where tura.id = misija.id_tura and tura.naziv ='"+misija.replace('%20'," ")+"';")
    MisijenaTuriDatumi= BP_DataAll("select date(misija.vrijeme_pocetka), date(misija.vrijeme_kraja) from tura,misija where tura.id = misija.id_tura and tura.naziv ='"+misija.replace('%20'," ")+"';")
    return render_template('testnewdesign.html',MisijenaTuri=MisijenaTuri,data=data,misija=misija,MisijenaTuriDatumi=MisijenaTuriDatumi,len=len(data),len2=len(MisijenaTuri))




                            # Errors
@app.errorhandler(404)
def page_not_found(error):
    return render_template('404.html',err="4o4 error ",note="programur profesional",desc="What are you looking for here silly?",ime=name,)



@app.errorhandler(505)  #Exception
def page_not_found(error):  
    return render_template('404.html',err="PlEaSe ReFrEsH eVeRyThInG",note=error,desc="brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr",ime=name,)    






if __name__ == "__main__":
    app.run(debug=True)


