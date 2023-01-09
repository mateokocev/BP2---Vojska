from flask import Flask, render_template, request
from random import randrange
from graph import pie
import sqlite3 as sql
import mysql.connector

cinovi = ["bojnik","brigadir", "general","narednik","poručnik","pozornik","pukovnik","razvodnik","satnik","skupnik"]
app = Flask(__name__)
                                        # <--------MAIN-------->

global name
name= "Čovječe"


# Get data
def BP_DataRow(sql):
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    return MainKursor.fetchone()

def BP_Update(sql):
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    return "Done"

def BP_DataAll(sql):
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    return MainKursor.fetchall()

def RandomImageGenerator():
    x = str(randrange(5))
    return "/static/img/profPictures/"+x+".png"

def SortTwoDimensionalTuple(lst,reverseType):
    return sorted(lst, key=lambda x: x[-2],reverse= reverseType)

def GetCin(cin,sektor):

    if sektor == "Hrvatska ratna mornarica":
        cin = str(cin) +"_p"

    elif sektor == "Hrvatsko ratno zrakoplovstvo":
        cin = str(cin) +"_z"

    return cin

# Route for handling the login page logic
@app.route('/', methods = ['GET', 'POST'])
def login():
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    krusor = vojska.cursor()
    error = ""

    if request.method == 'POST':

        global name
        global UpisLozinka


        name = request.form['username']
        UpisLozinka = request.form['password']

        krusor.execute("select * from login where md5(concat('"+name+"','"+UpisLozinka+"')) = lozinka;")
                        
        error=""
        if krusor.fetchone() == None:
            error = 'Kriva lozinka pokusaj ponovno!'

        else:
            osoblje=BP_DataRow("select osoblje.ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa from login,osoblje where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"';")
            
            VojskaText = BP_DataAll("select opis from sektor;")
            print(VojskaText)
            global randimg
            randimg = RandomImageGenerator()
            
            print(randimg)
            return render_template('index.html', randimg = randimg , ime = name, VojskaText = VojskaText, cin = osoblje[2])
    
    return render_template('Login.html',error = error)



@app.route('/profile', methods = ['GET', 'POST'])
def profile():
    
    osoblje=BP_DataRow("select osoblje.ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa from login,osoblje where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"';")
    sektor = BP_DataRow("select sektor.naziv from login,osoblje,sektor where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"' and osoblje.prezime='"+UpisLozinka+"' and id_sektor = sektor.id;")



    cin= GetCin(osoblje[2],sektor[0])

    return render_template('profile.html', randimg = randimg, osoblje = osoblje, sektor = sektor, cin = cin)
        


@app.route('/kopnena', methods=['GET', 'POST'])
def kopnenaVojska():
    
    data = BP_DataAll('select naziv,vrsta_ture,date(vrijeme_pocetka),date(vrijeme_kraja) from tura;')
    
    return render_template('testnewdesign.html',data=data,len=len(data))




@app.route('/izmjena', methods = ['GET', 'POST'])
def database():
    item= ""
    selection1=""
    if request.method == 'POST':
        selection1 = request.form['menu1']
        selection2 = request.form['menu2']
        item = BP_DataAll('SHOW COLUMNS  FROM '+str(selection2)+';')
  
       
    
    #SHOW COLUMNS  FROM osoblje;
    tables = BP_DataAll('show TABLES;')
   
    return render_template('edit.html',selection1 = selection1, tables = tables,item=item,tablesLen = len(tables),itemLen = len(item))





@app.route('/informacije/<sektor>/<data>')  #Exception
def informacije (data,sektor):

    if sektor == "Kopnena Vojska":
        SektorId = "1"
    elif sektor == "Ratna Mornarica":
        SektorId = "2"
    elif sektor == "Ratno Zrakoplovstvo":
        SektorId = "3"
    elif sektor == "Vojna Policija":
        SektorId = "4"
    
    osoblje = BP_DataAll("select osoblje.ime,osoblje.prezime,osoblje.cin,osoblje.krvna_grupa from osoblje,osoblje_na_misiji,misija where osoblje.id =osoblje_na_misiji.id_osoblje and  osoblje_na_misiji.id_misija = misija.id and osoblje.id_sektor = "+SektorId+" and  misija.naziv = '"+data+"' ;")
    vozila = BP_DataAll("select vozila.naziv,vozila.vrsta,vozila.ukupna_kolicina,vozila.kapacitet from misija,vozilo_na_misiji,vozila where misija.id = vozilo_na_misiji.id_misija and vozilo_na_misiji.id_vozilo = vozila.id and misija.naziv = '"+data+"';")
    
    
            #troskovi misija
    pie("troskovi","select ( select sum(trosak_misije)from misija), 'Trošak svih misija'from misija where naziv = '"+data+"' union select trosak_misije, naziv from misija where naziv = '"+data+"' ;",fileType="svg")

    Troskovi = BP_DataAll("select ( select sum(trosak_misije)from misija), 'Trošak svih misija'from misija where naziv = '"+data+"' union select trosak_misije, naziv from misija where naziv = '"+data+"' ;")
    
    
            #kolicina osoblja na misiji
    pie("osoblje","select count(*), 'Osoblja na misiji' from osoblje,osoblje_na_misiji,misija where osoblje.id =osoblje_na_misiji.id_osoblje and  osoblje_na_misiji.id_misija = misija.id and osoblje.id_sektor = "+SektorId+" and  misija.naziv = '"+data+"' union select count(id),'Svo osoblje' from osoblje ;select count(id),'Svo osoblje' from osoblje ;",fileType="svg")
            
    Osoblje = BP_DataAll("select count(*), 'Osoblja na misiji' from osoblje,osoblje_na_misiji,misija where osoblje.id =osoblje_na_misiji.id_osoblje and  osoblje_na_misiji.id_misija = misija.id and osoblje.id_sektor = "+SektorId+" and  misija.naziv = '"+data+"' union select count(id),'Svo osoblje' from osoblje ;select count(id),'Svo osoblje' from osoblje ;")

            #kolicina vozila na misiji
    pie("vozila","select sum(ukupna_kolicina), 'vozilo na misiji' from misija,vozilo_na_misiji,vozila where misija.id = vozilo_na_misiji.id_misija and vozilo_na_misiji.id_vozilo = vozila.id and misija.naziv = '"+data+"' union select sum(ukupna_kolicina),'ukupna kolicina svih vozila' from vozila ;",fileType="svg")

    Vozila = BP_DataAll("select sum(ukupna_kolicina), 'vozilo na misiji' from misija,vozilo_na_misiji,vozila where misija.id = vozilo_na_misiji.id_misija and vozilo_na_misiji.id_vozilo = vozila.id and misija.naziv = '"+data+"' union select sum(ukupna_kolicina),'ukupna kolicina svih vozila' from vozila ;")

    return render_template('informacije.html',Vozila = Vozila ,Troskovi = Troskovi, Osoblje = Osoblje, sektor=sektor,data=str(data),Svozila="vozila.svg",Sosoblje="osoblje.svg",Stroskovi="troskovi.svg",osoblje=osoblje,vozila=vozila, len2=len(osoblje),lenVozila = len(vozila),)



@app.route('/<sektor>/<misija>') 
def PrikazTura (misija,sektor):
    
    if sektor == "Kopnena Vojska":
        SektorId = "1)"
    elif sektor == "Ratna Mornarica":
        SektorId = "2"
    elif sektor == "Ratno Zrakoplovstvo":
        SektorId = "3"
    elif sektor == "Vojna Policija":
        SektorId = "4"

    data = BP_DataAll('select naziv,vrsta_ture,date(vrijeme_pocetka),date(vrijeme_kraja) from tura;')
    MisijenaTuri= BP_DataAll("select * from tura,misija where tura.id = misija.id_tura and tura.naziv ='"+misija.replace('%20'," ")+"';")
    MisijenaTuriDatumi= BP_DataAll("select date(misija.vrijeme_pocetka), date(misija.vrijeme_kraja) from tura,misija where tura.id = misija.id_tura and tura.naziv ='"+misija.replace('%20'," ")+"';")
    return render_template('testnewdesign.html',SektorId=SektorId,sektor = sektor,MisijenaTuri=MisijenaTuri,data=data,misija=misija,MisijenaTuriDatumi=MisijenaTuriDatumi,len=len(data),len2=len(MisijenaTuri))


@app.route("/ocjenjivanje/<Stype>", methods = ['GET', 'POST'])  #Exception
def ocjenjivanje(Stype):  

    osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv from osoblje,sektor where osoblje.id_sektor = sektor.id;")
    accountRating = BP_DataRow("select ocjena from osoblje where ime = '"+name+"' and prezime = '"+ UpisLozinka+"';")
    if request.method == 'POST':
        Search = request.form['search']
        
        
        if Search.lower() in cinovi:
            
            osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv  from osoblje,sektor where cin = '"+Search+"';")
            return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    
        

        else:
            osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv  from osoblje,sektor where ime = '"+Search+"';")
            
          
            if osoblje != []:
                return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    
            
            
            else:
                osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv  from osoblje where prezime = '"+Search+"';")
                return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    


    if Stype == 'asc': 
        osoblje= SortTwoDimensionalTuple(osoblje,False)
        

    if Stype == 'desc':
        osoblje= SortTwoDimensionalTuple(osoblje,True)
        
    


    return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    






                            # Errors
@app.errorhandler(505)
def page_not_found(error):
    return render_template('404.html', err = "4o4 error ", note = "programur profesional", desc = "What are you looking for here silly?", ime = name,)



@app.errorhandler(505)  #Exception
def page_not_found(error):  
    return render_template('404.html', err = "PlEaSe ReFrEsH eVeRyThInG", note = error, desc = "brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr",ime=name,)    






if __name__ == "__main__":
    app.run(debug = True)


