import matplotlib.pyplot as plt
import numpy as np
import mysql.connector

def pie(title, mySql, fileName="test", color="winter", fileType="png", font=15):
    
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

       
    for x in range(len(stuff)):
        if stuff[x] == None:
            stuff[x]=0
            
    plt.rc('font', size=2)  
    plt.style.use('_mpl-gallery-nogrid')
    colors = plt.get_cmap(color)(np.linspace(0.2, 0.7, len(stuff)))

  
    fig, ax = plt.subplots()

    ax.pie(stuff, colors=colors, autopct="%1.1f%%", labels=labels, wedgeprops={"linewidth": 1, "edgecolor": "white"})
    ax.legend(loc='lower right')
    
    saveTo = 'static/img/statistics/'
    plt.savefig(saveTo + (title + "." + fileType), dpi=500)
    print("Info:" + str(data))
    


