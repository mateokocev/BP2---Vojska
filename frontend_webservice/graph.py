import matplotlib.pyplot as plt
import numpy as np
import mysql.connector
#getting data from Database
from threading import Thread



def pie(title, mySql, fileName="test", color="winter", fileType="png", font=15):
    #sql stuff
    vojska = mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    MainKursor = vojska.cursor()
    MainKursor.execute(mySql)
    data = MainKursor.fetchall()

    MainKursor.close()
    nummberItems = len(data)
    labels = []
    stuff = []
    for x in range(nummberItems):
        stuff.append(data[x][0])
        labels.append(data[x][1])

    plt.rc('font', size=2)  
    plt.style.use('_mpl-gallery-nogrid')
    colors = plt.get_cmap(color)(np.linspace(0.2, 0.7, len(stuff)))

    # Create a new figure
    fig, ax = plt.subplots()

    ax.pie(stuff, colors=colors, autopct="%1.1f%%", labels=labels, wedgeprops={"linewidth": 1, "edgecolor": "white"})
    ax.legend(loc='lower right')
    # Save the figure
    saveTo = 'static/img/statistics/'
    plt.savefig(saveTo + (title + "." + fileType), dpi=500)
    print("Info:" + str(data))
    
    


    # prosjek imena
#pie("imena","select count(*),ime from osoblje where ime = 'Ela' union  select count(*),ime from osoblje where ime = 'Ivan';",fileType="svg")

    # cinovi
#pie("cinovi","select SUM(cin='Razvodnik') as razvodnik ,'Razvodnik' from osoblje union select SUM(cin='Pozornik') as Pozornik,'Pozornik' from osoblje union select SUM(cin='Skupnik') as Pozornik,'Skupnik' from osoblje union select SUM(cin='narednik') as Pozornik,'narednik' from osoblje union select SUM(cin='poručnik') as Pozornik,'poručnik' from osoblje union select SUM(cin='satnik') as Pozornik,'satnik' from osoblje union select SUM(cin='bojnik') as Pozornik,'bojnik' from osoblje union select SUM(cin='pukovnik') as Pozornik,'pukovnik' from osoblje union select SUM(cin='brigadir') as Pozornik,'brigadir' from osoblje;",fileType="svg")

    # kolicina ljudi po sektoru
#pie("ljudiPoSektoru","select count(*),sektor.naziv from osoblje,sektor where osoblje.id_sektor = sektor.id and sektor.naziv ='Hrvatska kopnena vojska' union (select count(*),sektor.naziv from osoblje,sektor where osoblje.id_sektor = sektor.id and sektor.naziv ='Hrvatska ratna mornarica') union (select count(*),sektor.naziv from osoblje,sektor where osoblje.id_sektor = sektor.id and sektor.naziv ='Hrvatsko ratno zrakoplovstvo') union (select count(*),sektor.naziv from osoblje,sektor where osoblje.id_sektor = sektor.id and sektor.naziv ='Hrvatska vojna policija');",fileType="svg")

    # status osoblja
#pie("Status_osoblja","select SUM(status_osoblja='Mrtav'),'Mrtav' from osoblje union select SUM(status_osoblja='Neaktivan'),'Neaktivan'from osoblje union select SUM(status_osoblja='Umirovljen'), 'Umirovljen' from osoblje union select SUM(status_osoblja='Aktivan'), 'Aktivan' from osoblje;",fileType="svg")




