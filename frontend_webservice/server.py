from flask import Flask, render_template, request
from random import randrange
from graph import pie
import sqlite3 as sql
import mysql.connector

cinovi = ["bojnik","brigadir", "general","narednik","poručnik","pozornik","pukovnik","razvodnik","satnik","skupnik"]
app = Flask(__name__)
                                        # <--------MAIN-------->

global name
name = "Čovječe"


# Get data
def BP_DataRow(sql):
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    return MainKursor.fetchone()


def BP_Function(sql):
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    
    return MainKursor.fetchall()

def BP_Update(sql):
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    MainKursor = vojska.cursor()
    MainKursor.execute(sql)
    vojska.commit()
    return "Done"

def BP_Insert (array, tablica,maxId): # does not work with date

    sqlTxt="INSERT INTO "+ tablica+" VALUES("+ str(maxId)+","
    for x in array:
        
        if x == int:
            sqlTxt += x
        elif x:
            sqlTxt += "'"+x+"',"

    sqlTxt =sqlTxt[:-1] 
    sqlTxt += ");"

    print(sqlTxt)
    print(sqlTxt)

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
    kurac = BP_Function("SELECT trosak() AS ukupni_trosak FROM DUAL;")
    print(kurac[0][0])
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




@app.route('/izmjena/insert/<tablica>', methods = ['GET', 'POST'])
def database(tablica):
    getData = BP_DataAll("Select * from "+ tablica+" ;")
    getRowLen = len(getData[0])
    error=""
    lokacija = BP_DataAll("select id, naziv from lokacija;")
    tura = BP_DataAll("select id, naziv from tura;")
    maxid = BP_DataRow("select max(id) from "+tablica+" limit 1")  
    if request.method == 'POST':
        
        
            
            if tablica == "osoblje":

                maxid = BP_DataRow("select max(id) from osoblje limit 1")            #STR_TO_DATE("12.12.1991.", "%d.%m.%Y.")

                datum1 = request.form["datum1"]
                datum2 = request.form["datum2"]

                datum1 = datum1.split("-")
                datum2 = datum2.split("-")  


                BP_Update("INSERT INTO osoblje VALUES ("+str(maxid[0]+1)+","+request.form["menu1"]+",'"+request.form["ime"]+"','"+request.form["prezime"]+"','"+request.form["cin"]+"', STR_TO_DATE('"+datum1[2]+"."+datum1[1]+"."+datum1[0]+"', '%d.%m.%Y.'), STR_TO_DATE('"+datum2[2]+"."+datum2[1]+"."+datum2[0]+"', '%d.%m.%Y.'),'"+request.form["status"]+"','"+request.form["krv"]+"',"+request.form["ocjena"]+");")

            if tablica == "vozila":

                polje = []

                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])

                BP_Insert(polje,tablica,maxid[0]+1)
            
            if tablica == "tura":

                        

                polje = []

                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])

                BP_Insert(polje,tablica,maxid[0]+1)

            if tablica == "trening":
                
                polje = []

                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])

                BP_Insert(polje,tablica,maxid[0]+1)

            if tablica == "oprema":
                
                polje = []

                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])

                BP_Insert(polje,tablica,maxid[0]+1)

            if tablica == "misija":
                
                polje = []

                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])

                BP_Insert(polje,tablica,maxid[0]+1)

            if tablica == "lokacija":
                
                polje = []

                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])

                BP_Insert(polje,tablica,maxid[0]+1)
            
            if error != "":                     #dodati kasnije
                error= "Uspjesno Dodano!"
            try:
                print("a")  
            except Exception as e:
                  error=e

    return render_template('izmjena.html',cinovi=cinovi,cinLen= len(cinovi),tablica= tablica,tura = tura,turaLen = len(tura),lokacija=lokacija,lokacijaLen = len(lokacija),getData=getData, getDatalen = len(getData),getRowLen=getRowLen,error=error,maxid=maxid)


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


@app.route("/oprema", methods = ['GET', 'POST'])
def oprema():
    oprema = BP_DataAll("select naziv, vrsta, ukupna_kolicina from oprema")
    opremaLen = len(oprema)

    if request.method == 'POST':
        Search = request.form['search']    
        
        if Search.lower() in oprema:     
            oprema = BP_DataAll("select naziv, vrsta, ukupna_kolicina from oprema where naziv = '"+Search+"';")
            return render_template('oprema.html', oprema = oprema, opremaLen = opremaLen)    

        else:
            oprema = BP_DataAll("select naziv, vrsta, ukupna_kolicina from oprema where vrsta = '"+Search+"';")
            return render_template('oprema.html', oprema = oprema, opremaLen = opremaLen)

    return render_template('oprema.html', oprema = oprema, opremaLen = opremaLen)


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


