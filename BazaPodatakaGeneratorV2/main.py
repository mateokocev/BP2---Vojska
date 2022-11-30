import random
from imena import ime, prezime
# variables
custom1 = []
custom2 = []
custom3 = []
custom4 = []
custom5 = []
#functions
def randname():
    return random.choice(ime)
def randprezime():
    return random.choice(prezime)

def randbool():
    x = random.randint(0, 1)
    if x == 0:
        return False
    else:
        return True


def RandNumb(brFrom, brTo):
    return random.randint(brFrom, brTo)


def Customrandname(custom=[]):
    return random.choice(custom)

         
def Date(addTime=True, addDate=False,god1=2,god2=2):
  
  vrijeme = str( random.randint( 1, 24 )) + ":" + str( random.randint( 0, 60 )) + ":" + str(random.randint( 0, 60 ))
  datum = str(random.randint( 1, 28 ))+ "." + str(random.randint( 1, 12 )) +"."+str(random.randint( god1, god2 ))+"." 

  if addTime and not addDate:
      return vrijeme
    
  elif not addTime and addDate:
      return datum

  elif addDate and addTime:
      return datum + "  " + vrijeme
  return "greska"







print("Dostupni atributi: \n [id] [ime] [prezime] \n [datum[(max 2)]] [customname[(max 5)]] [bool] \n [randnum[(max 5)]] [foreignkey[nummber] umirovljen \n Exmaple: id ime date2 customname4")

lista = list(map(str, input().split()))
for x in lista:
        #<---------custom commands---------------------->
  if "umirovljen"==x:





        #<---------custom commands---------------------->


  if ("customname1"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom1.append(input(str(x+1) + " name: "))
  if ("customname2"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom2.append(input(str(x+1) + " name: "))
  if ("customname3"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom3.append(input(str(x+1) + " name: "))
  if ("customname4"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom4.append(input(str(x+1) + " name: "))
  if ("customname5"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom5.append(input(str(x+1) + " name: "))

  if ("id" ==x):
      id = int(input("Id starts at? "))
    
  if ("foreignkey1" ==x):
      foreignkey1= int(input("Foreign key1 starts at? "))
  if ("foreignkey2" ==x):
      foreignkey2= int(input("Foreign key2 starts at? "))
  if ("foreignkey3" ==x):
      foreignkey3= int(input("Foreign key3 starts at? "))
  if ("foreignkey4" ==x):
      foreignkey4= int(input("Foreign key4 starts at? "))
  if ("foreignkey5" ==x):
      foreignkey5= int(input("Foreign key5 starts at? "))
  
  if ("datum1"== x):
      if input("Add Time? y/n") == "y":
          Vrijeme1 = True
      else:
          Vrijeme1 = False
      if input("Add Date? y/n") == "y":
          Datum1 = True
      else:
          Datum1 = False
      god1=input("date from: ")
      god2=input("date to: ")
        
  if ("datum2"== x):
    
      if input("Add Time? y/n") == "y":
          Vrijeme2 = True
      else:
          Vrijeme2 = False
      if input("Add Date? y/n") == "y":
          Datum2 = True
      else:
          Datum2 = False
      god3=input("date from: ")
      god4=input("date to: ")

    
        
  if ("randnum1"==x):
      start1 = input("rand number starts at? ")
      end1 = input("rand number ends at? ")
  if ("randnum2"==x):
      start2 = input("rand number starts at? ")
      end2 = input("rand number ends at? ")
  if ("randnum3"==x):
      start3 = input("rand number starts at? ")
      end3 = input("rand number ends at? ")
  if ("randnum4"==x):
      start4 = input("rand number starts at? ")
      end4 = input("rand number ends at? ")
  if ("randnum5"==x):
      start5 = input("rand number starts at? ")
      end5 = input("rand number ends at? ")




# crearting table
rj = []
rj.append("INSERT INTO " + input("Naziv Tablice? ") + " VALUES \n")

for y in range(int(input("Velicina tablice? "))):
    rj.append("(")
    for x in lista:
        
        if x == "id":
            id += 1
            rj.append(str(id) )
                #ime prezime
        elif x == "ime":
            rj.append(str('"'+randname())+'"' )
        elif x == "prezime":
            rj.append(str('"'+randprezime())+'"' )
                #datum - vrijeme
        elif x == "datum1":     #STR_TO_DATE("22.03.1991.", "%d.%m.%Y.")
           
            rj.append(str('STR_TO_DATE("'+str(Date(Vrijeme1, Datum1,int(god1),int(god2)))+'"'+', "%d.%m.%Y.")') )  
        elif x == "datum2":
              rj.append(str('STR_TO_DATE("'+str(Date(Vrijeme2, Datum2,int(god3),int(god4)))+'"'+', "%d.%m.%Y.")') )  
                #custom name
        elif x == "customname1":
            rj.append(str('"'+ Customrandname(custom1)+'"') )
        elif x == "customname2":
            rj.append(str('"'+Customrandname(custom2))+'"' )
        elif x == "customname3":
            rj.append(str('"'+Customrandname(custom3))+'"' )
        elif x == "customname4":
            rj.append(str('"'+Customrandname(custom4))+'"' )
        elif x == "customname5":
            rj.append(str('"'+Customrandname(custom5))+'"' )
                #foreign keys
        elif x == "foreignkey1":
            foreignkey1 += 1
            rj.append(str(foreignkey1) )
        elif x == "foreignkey2":
            foreignkey2 += 1
            rj.append(str(foreignkey2) )
        elif x == "foreignkey3":
            foreignkey3 += 1
            rj.append(str(foreignkey3) )
        elif x == "foreignkey4":
            foreignkey4 += 1
            rj.append(str(foreignkey4) )
        elif x == "foreignkey5":
            foreignkey5 += 1
            rj.append(str(foreignkey5) )
                #bool
        elif x == "bool":
            rj.append(str(randbool()) )
                #random nummbers
        elif x == "randnum1":
            rj.append(str(RandNumb(int(start1), int(end1))) )
        elif x == "randnum2":
            rj.append(str(RandNumb(int(start2), int(end2))) )
        elif x == "randnum3":
            rj.append(str(RandNumb(int(start3), int(end3))) )
        elif x == "randnum4":
            rj.append(str(RandNumb(int(start4), int(end4))) )
        elif x == "randnum5":
            rj.append(str(RandNumb(int(start5), int(end5))) )
        
        rj.append(",")
    rj=rj[:-1]
    rj.append("),\n")
print(*rj, end=");")

raw_input()
