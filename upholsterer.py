#!/bin/python

from tkinter import *
from tkinter.ttk import Frame, Label, Button, Style, Entry, Checkbutton
from time import sleep
import os
import sys
import subprocess
import threading

from PIL import Image

if __name__ != "__main__":
    exit()

window = Tk()
window["bg"] = '#D7EDFF'
window.title("Čalouníkův problém")
window.geometry = ('800x600')

style = Style()

style.configure('TButton', font = ('calibri', 15, 'bold'), borderwidth = '4', background = "#D7EDFF")
style.configure('TLabel',  font = ('calibri', 10, 'bold'), borderwidth = '0', background = "#D7EDFF")
style.configure('TEntry',  font = ('calibri', 10, 'bold'), borderwidth = '4', background = "#D7EDFF")
style.configure('TCheckbutton',  font = ('calibri', 10, 'bold'), borderwidth = '2', background = "#D7EDFF")

style.map('TButton', foreground = [('active', '!disabled', 'green')],
                     background = [('active', 'black')])

empty_label1 = Label(window,text="Čalouníkův", font = ('calibri', 15, 'bold'))
empty_label2 = Label(window,text="problém", font = ('calibri', 15, 'bold'))
empty_label1.grid(column=1, row=0)
empty_label2.grid(column=2, row=0)

label1 = Label(window, text="Šířka látky v cm")
width_entry = Entry(window, width = 17)
label1.grid(column=2, row=1)
width_entry.grid(column=3, row=1)

label2 = Label(window, text="Lze otáčet")
orientation_state = BooleanVar()
orientation_state.set(False)
orientation = Checkbutton(window, text="Ano", var=orientation_state)
label2.grid(column=0, row=1)
orientation.grid(column=1, row=1)

label3 = Label(window, text="Seznam kusů", font = ('calibri', 12, 'bold'))
label3.grid(column=1, row=2)


run_label = Label(window, text="")
name_label = Label(window, text="output.png")
run_label.grid(column=2,row=202)
name_label.grid(column=3, row=202)

row_idx=4
item_count = 0
piece_count = 0
x_entries = []
y_entries = []
count_entries = []
labels = []
running = False

label_total_count = Label(window, text="Celkem :"+str(item_count))

def add_piece():
    global row_idx
    global item_count
    global piece_count
    item_count += 1
    item_label = Label(window, text=str(item_count))
    labels.append(item_label)
    x_entry = Entry(window, width = 17)
    x_entries.append(x_entry)
    y_entry = Entry(window, width = 17)
    y_entries.append(y_entry)
    count_entry = Entry(window, width = 17)
    count_entries.append(count_entry)

    item_label.grid(column=0, row=row_idx)
    x_entry.grid(column=1, row=row_idx)
    y_entry.grid(column=2, row=row_idx)
    count_entry.grid(column=3, row=row_idx)
    row_idx += 1
    label_total_count.config(text="Celkem :"+str(item_count))

add_piece()

addbtn = Button(window, text="Přidej kus", command=add_piece)
addbtn.grid(column=0, row=3)

label_x = Label(window, text="Délka kusu")
label_y = Label(window, text="Šířka kusu")
label_count = Label(window, text="Počet")
label_x.grid(column=1, row=3)
label_y.grid(column=2, row=3)
label_count.grid(column=3, row=3)

def thread_run():
    global running
    running = True
    if( os.path.isfile("code/status.txt") ):
        os.remove("code/status.txt")
    os.system("julia -t 4 code/main.jl")
    running = False

def thread_status():
    imageViewerFromCommandLine = {'linux':'xdg-open',
                                  'win32':'explorer',
                                  'darwin':'open'}[sys.platform]
    while(True):
        print("Checking status")
        sleep(3)
        if( os.path.isfile("code/status.txt") ):
            f = open("code/status.txt", "r")
            status = f.read()
            f.close()
            run_label.config(text = status)
            print("status v souboru: ", status)
            if status == "done":
                run_label.config(text = "hotovo")
                subprocess.Popen([imageViewerFromCommandLine, "code/output.png"])
                break




def write_input():
    global runs
    global running
    if running:
        return
    try:
        picname = "./code/output.png"
        cm = int( width_entry.get() )
        can_rotate = orientation_state.get()
        items = []
        for i in range(item_count):
            x = int( x_entries[i].get() )
            y = int( y_entries[i].get() )
            count = int( count_entries[i].get() )
            for c in range(count):
                items.append( [x,y] )
        
        f = open("code/problem.txt", 'w')
        f.write(picname+"\n")
        f.write(str(cm)+"\n")
        f.write(str(can_rotate)+"\n")
        for item in items:
            f.write( str(item[0]) + " " + str(item[1])+"\n" )
        f.close()

        run_label.config(text="Pracuji...")
        temp = Label(window, text="temp")
        x = threading.Thread(target=thread_run, args=())
        x.start()
        y = threading.Thread(target=thread_status, args=())
        y.start()

    except Exception as e:
        run_label.config(text = "nejde to:"+str(e))



label_total_count.grid(column=1, row=201)

def remove_last():
    global row_idx
    global item_count
    global piece_count
    labels[-1].destroy()
    x_entries[-1].destroy()
    y_entries[-1].destroy()
    count_entries[-1].destroy()
    labels.pop()
    x_entries.pop()
    y_entries.pop()
    count_entries.pop()
    row_idx -= 1
    item_count -= 1
    label_total_count.config(text="Celkem :"+str(item_count))

delbtn = Button(window, text="Odeber", command=remove_last)
delbtn.grid(column=0,row=202)

btn = Button(window, text="Šup!", command=write_input)
btn.grid(column=1,row=202)



window.mainloop()