import mysql.connector 



vojska= mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')

MainKursor = vojska.cursor()
MainKursor.execute("select * from sektor;")
data2 = MainKursor.fetchone()

print(data2[1])