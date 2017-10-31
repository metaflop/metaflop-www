#!/usr/bin/env python

#mf2outline-tk version 20170110

#This program has been written by Linus Romer as 
#GUI (Graphical User Interface) for the mf2outline script.

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Copyright 2017 by Linus Romer

import os,ttk
from Tkinter import *
from tkFileDialog import askopenfilename      
from tkMessageBox import *

def choosefontfile():
    fontfilename = askopenfilename()
    fontentry.delete(0, END)
    fontentry.insert(0,fontfilename)

def runmf2outline():
	if fontentry.get() != "":
		arguments = ""
		if designsizeentry.get() != "":
			arguments += "--designsize " + designsizeentry.get() + " "
		os.system("python mf2outline.py "+arguments+fontentry.get())
	else:
		showwarning('Miss font file name', 'Please choose a font file name!')

# variables to be declared...
encoding = None # not known yet
fontentry = Entry(text="",width=40)
designsizeentry = Entry(text="",width=10)
encodingentry = Entry(text="",width=20)
#
Label(text='mf2outline is a python script that converts METAFONT fonts to outline formats like OpenType.').grid(row=0,column=0,columnspan=5)
#
Label(text='Font source:').grid(row=1,column=0)
fontentry.grid(row=1,column=1,columnspan=3)
Button(text='Choose', command=choosefontfile).grid(row=1,column=4)
#
Button(text='Convert', command=runmf2outline).grid(row=2,column=2)
#
ttk.Separator(orient=HORIZONTAL).grid(row=3, column=0, columnspan=2, sticky="ew")
Label(text='Options:').grid(row=3,column=2)
ttk.Separator(orient=HORIZONTAL).grid(row=3, column=3, columnspan=2, sticky="ew")
#
Label(text='Encoding:').grid(row=4,column=0)
Radiobutton(text="T1",variable=encoding,value="t1").grid(row=4,column=1,sticky=W)
Radiobutton(text="OT1",variable=encoding,value="ot1").grid(row=4,column=2,sticky=W)
Radiobutton(text="Unicode",variable=encoding,value="unicode").grid(row=4,column=3,sticky=W)
Radiobutton(text="Other:",variable=encoding,value="other").grid(row=5,column=1,sticky=W)
encodingentry.grid(row=5,column=2,columnspan=3,sticky=W)
#
Label(text='Design size:').grid(row=6,column=0)
designsizeentry.grid(row=6,column=1,sticky=W)

mainloop()



