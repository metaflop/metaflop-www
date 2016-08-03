#!/usr/bin/env python

#mf2outline version 20160803

#This program has been written by Linus Romer for the 
#Metaflop project by Marco Mueller and Alexis Reigel.

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Copyright 2014 by Linus Romer

import os,sys,fontforge,glob,subprocess,tempfile,shutil,argparse,math

def run_metapost(mffile,design_size,workdir,tempdir,mainargs):
	mpargs = ['mpost',
	'&%s/mf2outline-prev' % workdir
	if mainargs.preview
	else '&%s/mf2outline' % workdir,
	'\mode=localfont;',
	'mag:=%s;' % (1003.75/design_size), 
	'nonstopmode;',
	'outputtemplate:=\"%{charunicode}.eps\";',
	'input %s;' % mffile,
	'bye']
	subprocess.call(
	mpargs,
	stdout = None if mainargs.verbose else subprocess.PIPE, 
	stderr = subprocess.PIPE,
	cwd = tempdir
	)
	
def generate_pdf(font,mffile,outputname,tempdir,mainargs):
	subprocess.call( # run mpost in proof mode
	['mpost',
	'&%s/mf2outline' % os.path.split(os.path.abspath(sys.argv[0]))[0],
	'\mode:=proof;',
	'nonstopmode;',
	'outputtemplate:=\"%{charunicode}.mps\";',
	'input %s;' % mffile,
	'bye'],
	stdout = None if mainargs.veryverbose else subprocess.PIPE, 
	stderr = subprocess.PIPE,
	cwd = tempdir
	)
	# write tex-file for proof images
	with open(os.path.join(tempdir, "%s.tex" % outputname), "w") as texfile:
		texfile.write("\documentclass{article}\n")
		texfile.write("\usepackage{graphicx}\n")
		texfile.write("\usepackage[left=1cm,right=1cm,bottom=1cm]{geometry}\n")
		texfile.write("\pagestyle{empty}\n")
		texfile.write("\\begin{document}\n")
		texfile.write("\\begin{center}\n")
		texfile.write("\mbox{}\n\n\\vspace{3cm}\n{\Huge\\textbf{%s}}\\\\[3ex]\n" % outputname)
		texfile.write("\\today\\\\\n")
		texfile.write("\\vspace{2cm}\n")
		texfile.write("\\begin{tabular}{|l|c|}\hline\n")
		texfile.write("font name & %s\\\\\hline\n" % font.fontname)
		texfile.write("full name & %s\\\\\hline\n" % font.fullname)
		texfile.write("family name & %s\\\\\hline\n" % font.familyname)
		texfile.write("design size & %s\\\\\hline\n" % font.design_size)
		texfile.write("italic angle & %s\\\\\hline\n" % font.italicangle)
		texfile.write("\end{tabular}\\newpage\n")
		mpslist = sorted(glob.glob(os.path.join(tempdir, "*.mps")),
		key=lambda name: int(os.path.splitext(os.path.basename(name))[0],16))
		for i in mpslist:
			code = int(os.path.splitext(os.path.basename(i))[0],16)
			texfile.write("\\begin{tabular}{|l|c|}\hline\n")
			texfile.write("glyph name & %s\\\\\hline\n" % font[code].glyphname)
			texfile.write("code (hexadecimal) & %s\\\\\hline\n" % os.path.splitext(os.path.basename(i))[0])
			texfile.write("code (decimal) & %s\\\\\hline\n" % code)
			texfile.write("width (pt/1000) & %s\\\\\hline\n" % font[code].width)
			texfile.write("height (pt/1000) & %s\\\\\hline\n" % font[code].texheight)
			texfile.write("depth (pt/1000) & %s\\\\\hline\n" % font[code].texdepth)
			texfile.write("italic correction (pt/1000) & %s\\\\\hline\n" % font[code].italicCorrection)
			texfile.write("\end{tabular}\\\\[3ex]\n")
			texfile.write("\includegraphics[scale=%s]{%s}\\newpage\n" % (10.0/font.design_size,i) )
		texfile.write("\end{center}\n")
		texfile.write("\end{document}\n")
	subprocess.call(
	['latex',"%s.tex" % outputname],
	stdout = None if mainargs.veryverbose else subprocess.PIPE, 
	stderr = subprocess.PIPE,
	cwd = tempdir
	)
	subprocess.call(
	['dvipdfmx',"%s.dvi" % outputname],
	stdout = None if mainargs.veryverbose else subprocess.PIPE, 
	stderr = subprocess.PIPE,
	cwd = tempdir
	)
	shutil.copyfile("%s/%s.pdf" % (tempdir, outputname), "%s.pdf" % outputname) 
	
def write_t1_enc(tempdir):
	with open(os.path.join(tempdir, "t1.enc"), "w") as encfile:
		encfile.write("/T1Encoding [\n")
		encfile.write("/grave           % 0x00 U+0060\n")
		encfile.write("/acute           % 0x01 U+00B4\n")
		encfile.write("/circumflex      % 0x02 U+02C6\n")
		encfile.write("/tilde           % 0x03 U+02DC\n")
		encfile.write("/dieresis        % 0x04 U+00A8\n")
		encfile.write("/hungarumlaut    % 0x05 U+02DD\n")
		encfile.write("/ring            % 0x06 U+02DA\n")
		encfile.write("/caron           % 0x07 U+02C7\n")
		encfile.write("/breve           % 0x08 U+02D8\n")
		encfile.write("/macron          % 0x09 U+00AF\n")
		encfile.write("/dotaccent       % 0x0A U+02D9\n")
		encfile.write("/cedilla         % 0x0B U+00B8\n")
		encfile.write("/ogonek          % 0x0C U+02DB\n")
		encfile.write("/quotesinglbase  % 0x0D U+201A\n")
		encfile.write("/guilsinglleft   % 0x0E U+2039\n")
		encfile.write("/guilsinglright  % 0x0F U+203A\n")
		encfile.write("/quotedblleft    % 0x10 U+201C\n")
		encfile.write("/quotedblright   % 0x11 U+201D\n")
		encfile.write("/quotedblbase    % 0x12 U+201E\n")
		encfile.write("/guillemotleft   % 0x13 U+00AB\n")
		encfile.write("/guillemotright  % 0x14 U+00BB\n")
		encfile.write("/endash          % 0x15 U+2013\n")
		encfile.write("/emdash          % 0x16 U+2014\n")
		encfile.write("/cwm             % 0x17 U+200B\n")
		encfile.write("/perthousandzero % 0x18 ______\n")
		encfile.write("/dotlessi        % 0x19 U+0131\n")
		encfile.write("/dotlessj        % 0x1A U+0237\n")
		encfile.write("/ff              % 0x1B U+FB00\n")
		encfile.write("/fi              % 0x1C U+FB01\n")
		encfile.write("/fl              % 0x1D U+FB02\n")
		encfile.write("/ffi             % 0x1E U+FB03\n")
		encfile.write("/ffl             % 0x1F U+FB04\n")
		encfile.write("/visiblespace    % 0x20 U+2423\n")
		encfile.write("/exclam          % 0x21\n")
		encfile.write("/quotedbl        % 0x22\n")
		encfile.write("/numbersign      % 0x23\n")
		encfile.write("/dollar          % 0x24\n")
		encfile.write("/percent         % 0x25\n")
		encfile.write("/ampersand       % 0x26\n")
		encfile.write("/quoteright      % 0x27 U+2019\n")
		encfile.write("/parenleft       % 0x28\n")
		encfile.write("/parenright      % 0x29\n")
		encfile.write("/asterisk        % 0x2A\n")
		encfile.write("/plus            % 0x2B\n")
		encfile.write("/comma           % 0x2C\n")
		encfile.write("/hyphen          % 0x2D\n")
		encfile.write("/period          % 0x2E\n")
		encfile.write("/slash           % 0x2F\n")
		encfile.write("/zero            % 0x30\n")
		encfile.write("/one             % 0x31\n")
		encfile.write("/two             % 0x32\n")
		encfile.write("/three           % 0x33\n")
		encfile.write("/four            % 0x34\n")
		encfile.write("/five            % 0x35\n")
		encfile.write("/six             % 0x36\n")
		encfile.write("/seven           % 0x37\n")
		encfile.write("/eight           % 0x38\n")
		encfile.write("/nine            % 0x39\n")
		encfile.write("/colon           % 0x3A\n")
		encfile.write("/semicolon       % 0x3B\n")
		encfile.write("/less            % 0x3C\n")
		encfile.write("/equal           % 0x3D\n")
		encfile.write("/greater         % 0x3E\n")
		encfile.write("/question        % 0x3F\n")
		encfile.write("/at              % 0x40\n")
		encfile.write("/A               % 0x41\n")
		encfile.write("/B               % 0x42\n")
		encfile.write("/C               % 0x43\n")
		encfile.write("/D               % 0x44\n")
		encfile.write("/E               % 0x45\n")
		encfile.write("/F               % 0x46\n")
		encfile.write("/G               % 0x47\n")
		encfile.write("/H               % 0x48\n")
		encfile.write("/I               % 0x49\n")
		encfile.write("/J               % 0x4A\n")
		encfile.write("/K               % 0x4B\n")
		encfile.write("/L               % 0x4C\n")
		encfile.write("/M               % 0x4D\n")
		encfile.write("/N               % 0x4E\n")
		encfile.write("/O               % 0x4F\n")
		encfile.write("/P               % 0x50\n")
		encfile.write("/Q               % 0x51\n")
		encfile.write("/R               % 0x52\n")
		encfile.write("/S               % 0x53\n")
		encfile.write("/T               % 0x54\n")
		encfile.write("/U               % 0x55\n")
		encfile.write("/V               % 0x56\n")
		encfile.write("/W               % 0x57\n")
		encfile.write("/X               % 0x58\n")
		encfile.write("/Y               % 0x59\n")
		encfile.write("/Z               % 0x5A\n")
		encfile.write("/bracketleft     % 0x5B\n")
		encfile.write("/backslash       % 0x5C\n")
		encfile.write("/bracketright    % 0x5D\n")
		encfile.write("/asciicircum     % 0x5E\n")
		encfile.write("/underscore      % 0x5F\n")
		encfile.write("/quoteleft       % 0x60 U+2018\n")
		encfile.write("/a               % 0x61\n")
		encfile.write("/b               % 0x62\n")
		encfile.write("/c               % 0x63\n")
		encfile.write("/d               % 0x64\n")
		encfile.write("/e               % 0x65\n")
		encfile.write("/f               % 0x66\n")
		encfile.write("/g               % 0x67\n")
		encfile.write("/h               % 0x68\n")
		encfile.write("/i               % 0x69\n")
		encfile.write("/j               % 0x6A\n")
		encfile.write("/k               % 0x6B\n")
		encfile.write("/l               % 0x6C\n")
		encfile.write("/m               % 0x6D\n")
		encfile.write("/n               % 0x6E\n")
		encfile.write("/o               % 0x6F\n")
		encfile.write("/p               % 0x70\n")
		encfile.write("/q               % 0x71\n")
		encfile.write("/r               % 0x72\n")
		encfile.write("/s               % 0x73\n")
		encfile.write("/t               % 0x74\n")
		encfile.write("/u               % 0x75\n")
		encfile.write("/v               % 0x76\n")
		encfile.write("/w               % 0x77\n")
		encfile.write("/x               % 0x78\n")
		encfile.write("/y               % 0x79\n")
		encfile.write("/z               % 0x7A\n")
		encfile.write("/braceleft       % 0x7B\n")
		encfile.write("/bar             % 0x7C\n")
		encfile.write("/braceright      % 0x7D\n")
		encfile.write("/asciitilde      % 0x7E\n")
		encfile.write("/dash            % 0x7F U+2010\n")
		encfile.write("/Abreve          % 0x80 U+0102\n")
		encfile.write("/Aogonek         % 0x81 U+0104\n")
		encfile.write("/Cacute          % 0x82 U+0106\n")
		encfile.write("/Ccaron          % 0x83 U+010C\n")
		encfile.write("/Dcaron          % 0x84 U+010E\n")
		encfile.write("/Ecaron          % 0x85 U+011A\n")
		encfile.write("/Eogonek         % 0x86 U+0118\n")
		encfile.write("/Gbreve          % 0x87 U+011E\n")
		encfile.write("/Lacute          % 0x88 U+0139\n")
		encfile.write("/Lcaron          % 0x89 U+013D\n")
		encfile.write("/Lslash          % 0x8A U+0141\n")
		encfile.write("/Nacute          % 0x8B U+0143\n")
		encfile.write("/Ncaron          % 0x8C U+0147\n")
		encfile.write("/Eng             % 0x8D U+014A\n")
		encfile.write("/Ohungarumlaut   % 0x8E U+0150\n")
		encfile.write("/Racute          % 0x8F U+0154\n")
		encfile.write("/Rcaron          % 0x90 U+0158\n")
		encfile.write("/Sacute          % 0x91 U+015A\n")
		encfile.write("/Scaron          % 0x92 U+0160\n")
		encfile.write("/Scedilla        % 0x93 U+015E\n")
		encfile.write("/Tcaron          % 0x94 U+0164\n")
		encfile.write("/Tcedilla        % 0x95 U+0162\n")
		encfile.write("/Uhungarumlaut   % 0x96 U+0170\n")
		encfile.write("/Uring           % 0x97 U+016E\n")
		encfile.write("/Ydieresis       % 0x98 U+0178\n")
		encfile.write("/Zacute          % 0x99 U+0179\n")
		encfile.write("/Zcaron          % 0x9A U+017D\n")
		encfile.write("/Zdotaccent      % 0x9B U+017B\n")
		encfile.write("/IJ              % 0x9C U+0132\n")
		encfile.write("/Idotaccent      % 0x9D U+0130\n")
		encfile.write("/dcroat          % 0x9E U+0111\n")
		encfile.write("/section         % 0x9F U+00A7\n")
		encfile.write("/abreve          % 0xA0 U+0103\n")
		encfile.write("/aogonek         % 0xA1 U+0105\n")
		encfile.write("/cacute          % 0xA2 U+0107\n")
		encfile.write("/ccaron          % 0xA3 U+010D\n")
		encfile.write("/dcaron          % 0xA4 U+010F\n")
		encfile.write("/ecaron          % 0xA5 U+011B\n")
		encfile.write("/eogonek         % 0xA6 U+0119\n")
		encfile.write("/gbreve          % 0xA7 U+011F\n")
		encfile.write("/lacute          % 0xA8 U+013A\n")
		encfile.write("/lcaron          % 0xA9 U+013E\n")
		encfile.write("/lslash          % 0xAA U+0142\n")
		encfile.write("/nacute          % 0xAB U+0144\n")
		encfile.write("/ncaron          % 0xAC U+0148\n")
		encfile.write("/eng             % 0xAD U+014B\n")
		encfile.write("/ohungarumlaut   % 0xAE U+0151\n")
		encfile.write("/racute          % 0xAF U+0155\n")
		encfile.write("/rcaron          % 0xB0 U+0159\n")
		encfile.write("/sacute          % 0xB1 U+015B\n")
		encfile.write("/scaron          % 0xB2 U+0161\n")
		encfile.write("/scedilla        % 0xB3 U+015F\n")
		encfile.write("/tcaron          % 0xB4 U+0165\n")
		encfile.write("/tcedilla        % 0xB5 U+0163\n")
		encfile.write("/uhungarumlaut   % 0xB6 U+0171\n")
		encfile.write("/uring           % 0xB7 U+016F\n")
		encfile.write("/ydieresis       % 0xB8 U+00FF\n")
		encfile.write("/zacute          % 0xB9 U+017A\n")
		encfile.write("/zcaron          % 0xBA U+017E\n")
		encfile.write("/zdotaccent      % 0xBB U+017C\n")
		encfile.write("/ij              % 0xBC U+0133\n")
		encfile.write("/exclamdown      % 0xBD U+00A1\n")
		encfile.write("/questiondown    % 0xBE U+00BF\n")
		encfile.write("/sterling        % 0xBF U+00A3\n")
		encfile.write("/Agrave          % 0xC0\n")
		encfile.write("/Aacute          % 0xC1\n")
		encfile.write("/Acircumflex     % 0xC2\n")
		encfile.write("/Atilde          % 0xC3\n")
		encfile.write("/Adieresis       % 0xC4\n")
		encfile.write("/Aring           % 0xC5\n")
		encfile.write("/AE              % 0xC6\n")
		encfile.write("/Ccedilla        % 0xC7\n")
		encfile.write("/Egrave          % 0xC8\n")
		encfile.write("/Eacute          % 0xC9\n")
		encfile.write("/Ecircumflex     % 0xCA\n")
		encfile.write("/Edieresis       % 0xCB\n")
		encfile.write("/Igrave          % 0xCC\n")
		encfile.write("/Iacute          % 0xCD\n")
		encfile.write("/Icircumflex     % 0xCE\n")
		encfile.write("/Idieresis       % 0xCF\n")
		encfile.write("/Eth             % 0xD0\n")
		encfile.write("/Ntilde          % 0xD1\n")
		encfile.write("/Ograve          % 0xD2\n")
		encfile.write("/Oacute          % 0xD3\n")
		encfile.write("/Ocircumflex     % 0xD4\n")
		encfile.write("/Otilde          % 0xD5\n")
		encfile.write("/Odieresis       % 0xD6\n")
		encfile.write("/OE              % 0xD7 U+0152\n")
		encfile.write("/Oslash          % 0xD8\n")
		encfile.write("/Ugrave          % 0xD9\n")
		encfile.write("/Uacute          % 0xDA\n")
		encfile.write("/Ucircumflex     % 0xDB\n")
		encfile.write("/Udieresis       % 0xDC\n")
		encfile.write("/Yacute          % 0xDD\n")
		encfile.write("/Thorn           % 0xDE\n")
		encfile.write("/Germandbls      % 0xDF U+1E9E\n")
		encfile.write("/agrave          % 0xE0\n")
		encfile.write("/aacute          % 0xE1\n")
		encfile.write("/acircumflex     % 0xE2\n")
		encfile.write("/atilde          % 0xE3\n")
		encfile.write("/adieresis       % 0xE4\n")
		encfile.write("/aring           % 0xE5\n")
		encfile.write("/ae              % 0xE6\n")
		encfile.write("/ccedilla        % 0xE7\n")
		encfile.write("/egrave          % 0xE8\n")
		encfile.write("/eacute          % 0xE9\n")
		encfile.write("/ecircumflex     % 0xEA\n")
		encfile.write("/edieresis       % 0xEB\n")
		encfile.write("/igrave          % 0xEC\n")
		encfile.write("/iacute          % 0xED\n")
		encfile.write("/icircumflex     % 0xEE\n")
		encfile.write("/idieresis       % 0xEF\n")
		encfile.write("/eth             % 0xF0\n")
		encfile.write("/ntilde          % 0xF1\n")
		encfile.write("/ograve          % 0xF2\n")
		encfile.write("/oacute          % 0xF3\n")
		encfile.write("/ocircumflex     % 0xF4\n")
		encfile.write("/otilde          % 0xF5\n")
		encfile.write("/odieresis       % 0xF6\n")
		encfile.write("/oe              % 0xF7 U+0153\n")
		encfile.write("/oslash          % 0xF8\n")
		encfile.write("/ugrave          % 0xF9\n")
		encfile.write("/uacute          % 0xFA\n")
		encfile.write("/ucircumflex     % 0xFB\n")
		encfile.write("/udieresis       % 0xFC\n")
		encfile.write("/yacute          % 0xFD\n")
		encfile.write("/thorn           % 0xFE\n")
		encfile.write("/germandbls      % 0xFF U+00DF\n")
		encfile.write("] def")

def write_ot1_enc(tempdir):
	with open(os.path.join(tempdir, "ot1.enc"), "w") as encfile:
		encfile.write("/OT1Encoding [\n")
		encfile.write("/Gamma           % 0x00 U+0393\n")
		encfile.write("/Delta           % 0x01 U+0394\n")
		encfile.write("/Theta           % 0x02 U+0398\n")
		encfile.write("/Lambda          % 0x03 U+039B\n")
		encfile.write("/Xi              % 0x04 U+039E\n")
		encfile.write("/Pi              % 0x05 U+03A0\n")
		encfile.write("/Sigma           % 0x06 U+03A3\n")
		encfile.write("/Upsilon         % 0x07 U+03A5\n")
		encfile.write("/Phi             % 0x08 U+03A6\n")
		encfile.write("/Psi             % 0x09 U+03A8\n")
		encfile.write("/Omega           % 0x0A U+03A9\n")
		encfile.write("/ff              % 0x0B U+FB00\n")
		encfile.write("/fi              % 0x0C U+FB01\n")
		encfile.write("/fl              % 0x0D U+FB02\n")
		encfile.write("/ffi             % 0x0E U+FB03\n")
		encfile.write("/ffl             % 0x0F U+FB04\n")
		encfile.write("/dotlessi        % 0x10 U+0131\n")
		encfile.write("/dotlessj        % 0x11 U+0237\n")
		encfile.write("/grave           % 0x12 U+0060\n")
		encfile.write("/acute           % 0x13 U+00B4\n")
		encfile.write("/caron           % 0x14 U+02C7\n")
		encfile.write("/breve           % 0x15 U+02D8\n")
		encfile.write("/macron          % 0x16 U+00AF\n")
		encfile.write("/ring            % 0x17 U+02DA\n")
		encfile.write("/cedilla         % 0x18 U+00B8\n")
		encfile.write("/germandbls      % 0x19 U+00DF\n")
		encfile.write("/ae              % 0x1A U+00E6\n")
		encfile.write("/oe              % 0x1B U+0153\n")
		encfile.write("/oslash          % 0x1C U+00F8\n")
		encfile.write("/AE              % 0x1D U+00C6\n")
		encfile.write("/OE              % 0x1E U+0152\n")
		encfile.write("/Oslash          % 0x1F U+00D8\n")
		encfile.write("/polishstroke    % 0x20 U+0335\n")
		encfile.write("/exclam          % 0x21 U+0021\n")
		encfile.write("/quotedblright   % 0x22 U+201D\n")
		encfile.write("/numbersign      % 0x23 U+0023\n")
		encfile.write("/dollar          % 0x24 U+0024\n")
		encfile.write("/percent         % 0x25 U+0025\n")
		encfile.write("/ampersand       % 0x26 U+0026\n")
		encfile.write("/quoteright      % 0x27 U+2019\n")
		encfile.write("/parenleft       % 0x28 U+0028\n")
		encfile.write("/parenright      % 0x29 U+0029\n")
		encfile.write("/asterisk        % 0x2A U+002A\n")
		encfile.write("/plus            % 0x2B U+002B\n")
		encfile.write("/comma           % 0x2C U+002C\n")
		encfile.write("/hyphen          % 0x2D U+002D\n")
		encfile.write("/period          % 0x2E U+002E\n")
		encfile.write("/slash           % 0x2F U+002F\n")
		encfile.write("/zero            % 0x30\n")
		encfile.write("/one             % 0x31\n")
		encfile.write("/two             % 0x32\n")
		encfile.write("/three           % 0x33\n")
		encfile.write("/four            % 0x34\n")
		encfile.write("/five            % 0x35\n")
		encfile.write("/six             % 0x36\n")
		encfile.write("/seven           % 0x37\n")
		encfile.write("/eight           % 0x38\n")
		encfile.write("/nine            % 0x39\n")
		encfile.write("/colon           % 0x3A U+003A\n")
		encfile.write("/semicolon       % 0x3B U+003B\n")
		encfile.write("/exclamdown      % 0x3C U+003C\n")
		encfile.write("/equal           % 0x3D U+003D\n")
		encfile.write("/questiondown    % 0x3E U+003E\n")
		encfile.write("/question        % 0x3F U+003F\n")
		encfile.write("/at              % 0x40 U+0040\n")
		encfile.write("/A               % 0x41\n")
		encfile.write("/B               % 0x42\n")
		encfile.write("/C               % 0x43\n")
		encfile.write("/D               % 0x44\n")
		encfile.write("/E               % 0x45\n")
		encfile.write("/F               % 0x46\n")
		encfile.write("/G               % 0x47\n")
		encfile.write("/H               % 0x48\n")
		encfile.write("/I               % 0x49\n")
		encfile.write("/J               % 0x4A\n")
		encfile.write("/K               % 0x4B\n")
		encfile.write("/L               % 0x4C\n")
		encfile.write("/M               % 0x4D\n")
		encfile.write("/N               % 0x4E\n")
		encfile.write("/O               % 0x4F\n")
		encfile.write("/P               % 0x50\n")
		encfile.write("/Q               % 0x51\n")
		encfile.write("/R               % 0x52\n")
		encfile.write("/S               % 0x53\n")
		encfile.write("/T               % 0x54\n")
		encfile.write("/U               % 0x55\n")
		encfile.write("/V               % 0x56\n")
		encfile.write("/W               % 0x57\n")
		encfile.write("/X               % 0x58\n")
		encfile.write("/Y               % 0x59\n")
		encfile.write("/Z               % 0x5A\n")
		encfile.write("/bracketleft     % 0x5B U+005B\n")
		encfile.write("/quotedblleft    % 0x5C U+201C\n")
		encfile.write("/bracketright    % 0x5D U+005D\n")
		encfile.write("/circumflex      % 0x5E U+005E\n")
		encfile.write("/dotaccent       % 0x5F U+0307\n")
		encfile.write("/quoteleft       % 0x60 U+2018\n")
		encfile.write("/a               % 0x61\n")
		encfile.write("/b               % 0x62\n")
		encfile.write("/c               % 0x63\n")
		encfile.write("/d               % 0x64\n")
		encfile.write("/e               % 0x65\n")
		encfile.write("/f               % 0x66\n")
		encfile.write("/g               % 0x67\n")
		encfile.write("/h               % 0x68\n")
		encfile.write("/i               % 0x69\n")
		encfile.write("/j               % 0x6A\n")
		encfile.write("/k               % 0x6B\n")
		encfile.write("/l               % 0x6C\n")
		encfile.write("/m               % 0x6D\n")
		encfile.write("/n               % 0x6E\n")
		encfile.write("/o               % 0x6F\n")
		encfile.write("/p               % 0x70\n")
		encfile.write("/q               % 0x71\n")
		encfile.write("/r               % 0x72\n")
		encfile.write("/s               % 0x73\n")
		encfile.write("/t               % 0x74\n")
		encfile.write("/u               % 0x75\n")
		encfile.write("/v               % 0x76\n")
		encfile.write("/w               % 0x77\n")
		encfile.write("/x               % 0x78\n")
		encfile.write("/y               % 0x79\n")
		encfile.write("/z               % 0x7A\n")
		encfile.write("/endash          % 0x7B U+2013\n")
		encfile.write("/emdash          % 0x7C U+2014\n")
		encfile.write("/quotedbl        % 0x7D U+0022\n")
		encfile.write("/tilde           % 0x7E U+02DC\n")
		encfile.write("/dieresis        % 0x7F U+00A8\n")
		encfile.write("] def")

if __name__ == "__main__":			
	parser = argparse.ArgumentParser(description="Generate outline fonts from Metafont sources.")
	parser.add_argument("mfsource", help="The file name of the Metafont source file")
	parser.add_argument("-v", "--verbose",
		action='store_true',
		default=False,
		help="Explain what is being done.")
	parser.add_argument("-vv", "--veryverbose",
		action='store_true',
		default=False,
		help="Explain very detailed what is being done.")
	parser.add_argument("--designsize", 
		dest = "designsize",
		metavar = "SIZE",
		type = float,
		default = None,
		help="Force the designsize to be SIZE (e.g. 12 for 12pt).")	
	parser.add_argument("--raw",
		action="store_true",
		dest="raw",
		default=False,
		help="Do not remove overlaps, round to int, add extrema, add hints...")
	parser.add_argument("--ignore-tfm",
		action="store_true",
		dest="ignoretfm",
		default=False,
		help="Do not read any data from the tfm file...")
	parser.add_argument("--preview",
		action="store_true",
		dest="preview",
		default=False,
		help="Use icosagon pens instead of circle/elliptic pens and do not" \
		"care about advanced font features like kerning and ligatures" \
		"(makes things faster, mainly used for METAFLOP). ")
	parser.add_argument("-f", "--formats",
		action="append",
		dest="formats",
		default=[],
		help="Generate the formats FORMATS (comma " \
		"separated list). Supported formats: sfd, afm, pfa, pfb, " \
		"otf, ttf, eoff, svg, tfm, pdf (proof). Default: otf")
	parser.add_argument("--encoding", 
		dest="encoding",
		metavar="ENC",
		type=str,
		default="unicode",
		help="Force the font encoding to be ENC. Natively supported " \
		"encodings: ot1, t1, unicode. Default: unicode. The file " \
		"ENC.enc will be read if it exists in the same directory as " \
		"the source file (the encoding name inside the encoding file "\
		"must be named ENC, too).")	
	parser.add_argument("--fullname", 
		dest="fullname",
		metavar="FULL",
		type=str,
		default="Unknown",
		help="Set the full name to FULL (with modifiers and possible spaces).")	
	parser.add_argument("--fontname", 
		dest="fontname",
		metavar="NAME",
		type=str,
		default="Unknown",
		help="Set the font name to NAME (with modifiers and without spaces).")	
	parser.add_argument("--familyname", 
		dest="familyname",
		metavar="FAM",
		type=str,
		default="Unknown",
		help="Set the font family name to FAM.")		
	parser.add_argument("--fullname-as-filename",
		action="store_true",
		dest="fullnameasfilename",
		default=False,
		help="Use the fullname for the name of the output file.")
	parser.add_argument("--fontversion", 
		dest="version",
		metavar="VERS",
		type=str,
		default="001.001",
		help="Set the version of the font to VERS. Default: 001.001")	
	parser.add_argument("--copyright", 
		dest="copyright",
		metavar="COPY",
		type=str,
		default="",
		help="Set the copyright notice of the font to COPY.")		
	parser.add_argument("--vendor", 
		dest="vendor",
		metavar="VEND",
		type=str,
		default="",
		help="Set the vendor name of the font to VEND (limited to 4 " \
		"characters).")	
	parser.add_argument("--weight", 
		dest="weight",
		metavar="WGT",
		type=int,
		default=None,
		help="Force the OS/2 weight of the font to be WGT. The " \
		"weight number is mapped to the following PostScript weight "\
		"names: 100=Thin, 200=Extra-Light, 300=Light, 400=Book, " \
		"500=Medium, 600=Demi-Bold, 700=Bold, 800=Heavy, 900=Black")
	parser.add_argument("--width", 
		dest="width",
		metavar="WDT",
		type=int,
		default=None,
		help="Force the OS/2 width of the font to be WDT. " \
		"The width number stands for the following width names: " \
		"1=Ultra-condensed, 2=Extra-condensed, 3=Condensed, " \
		"4=Semi-condensed, 5=Medium (normal), 6=Semi-expanded, " \
		"7=Expanded, 8=Extra-expanded, 9=Ultra-expanded")
	parser.add_argument("--ffscript", 
		dest="ffscript",
		type=str,
		default="",
		help="Specify an own finetuning fontforge script (e.g. " \
		"finetune.pe). The script file has to be in the same " \
		"directory as the source file. Example script: " \
		"Open($1); SelectAll(); RemoveOverlap(); Generate($1); " \
		"Quit(0);")	
	args = parser.parse_args()
	
	# split args.formats string into proper list
	if len(args.formats)>0:
		args.formats = args.formats[0].split(",")
	else:
		args.formats = ["otf"] # make "otf" default format
		
	if args.veryverbose:
		args.verbose=True

	if not (os.path.isfile(args.mfsource) or os.path.isfile(args.mfsource+".mf")):
		print "Cannot find your specified source file '%s'" % args.mfsource
		exit(1)
	
	font = fontforge.font()
	if args.designsize == None:
		font.design_size = 10
	else:
		font.design_size = args.designsize
	
	mffile = os.path.abspath("%s" % args.mfsource)
	tempdir = tempfile.mkdtemp()
	workdir = os.path.split(os.path.abspath(sys.argv[0]))[0]
	
	if args.verbose:
		print "Running METAPOST..."
		print "-------------------"
	run_metapost(mffile,font.design_size,workdir,tempdir,args)
	if args.verbose:
		print "-------------------"
	if args.designsize == None:	
		if args.verbose:
			print "Checking the designsize in mf2outline.txt..."
		with open(os.path.join(tempdir,"mf2outline.txt"), "r") as metricfile:
			for line in metricfile:
				if line[:11] == "mf2outline:":
					words = line.split()
					if len(words) > 0 and words[1] == "font_size" and len(words) > 1:
						args.designsize = int(words[2])
					break
		if font.design_size != args.designsize: # remember that we just set 10pt by default
			font.design_size = args.designsize
			if args.verbose:
				print "The correct designsize is %s, hence I have to run METAPOST again..." % font.design_size
			run_metapost(mffile,font.design_size,workdir,tempdir,args)
	
	if args.verbose:
		print "Importing font metrics from mf2outline.txt..."
	font_normal_space = 300 # this is a default that has to be set but is changed probably
	fontforgecommands = [] # this list may be used later
	with open(os.path.join(tempdir,"mf2outline.txt"), "r") as metricfile:
		# the idea is to read through the file and store the relevant
		# information in variables or in the fontforgecommands list,
		# which will be processed later
		currentlistname = "none" # yet there is no list to write information to...
		for line in metricfile:
			if line[:11] == "mf2outline:": # look for special words inside the glyphs eps
				words = line.split()
				if len(words) > 0:
					# the single parameters will overwrite existing font parameters...
					if words[1] == "eof": # end of file
						break
					elif words[1] == "font_slant" and len(words) > 1: # the slant of the font
						font.italicangle = -math.degrees(math.atan(float(words[2])))
					elif words[1] == "font_version" and len(words) > 1:
						font.version = " ".join(words[2:])
					elif words[1] == "font_copyright" and len(words) > 1: 
						font.copyright = " ".join(words[2:])
					elif words[1] == "font_name" and len(words) > 1:
						font.fontname = " ".join(words[2:])
					elif words[1] == "font_fullname" and len(words) > 1:
						font.fullname = " ".join(words[2:])
					elif words[1] == "font_familyname" and len(words) > 1:
						font.familyname = " ".join(words[2:])
					elif words[1] == "font_coding_scheme" and len(words) > 1: 
						originalencoding = " ".join(words[2:])
					elif words[1] == "font_os_weight" and len(words) > 1:
						font_os2_weight = int(words[2])
					elif words[1] == "font_os_width" and len(words) > 1:
						font_os2_width = int(words[2])
					# the following tex information cannot be set in the font, 
					# as fontforge does not yet support the setting of 
					# texparameters (only access) but we still read them
					elif words[1] == "font_normal_space" and len(words) > 1:
						font_normal_space = round(float(words[2]) *1000 / args.designsize)
					elif words[1] == "font_x_height" and len(words) > 1:
						font_x_height = round(float(words[2]) *1000 / args.designsize)
					elif words[1] == "font_quad" and len(words) > 1:
						font_quad = round(float(words[2]) *1000 / args.designsize)
					elif words[1] == "fontforge":
						currentlistname = "fontforgecommands"
			elif not currentlistname == "none": # if there is something to write to...
				if (currentlistname == "fontforgecommands"):
					vars()[currentlistname].append(line.rstrip('\n'))
				# else: there may be other lists in future...
					#vars()[currentlistname].append(line.split())

	if args.verbose:
		print "Setting the font encoding..."
	if args.encoding == None:
		args.encoding = originalencoding
	if args.encoding == "Unicode" or args.encoding == "unicode":
		font.encoding = "unicode"
	elif args.encoding == "t1" or args.encoding == "T1": # tex cork encoding (8bit)
		write_t1_enc(tempdir)
		fontforge.loadEncodingFile(os.path.join(tempdir, "t1.enc"))
		font.encoding="T1Encoding"
	elif args.encoding == "ot1" or args.encoding == "OT1": # old tex encoding (7bit)
		write_ot1_enc(tempdir)
		fontforge.loadEncodingFile(os.path.join(tempdir, "ot1.enc"))
		font.encoding = "OT1Encoding"
	elif os.path.isfile(os.path.join(os.path.split(os.path.abspath("%s" % args.mfsource))[0],"%s.enc" %args.encoding)):
		fontforge.loadEncodingFile(os.path.join(os.path.split(os.path.abspath("%s" % args.mfsource))[0],"%s.enc" %args.encoding))
		font.encoding = args.encoding
	else:
		print os.path.join(os.path.split(os.path.abspath("%s" % args.mfsource))[0],"%s.enc" %args.encoding)
		if args.verbose:
			print "I do not know this encoding but will continue with Unicode (BMP)"
		font.encoding = "unicode"
	
	if args.verbose:
		print "Setting other general font information..."
	if args.fullname:
		font.fullname = args.fullname
	if args.fontname:
		font.fontname = args.fontname
	if args.familyname:
		font.familyname = args.familyname
	if args.version:
		font.version = args.version
	if args.copyright:
		font.copyright = args.copyright
	if args.vendor:
		font.os2_vendor = args.vendor
	# setting the weight
	if args.weight == None:
		font.os2_weight = 500 # default
	else:
		font.os2_weight = args.weight
	if font.os2_weight == 100:
		font.weight = "Thin"
	elif font.os2_weight == 200:
		font.weight = "Extra-Light"
	elif font.os2_weight == 300:
		font.weight = "Light"
	elif font.os2_weight == 400:
		font.weight = "Book"
	elif font.os2_weight == 600:
		font.weight = "Demi-Bold"
	elif font.os2_weight == 700:
		font.weight = "Bold"
	elif font.os2_weight == 800:
		font.weight = "Heavy"
	elif font.os2_weight == 900:
		font.weight = "Black"
	else:
		font.os2_weight == 500
		font.weight = "Medium"
	# setting the width
	if args.width == None:
		font.os2_weight = 5 # default
	else:
		font.os2_weight = args.width
	# setting the font comment
	font.comment = "Created with mf2outline."

	if args.verbose:
		print "Importing glyphs and adding glyph metrics..."
	glyph_files = glob.glob(os.path.join(tempdir, "*.eps"))
	for eps in glyph_files:
		code  = int(os.path.splitext(os.path.basename(eps))[0],16) # string is in hexadecimal
		if args.encoding == "unicode":
			glyph = font.createChar(code,fontforge.nameFromUnicode(code))
		else:
			glyph = font.createMappedChar(code)
		if not ((args.encoding == "unicode") and (code == 32) or (args.encoding == "t1" and code == 23)): # do not read space/cwm (it will be empty)
			glyph.importOutlines(eps, ("toobigwarn", "correctdir"))
		with open(eps, "r") as epsfile:
			for line in epsfile:
				if line[0] == "%": # only look at comments	
					words = line.split()
					if len(words) > 1 and words[1] == "mf2outline:": # we read only comments made by mpfont.mp
						if words[2] == "charwd": # the width of the current char
							glyph.width = round(float(words[3]) *1000 / args.designsize)
						elif words[2] == "charht": # the height of the current char
							glyph.texheight = round(float(words[3]) *1000 / args.designsize)
						elif words[2] == "chardp": # the depth of the current char
							glyph.texdepth = round(float(words[3]) *1000 / args.designsize)
						elif words[2] == "charic": # the italic correction of the current char
							glyph.italicCorrection = round(float(words[3]) *1000 / args.designsize)	
	generalname = os.path.splitext(os.path.basename(args.mfsource))[0]	
	
	if not args.preview: # preview does not need ligatures, kernings etc.
		if args.verbose:
			print "Processing font metrics"
		# read and integrate the tfm-file if needed (hence, there seem to be no OpenType features)
		if not args.ignoretfm:
			if args.verbose:
				print "Reading kerning/ligature information from tfm..."
			font.mergeFeature("%s/%s.tfm" % (tempdir, generalname))
		# apply fontforge commands
		if len(fontforgecommands)>0:
			for i in range(0,len(fontforgecommands)):
				eval(fontforgecommands[i])
				
	if args.encoding == "t1":
		if args.veryverbose:
			print "Adding the space character..."
		font.encoding = "unicode" #add space for non-TeX use
		font.createChar(32)
		font[32].width = font_normal_space
		font.encoding = "T1Encoding"
		font.encoding = "compacted"
	
	if not args.raw:
		if args.verbose:
			print "General finetuning in fontforge..."
		if args.preview:
			font.selection.all()
			if args.veryverbose:
				print "Removing overlaps"
			font.removeOverlap()
			if args.veryverbose:
				print "Correcting directions"
			font.correctDirection()
			if args.veryverbose:
				print "Rounding"
			font.round()
			if args.veryverbose:
				print "Hinting"
			font.autoHint()
		elif args.ffscript == "": # no user defined script
			font.selection.all()
			if args.veryverbose:
				print "Simplifying"
			font.simplify()
			if args.veryverbose:
				print "Rounding to 1/100 unit"
			font.round(100)
			if args.veryverbose:
				print "Removing overlaps"
			font.removeOverlap()
			if args.veryverbose:
				print "Correcting directions"
			font.correctDirection()
			if args.veryverbose:
				print "Adding extrema"
			font.addExtrema()
			if args.veryverbose:
				print "Simplifying"
			font.simplify()
			if args.veryverbose:
				print "Rounding"
			font.round()
			if args.veryverbose:
				print "Simplifying"
			font.simplify()
			if args.veryverbose:
				print "Rounding"
			font.round()
			if args.veryverbose:
				print "Hinting"
			font.autoHint()
		else:		# user defined script
			font.save("%s/temp.sfd" % tempdir)
			subprocess.call(
			['fontforge',
			'-script',
			os.path.join(os.path.split(os.path.abspath("%s" % args.mfsource))[0],args.ffscript),
			'%s/temp.sfd' % tempdir],
			stdout=subprocess.PIPE, 
			stderr=subprocess.PIPE,
			cwd=tempdir,
			)
			font=fontforge.open("%s/temp.sfd" % tempdir)
			 
	if args.verbose:
		print "Saving outline font file..."
	if args.fullnameasfilename:
		outputname = font.fullname
	else:
		outputname = generalname
	for outlineformat in args.formats:
		if outlineformat == "sfd":
			font.save("%s.%s" % (outputname,outlineformat))
		elif outlineformat == "pdf":
			generate_pdf(font,mffile,outputname,tempdir,args)
		else:
			font.generate("%s.%s" % (outputname,outlineformat))
	
	#print os.listdir(tempdir)
	#f = open('%s/mf2outline.txt' % tempdir,"r")
	#print f.read()
	#f.close()
	
	shutil.rmtree(tempdir)
	
	exit(0)
